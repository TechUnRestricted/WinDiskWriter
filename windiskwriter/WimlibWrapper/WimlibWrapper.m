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

- (enum wimlib_error_code)splitWithDestinationDirectoryPath: (NSString * _Nonnull)destinationDirectoryPath
                                        maxSliceSizeInBytes: (UInt64 * _Nonnull)maxSliceSizeInBytes
                                            progressHandler: (wimlib_progress_func_t _Nullable)progressHandler
                                                    context: (void *_Nullable)context {
    
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

- (enum wimlib_error_code)extractFiles: (NSArray *)files
                  destinationDirectory: (NSString *)destinationDirectory {
    
    CChar2DArray *filesArrayCCharEncoded = [[CChar2DArray alloc] initWithNSArray:files];
    
    return wimlib_extract_paths(currentWIM,
                                1,
                                [destinationDirectory UTF8String],
                                [filesArrayCCharEncoded getArray],
                                [files count],
                                WIMLIB_EXTRACT_FLAG_NO_PRESERVE_DIR_STRUCTURE
                                );
}

- (BOOL)bypassWindowsSecurityChecks {
    UInt32 imageCount = currentWIM->hdr.image_count;
    
    // Image indexes are 1-based
    for (UInt32 currentImageIndex = 1; currentImageIndex <= imageCount; currentImageIndex++) {
        char *propertyName = "WINDOWS/INSTALLATIONTYPE";
        char *propertyValue = "Server";
        
        enum wimlib_error_code result = wimlib_set_image_property(currentWIM,
                                                                  currentImageIndex,
                                                                  propertyName,
                                                                  propertyValue);
        
        if (result != WIMLIB_ERR_SUCCESS && result != WIMLIB_ERR_IMAGE_NAME_COLLISION) {
            return NO;
        }
        
    }
    
    return YES;
}

- (void)dealloc {
    if (currentWIM != NULL) {
        wimlib_free(currentWIM);
    }
}

@end
