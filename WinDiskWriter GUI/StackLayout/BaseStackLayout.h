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
extern StackLayoutConstraintIdentifier const StackLayoutConstraintIdentifierTrailing;
extern StackLayoutConstraintIdentifier const StackLayoutConstraintIdentifierTrailingWeak;

@interface BaseStackLayout : NSView

@property (nonatomic, strong, readonly) NSView *containerView;

@end

NS_ASSUME_NONNULL_END
