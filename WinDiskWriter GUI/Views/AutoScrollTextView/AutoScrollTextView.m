//
//  AutoScrollTextView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 10.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "AutoScrollTextView.h"

@implementation AutoScrollTextView {
    NSDateFormatter *dateFormatter;
}

- (instancetype) init {
    self = [super init];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];

    [self setHasVerticalScroller: NO];
    [self setHasHorizontalScroller:NO];
    
    [self setBackgroundColor: NSColor.redColor];
    [self.layer setCornerRadius:10.0f];
    
    [self setDrawsBackground: NO];
    
    [self.contentView setWantsLayer:YES];
    [self.contentView.layer setCornerRadius:10.0f];
    
    _textViewInstance = [[NSTextView alloc] init];
    
    [self.textViewInstance setVerticallyResizable: YES];
    [self.textViewInstance setHorizontallyResizable: NO];
    [self.textViewInstance setAutoresizingMask:NSViewWidthSizable];
    [self.textViewInstance setEditable: NO];
    [self.textViewInstance setSelectable: YES];
    
    [self.textViewInstance setWantsLayer:YES];
    [self.textViewInstance.layer setCornerRadius:10.0f];
    
    [self.textViewInstance setFocusRingType:NSFocusRingTypeNone];

    [self setDocumentView: self.textViewInstance];

    return self;
}


- (void)appendLine: (NSString *)message {
    NSString *appendedString = [NSString stringWithFormat:@"%@%@\n", self.textViewInstance.string, message];
    
    [self.textViewInstance setString:appendedString];
    
    //[self scrollToEndOfDocument: self.textViewInstance];
}

- (void)appendTimestampedLine: (NSString *)message {
    NSString *timeString = [dateFormatter stringFromDate: NSDate.date];
    NSString *timestampedString = [NSString stringWithFormat:@"[%@] %@", timeString, message];
    
    [self appendLine: timestampedString];
}

- (void)clear {
    [self.textViewInstance setString:@""];
    
    [self scrollToEndOfDocument: NULL];
}


@end
