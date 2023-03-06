//
//  BaseStackLayout.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 05.03.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "BaseStackLayout.h"
#import "NSView+QuickConstraints.h"

@implementation BaseStackLayout

- (instancetype)init {
    self = [super init];
    
    _containerView = [[NSView alloc] init];
    
    [_containerView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [self addSubview: _containerView];
    
    [_containerView setConstraintAttribute:NSLayoutAttributeWidth toItem:self itemAttribute:NSLayoutAttributeWidth relation:NSLayoutRelationEqual isWeak:NO constant:0 identifier:NULL];
    [_containerView setConstraintAttribute:NSLayoutAttributeHeight toItem:self itemAttribute:NSLayoutAttributeHeight relation:NSLayoutRelationEqual isWeak:NO constant:0 identifier:NULL];

    return self;
}

@end
