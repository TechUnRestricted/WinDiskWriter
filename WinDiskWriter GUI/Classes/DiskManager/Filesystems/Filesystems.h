//
//  Filesystems.h
//  windiskwriter
//
//  Created by Macintosh on 28.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *Filesystem NS_TYPED_ENUM;
extern Filesystem const FilesystemFAT32;
extern Filesystem const FilesystemFAT16 UNAVAILABLE_ATTRIBUTE;
extern Filesystem const FilesystemFAT12 UNAVAILABLE_ATTRIBUTE;
extern Filesystem const FilesystemExFAT;

// TODO: Add more Filesystems

NS_ASSUME_NONNULL_END
