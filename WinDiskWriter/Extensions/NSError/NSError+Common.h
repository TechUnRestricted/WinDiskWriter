//
//  NSError+Common.h
//  windiskwriter
//
//  Created by Macintosh on 20.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (Common)

- (NSString *)stringValue;
+ (NSError *)errorWithStringValue: (NSString *)stringValue;

@end

NS_ASSUME_NONNULL_END
