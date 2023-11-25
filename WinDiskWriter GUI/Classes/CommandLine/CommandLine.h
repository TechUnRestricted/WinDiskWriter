//
//  CommandLine.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "CommandLineData.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommandLine : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (CommandLineData *_Nullable)execute: (NSString *)executable
                            arguments: (NSArray *_Nullable)arguments;
@end

NS_ASSUME_NONNULL_END

