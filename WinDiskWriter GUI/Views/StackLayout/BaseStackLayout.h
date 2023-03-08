//
//  BaseStackLayout.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 05.03.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *StackLayoutConstraintIdentifier NS_TYPED_ENUM;

@interface BaseStackLayout : NSView

@property (nonatomic, strong, readonly) NSView *containerView;

- (void)removeConstraintsForFirstOccurenceWithID: (StackLayoutConstraintIdentifier)constraintID
                                         forView: (NSView *)nsView;

- (void)removeAllConstraintsWithID: (StackLayoutConstraintIdentifier)constraintID;

@end

NS_ASSUME_NONNULL_END
