//
//  TextInputView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 27.07.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "TextInputView.h"

@implementation TextInputView

- (instancetype)init {
    self = [super init];
    
    [self setBezeled: YES];
    [self setBordered: YES];
        
    if (@available(macOS 10.10, *)) {
        [self setLineBreakMode: NSLineBreakByTruncatingMiddle];
    }
        
    [self setBezeled: YES];
    [self setBezelStyle: NSTextFieldRoundedBezel];
    
    [self setFocusRingType:NSFocusRingTypeNone];
    
    return self;
}

@end
