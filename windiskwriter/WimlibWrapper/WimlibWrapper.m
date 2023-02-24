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

@implementation WimlibWrapper {
    WIMStruct *currentWIM;
}

- (instancetype _Nullable)initWithWimPath: (NSString *)wimPath {
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exists = [defaultManager fileExistsAtPath:wimPath isDirectory:&isDirectory];
    
    if (!exists || isDirectory) {
        return NULL;
    }
    
    enum wimlib_error_code wimOpenStatus = wimlib_open_wim([wimPath UTF8String], NULL, &currentWIM);
    if (wimOpenStatus != WIMLIB_ERR_SUCCESS) {
        return NULL;
    }
    
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

- (void)dealloc {
    if (currentWIM != NULL) {
        wimlib_free(currentWIM);
    }
}

@end
