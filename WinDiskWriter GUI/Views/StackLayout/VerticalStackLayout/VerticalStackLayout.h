//
//  VerticalStackLayout.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseStackLayout.h"

NS_ASSUME_NONNULL_BEGIN

extern StackLayoutConstraintIdentifier const StackLayoutConstraintIdentifierBottom;
extern StackLayoutConstraintIdentifier const StackLayoutConstraintIdentifierBottomWeak;

@interface VerticalStackLayout : BaseStackLayout

- (void)addView: (NSView *_Nonnull)newView
        spacing: (CGFloat)spacing;

@end

NS_ASSUME_NONNULL_END
