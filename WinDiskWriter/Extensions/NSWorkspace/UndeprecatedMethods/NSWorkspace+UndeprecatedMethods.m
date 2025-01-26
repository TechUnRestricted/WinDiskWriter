//
//  NSWorkspace+UndeprecatedMethods.m
//  WinDiskWriter
//
//  Created by Macintosh on 29.12.2024.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#import "NSWorkspace+UndeprecatedMethods.h"

@implementation NSWorkspace (UndeprecatedMethods)

- (NSImage *)iconForFileTypeUndeprecated:(NSString *)fileType {
    return [self iconForFileType:fileType];
}

@end

#pragma clang diagnostic pop
