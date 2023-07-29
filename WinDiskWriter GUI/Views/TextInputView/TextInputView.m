//
//  TextInputView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 27.07.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "TextInputView.h"
#import "VerticalCenteredTextFieldCell.h"

@implementation TextInputView

- (instancetype)init {
    self = [super init];
    
    [self setBezeled: YES];
    [self setBezelStyle: NSTextFieldRoundedBezel];
    
    if (@available(macOS 10.10, *)) {
        [self setLineBreakMode: NSLineBreakByTruncatingMiddle];
    }
    
    [self setBordered: YES];
    
    VerticalCenteredTextFieldCell *verticalCenteredTextFieldCell = [[VerticalCenteredTextFieldCell alloc] init];
    [verticalCenteredTextFieldCell setEditable: YES];
    [verticalCenteredTextFieldCell setTitle:@""];
    
    [self setCell: verticalCenteredTextFieldCell];
        
    return self;
}

@end
