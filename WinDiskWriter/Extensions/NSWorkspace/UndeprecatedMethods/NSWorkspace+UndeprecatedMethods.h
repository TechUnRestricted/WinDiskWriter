//
//  NSWorkspace+UndeprecatedMethods.h
//  WinDiskWriter
//
//  Created by Macintosh on 29.12.2024.
//

#ifndef NSWorkspace_UndeprecatedMethods_h
#define NSWorkspace_UndeprecatedMethods_h

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface NSWorkspace (UndeprecatedMethods)
- (NSImage *)iconForFileTypeUndeprecated:(NSString *)fileType;
@end

#endif /* NSWorkspace_UndeprecatedMethods_h */
