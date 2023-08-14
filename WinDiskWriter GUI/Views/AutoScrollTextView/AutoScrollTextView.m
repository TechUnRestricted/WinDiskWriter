//
//  AutoScrollTextView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 10.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "AutoScrollTextView.h"
#import "NSColor+Common.h"

ASLogType const ASLogTypeLog = @"Log";
ASLogType const ASLogTypeSuccess = @"Success";
ASLogType const ASLogTypeWarning = @"Warning";
ASLogType const ASLogTypeError = @"Error";
ASLogType const ASLogTypeFatal = @"Fatal";
ASLogType const ASLogTypeAssertionError = @"AssertionFailure";

@implementation AutoScrollTextView {
    NSDateFormatter *dateFormatter;
}

- (instancetype) init {
    self = [super init];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];

    [self setHasVerticalScroller: YES];
    
    [self setAutohidesScrollers: YES];
    
    [self setHasHorizontalScroller:NO];
    
    [self setDrawsBackground: NO];
    [self.contentView setWantsLayer:YES];
    [self.contentView.layer setCornerRadius:10.0f];

    [self.contentView.layer setBorderColor:[NSColor.textColor colorWithAlphaComponent:0.25].toCGColor];

    [self.contentView.layer setBorderWidth: 1.5f];
    
    _textViewInstance = [[VibrantTextView alloc] init];
    
    [self.textViewInstance setTextContainerInset: NSMakeSize(5, 10)];
    [self.textViewInstance setAutoresizingMask:NSViewWidthSizable];
    [self.textViewInstance setEditable: NO];
    [self.textViewInstance setSelectable: YES];
    
    [self.textViewInstance setFocusRingType:NSFocusRingTypeNone];

    [self setDocumentView: self.textViewInstance];

    return self;
}


- (void)appendLine: (NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *appendedString = [NSString stringWithFormat:@"%@%@\n", self.textViewInstance.string, message];

        [self.textViewInstance setString:appendedString];
    });
}

- (BOOL)allowsVibrancy {
    return YES;
}

- (void)appendTimestampedLine: (NSString *)message
                      logType: (ASLogType)logType {
    NSString *timeString = [dateFormatter stringFromDate: NSDate.date];
    NSString *timestampedString = [NSString stringWithFormat:@"[(%@) %@] %@", logType, timeString, message];
    
    [self appendLine: timestampedString];
}

- (void)clear {
    [self.textViewInstance setString:@""];    
}


@end
