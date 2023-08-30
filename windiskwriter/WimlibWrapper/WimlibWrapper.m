//
//  WimlibWrapper.m
//  windiskwriter
//
//  Created by Macintosh on 12.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "WimlibWrapper.h"
#import "CChar2DArray.h"
#import "wimlib.h"
#import "wim.h"
#import "xml.h"

@implementation WimlibWrapper {
    WIMStruct *currentWIM;
}

- (instancetype)initWithWimPath: (NSString *)wimPath {
    
    enum wimlib_error_code wimOpenStatus = wimlib_open_wim([wimPath UTF8String], NULL, &currentWIM);
    _wimPath = wimPath;
    
    return self;
}

- (UInt32)imagesCount {
    if (currentWIM == NULL) {
        return 0;
    }
    
    return currentWIM->hdr.image_count;
}

- (WimLibWrapperCPUArch)CPUArchitectureForImageIndex: (UInt32)imageIndex {
    if (currentWIM == NULL) {
        return NULL;
    }
    
    NSString *stringValue = [self propertyValueForKey: @"WINDOWS/ARCH"
                                           imageIndex: imageIndex];
    
    if (stringValue == NULL) {
        return WimLibWrapperCPUArchUnknown;
    }
    
    NSInteger convertedIntegerValue = [stringValue integerValue];
    
    switch (convertedIntegerValue) {
        case WimLibWrapperCPUArchIntel:
        case WimLibWrapperCPUArchMIPS:
        case WimLibWrapperCPUArchAlpha:
        case WimLibWrapperCPUArchPPC:
        case WimLibWrapperCPUArchSHX:
        case WimLibWrapperCPUArchARM:
        case WimLibWrapperCPUArchIA64:
        case WimLibWrapperCPUArchAlpha64:
        case WimLibWrapperCPUArchMSIL:
        case WimLibWrapperCPUArchAMD64:
        case WimLibWrapperCPUArchIA32OnWin64:
        case WimLibWrapperCPUArchARM64:
            return convertedIntegerValue;
        default:
            return WimLibWrapperCPUArchUnknown;
    }
}

- (NSString *_Nullable)propertyValueForKey: (NSString *)key
                                imageIndex: (NSUInteger)imageIndex {
    if (currentWIM == NULL) {
        return NULL;
    }
    
    return [NSString stringWithCString: wimlib_get_image_property(currentWIM, imageIndex, key.UTF8String)
                              encoding: NSUTF8StringEncoding];
}

- (WimlibWrapperResult)setPropertyValue: (NSString *)value
                                 forKey: (NSString *)key
                             imageIndex: (UInt32)imageIndex {
    if (currentWIM == NULL) {
        return NO;
    }
    
    NSString *currentValue = [self propertyValueForKey: key
                                            imageIndex: imageIndex];
    
    if ([value isEqualToString:currentValue]) {
        return WimlibWrapperResultSkipped;
    }
    
    enum wimlib_error_code result = wimlib_set_image_property(currentWIM,
                                                              imageIndex,
                                                              [key cStringUsingEncoding: NSUTF8StringEncoding],
                                                              [value cStringUsingEncoding: NSUTF8StringEncoding]);
    
    if (result != WIMLIB_ERR_SUCCESS) {
        return WimlibWrapperResultFailure;
    }
    
    return WimlibWrapperResultSuccess;
}

- (WimlibWrapperResult)setPropertyValueForAllImages: (NSString *)value
                                             forKey: (NSString *)key {
    
    UInt32 imagesCount = [self imagesCount];
    
    BOOL requiresOverwriting = NO;
    
    for (UInt32 currentImageIndex = 1; currentImageIndex <= imagesCount; currentImageIndex++) {
        WimlibWrapperResult setPropertyResult = [self setPropertyValue: value
                                                                forKey: key
                                                            imageIndex: currentImageIndex];
        
        switch (setPropertyResult) {
            case WimlibWrapperResultSuccess:
                requiresOverwriting = YES;
                break;
            case WimlibWrapperResultFailure:
                return WimlibWrapperResultFailure;
            case WimlibWrapperResultSkipped:
                break;
        }
    }
    
    return requiresOverwriting ? WimlibWrapperResultSuccess : WimlibWrapperResultSkipped;
}

- (BOOL)applyChanges {
    if (currentWIM == NULL) {
        return NO;
    }
    
    enum wimlib_error_code overwriteReturnCode = wimlib_overwrite(currentWIM, 0, 1);
    
    return overwriteReturnCode == WIMLIB_ERR_SUCCESS;
}

- (enum wimlib_error_code)splitWithDestinationDirectoryPath: (NSString *)destinationDirectoryPath
                                        maxSliceSizeInBytes: (UInt64 *)maxSliceSizeInBytes
                                            progressHandler: (wimlib_progress_func_t _Nullable)progressHandler
                                                    context: (void *_Nullable)context {
    if (currentWIM == NULL) {
        return WIMLIB_ERR_ABORTED_BY_PROGRESS;
    }
    
    if (progressHandler != NULL) {
        wimlib_register_progress_function(currentWIM, progressHandler, context);
    }
    
    NSString *destinationFileName = [[[_wimPath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"swm"];
    
    return wimlib_split(currentWIM,
                        [[destinationDirectoryPath stringByAppendingPathComponent:destinationFileName] UTF8String],
                        maxSliceSizeInBytes,
                        NULL
                        );
}

- (BOOL)extractFiles: (NSArray *)files
destinationDirectory: (NSString *)destinationDirectory
      fromImageIndex: (UInt32)imageIndex {
    
    if (currentWIM == NULL) {
        return NULL;
    }
    
    CChar2DArray *filesArrayCCharEncoded = [[CChar2DArray alloc] initWithNSArray:files];
    
    enum wimlib_error_code extractionResult = wimlib_extract_paths(currentWIM,
                                                                   imageIndex,
                                                                   [destinationDirectory UTF8String],
                                                                   [filesArrayCCharEncoded getArray],
                                                                   [files count],
                                                                   WIMLIB_EXTRACT_FLAG_NO_PRESERVE_DIR_STRUCTURE
                                                                   );
    
    return extractionResult == WIMLIB_ERR_SUCCESS;
}

- (WimlibWrapperResult)extractWindowsEFIBootloaderForDestinationDirectory: (NSString *)destinationDirectory {
    UInt32 imagesCount = [self imagesCount];
    
    for (UInt32 currentImageIndex = 1; currentImageIndex <= imagesCount; currentImageIndex++) {
        if ([self CPUArchitectureForImageIndex:currentImageIndex] != WimLibWrapperCPUArchAMD64) {
            continue;
        }
        
        BOOL bootloaderExtractionResult = [self extractFiles: @[@"/Windows/Boot/EFI/bootmgfw.efi"]
                                        destinationDirectory: destinationDirectory
                                              fromImageIndex: currentImageIndex];
        
        if (!bootloaderExtractionResult) {
            return WimlibWrapperResultFailure;
        }
        
        BOOL bootloaderRanamingSuccess = [NSFileManager.defaultManager moveItemAtPath: [destinationDirectory stringByAppendingPathComponent: @"bootmgfw.efi"]
                                                                               toPath: [destinationDirectory stringByAppendingPathComponent: @"bootx64.efi"]
                                                                                error: NULL];
        if (!bootloaderRanamingSuccess) {
            return NO;
        }
        
        return WimlibWrapperResultSuccess;
    }
    
    return WimlibWrapperResultSkipped;
}

- (WimlibWrapperResult)patchWindowsRequirementsChecks {
    if (currentWIM == NULL) {
        return WimlibWrapperResultFailure;
    }
    
    WimlibWrapperResult setPropertyResult = [self setPropertyValueForAllImages: @"Server"
                                                                        forKey: @"WINDOWS/INSTALLATIONTYPE"];
    
    switch (setPropertyResult) {
        case WimlibWrapperResultSkipped:
        case WimlibWrapperResultFailure:
            return setPropertyResult;
        default:
            break;
    }
    
    WimlibWrapperResult applyChangesResult = [self applyChanges];
    
    return applyChangesResult;
}

- (void)dealloc {
    if (currentWIM != NULL) {
        wimlib_free(currentWIM);
    }
}

@end
