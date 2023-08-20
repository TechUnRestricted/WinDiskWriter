//
//  SynchronizedAlertData.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 21.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SynchronizedAlertData : NSObject

@property (nonatomic, readonly) dispatch_semaphore_t semaphore;
@property (nonatomic, readwrite) NSInteger resultCode;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSemaphore: (dispatch_semaphore_t)semaphore;

@end

NS_ASSUME_NONNULL_END
