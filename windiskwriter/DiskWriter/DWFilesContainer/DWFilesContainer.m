//
//  DWFilesContainer.m
//  windiskwriter
//
//  Created by Macintosh on 21.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "DWFilesContainer.h"
#import "DWFile.h"

@implementation DWFilesContainer

- (instancetype)initWithSWFileInfoArray: (NSArray<DWFile *> *_Nonnull)array
                          containerPath: (NSString *_Nonnull)containerPath {
    
    _files = array;
    _containerPath = containerPath;
    
    return self;
}

- (UInt64)sizeOfFiles {
    UInt64 filesSize = 0;
    for (DWFile *currentFile in _files) {
        filesSize += currentFile.size;
    }
    
    return filesSize;
}

+ (DWFilesContainer *_Nullable)containerFromContainerPath: (NSString *_Nonnull)containerPath
                                                 callback: (DWFilesContainerCallback)callback {
    
    NSMutableArray<DWFile *> *filesList = [[NSMutableArray alloc] init];
    
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:containerPath];
    
    NSString *currentRelativePath = NULL;
    while ((currentRelativePath = [dirEnum nextObject])) {
        enum DWAction callbackAction;
        
        DWFile *currentFile = [[DWFile alloc] initWithSourcePath: currentRelativePath];
        
        callbackAction = callback(currentFile, DWFilesContainerMessageGetAttributesProcess);
        if (callbackAction == DWActionSkip) {
            continue;
        } else if (callbackAction == DWActionStop) {
            break;
        }
        
        NSError *fileAttributesError = NULL;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[containerPath
                                                                                               stringByAppendingPathComponent:currentRelativePath]
                                                                                        error:&fileAttributesError];
        currentFile.size = [fileAttributes fileSize];
        currentFile.fileType = [fileAttributes fileType];
        
        callbackAction = callback(currentFile,
                                  (fileAttributesError == NULL ?
                                   DWFilesContainerMessageGetAttributesSuccess : DWFilesContainerMessageGetAttributesFailure));
        if (callbackAction == DWActionSkip) {
            continue;
        } else if (callbackAction == DWActionStop) {
            break;
        }
        
        [filesList addObject:currentFile];
    }
    
    
    return [[DWFilesContainer alloc] initWithSWFileInfoArray: filesList
                                               containerPath: containerPath];
}

@end
