//
//  SynchronizedAlertData.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 21.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "SynchronizedAlertData.h"

@implementation SynchronizedAlertData

- (instancetype)initWithSemaphore: (dispatch_semaphore_t)semaphore {
    self = [super init];
    
    _semaphore = semaphore;
    
    return self;
}

@end
