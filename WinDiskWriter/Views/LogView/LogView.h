//
//  LogView.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.11.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ASLogType) {
    ASLogTypeStart,
    ASLogTypeSuccess,
    ASLogTypeFailure,
    ASLogTypeSkipped,
    
    ASLogTypeLog,
    ASLogTypeWarning,
    ASLogTypeFatal,
    ASLogTypeAssertionError
};

@interface LogView : NSScrollView

@property (strong, nonatomic, readonly) NSTableView *tableViewInstance;

- (void)appendRow: (NSString *)string;

- (void)appendTimestampedRow: (NSString *)string
                     logType: (ASLogType)logType;

- (void)appendRow: (NSString *)string
          logType: (ASLogType)logType;

- (void)appendTimestampedRow: (NSString *)string;

@end

NS_ASSUME_NONNULL_END
