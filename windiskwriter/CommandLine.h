//
//  CommandLine.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface CommandLine : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (NSData * _Nullable)execute: (NSString *)executable
                withArguments: (NSArray *)arguments;
@end

NS_ASSUME_NONNULL_END

