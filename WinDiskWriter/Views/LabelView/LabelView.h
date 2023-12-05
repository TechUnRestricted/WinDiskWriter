//
//  LabelView.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 05.03.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface LabelView : NSTextField

- (BOOL)isClickActionRegistered;

- (void)unregisterClickAction;

- (void)registerClickWithTarget: (id)target
                       selector: (SEL)selector;

@end

NS_ASSUME_NONNULL_END
