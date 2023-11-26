//
//  NSFileManager+Common.m
//  windiskwriter
//
//  Created by Macintosh on 04.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "NSFileManager+Common.h"

@implementation NSFileManager (Common)

- (BOOL)folderExistsAtPath: (NSString *)folderPath {
    BOOL isDirectory = NO;
    BOOL exists = [self fileExistsAtPath: folderPath
                             isDirectory: &isDirectory];
    
    return (exists && isDirectory);
}

- (BOOL)fileExistsAtPathAndNotAFolder:(NSString *)filePath {
    BOOL isDirectory = NO;
    BOOL exists = [self fileExistsAtPath: filePath
                             isDirectory: &isDirectory];
    
    if (!exists || isDirectory) {
        return NO;
    }

    return YES;
}

@end
