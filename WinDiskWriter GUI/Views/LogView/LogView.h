//
//  LogView.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.11.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *ASLogType NS_TYPED_ENUM;

extern ASLogType const ASLogTypeStart;
extern ASLogType const ASLogTypeSuccess;
extern ASLogType const ASLogTypeFailure;
extern ASLogType const ASLogTypeSkipped;

extern ASLogType const ASLogTypeLog;
extern ASLogType const ASLogTypeWarning;
extern ASLogType const ASLogTypeFatal;
extern ASLogType const ASLogTypeAssertionError;

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
