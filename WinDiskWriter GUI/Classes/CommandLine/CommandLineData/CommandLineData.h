//
//  CommandLineData.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 25.11.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommandLineData : NSObject

@property (strong, nonatomic, readonly, nullable) NSData *standardData;
@property (strong, nonatomic, readonly, nullable) NSData *errorData;

@property (nonatomic, readonly) NSInteger processIdentifier;
@property (nonatomic, readonly) NSInteger terminationStatus;

@property (nonatomic, readonly) NSTaskTerminationReason terminationReason;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithProcessIdentifier: (NSInteger)processIdentifier
                        terminationStatus: (NSInteger)terminationStatus
                        terminationReason: (NSTaskTerminationReason)terminationReason
                             standardData: (NSData *)standardData
                                errorData: (NSData *)errorData;


@end

NS_ASSUME_NONNULL_END
