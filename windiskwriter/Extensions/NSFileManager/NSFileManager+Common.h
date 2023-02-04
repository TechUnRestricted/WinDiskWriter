//
//  NSFileManager+Common.h
//  windiskwriter
//
//  Created by Macintosh on 04.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Common)

- (BOOL)folderExistsAtPath: (NSString *)folderPath;

@end

NS_ASSUME_NONNULL_END
