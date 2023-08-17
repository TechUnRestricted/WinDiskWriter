//
//  NSString+Common.h
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Common)
- (BOOL)hasOneOfThePrefixes:(NSArray *)prefixes;
- (BOOL)hasOneOfTheSuffixes:(NSArray *)suffixes;
- (BOOL)isOneOfTheValues:(NSArray *)values;
- (NSString *)removeLeadingTrailingSpaces;
@end

NS_ASSUME_NONNULL_END
