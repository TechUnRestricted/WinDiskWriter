//
//  CommandLine.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

struct CommandLineReturn {
    NSData *standardData;
    NSData *errorData;

    int processIdentifier;
    int terminationStatus;
    NSTaskTerminationReason terminationReason;
};

@interface CommandLine : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (struct CommandLineReturn)execute: (NSString *)executable
                          arguments: (NSArray *)arguments;
@end

NS_ASSUME_NONNULL_END

