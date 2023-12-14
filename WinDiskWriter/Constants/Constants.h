//
//  Constants.h
//  windiskwriter
//
//  Created by Macintosh on 05.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern const CGFloat MAIN_CONTENT_SPACING;
extern const CGFloat CHILD_CONTENT_SPACING;

+ (NSString *)applicationName;
+ (NSString *)applicationVersion;
+ (NSString *)bundleIndentifier;
+ (NSString *)developerName;

/* Partition Scheme Types */
extern NSString * const PARTITION_SCHEME_TYPE_MBR_TITLE;
extern NSString * const PARTITION_SCHEME_TYPE_GPT_TITLE;

/* Filesystem Types */
extern NSString * const FILESYSTEM_TYPE_FAT32_TITLE;
extern NSString * const FILESYSTEM_TYPE_EXFAT_TITLE;

@end

#endif /* Constants_h */
