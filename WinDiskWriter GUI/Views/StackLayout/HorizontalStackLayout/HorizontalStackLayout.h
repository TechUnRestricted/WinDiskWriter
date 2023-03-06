//
//  HorizontalStackLayout.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 04.03.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseStackLayout.h"

NS_ASSUME_NONNULL_BEGIN

extern StackLayoutConstraintIdentifier const StackLayoutConstraintIdentifierTrailing;
extern StackLayoutConstraintIdentifier const StackLayoutConstraintIdentifierTrailingWeak;

@interface HorizontalStackLayout : BaseStackLayout

- (void)addView: (NSView *_Nonnull)newView
        spacing: (CGFloat)spacing;

@end

NS_ASSUME_NONNULL_END
