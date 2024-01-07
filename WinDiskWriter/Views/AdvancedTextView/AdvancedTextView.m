//
//  AdvancedTextView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 10.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "AdvancedTextView.h"
#import "NSColor+Common.h"

@implementation AdvancedTextView {
    NSDateFormatter *dateFormatter;
}

- (instancetype) init {
    self = [super init];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];

    [self setHasVerticalScroller: YES];
    [self setAutohidesScrollers: YES];
    [self setHasHorizontalScroller: NO];
    [self setDrawsBackground: NO];
    
    [self.contentView setWantsLayer: YES];
    [self.contentView.layer setCornerRadius: 10.0f];

    [self.contentView.layer setBorderColor: [NSColor.textColor colorWithAlphaComponent: 0.25].toCGColor];

    [self.contentView.layer setBorderWidth: 1.5f];
    
    _textViewInstance = [[VibrantTextView alloc] init];
    
    [self.textViewInstance setTextContainerInset: NSMakeSize(5, 10)];
    [self.textViewInstance setAutoresizingMask: NSViewWidthSizable];
    [self.textViewInstance setEditable: NO];
    [self.textViewInstance setSelectable: YES];
    
    [self.textViewInstance setFocusRingType: NSFocusRingTypeNone];

    [self setDocumentView: self.textViewInstance];

    return self;
}

// TODO: Replace this with something better
- (void)delayedUpdate {
    [self.documentView scrollPoint: NSMakePoint(0, self.documentView.frame.size.height)];
}

- (void)appendLine: (NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *appendedString = [NSString stringWithFormat:@"%@%@\n", self.textViewInstance.string, message];

        [self.textViewInstance setString:appendedString];
        
        if (self.automaticallyScroll) {
            [NSTimer scheduledTimerWithTimeInterval: 1.0f
                                             target: self
                                           selector: @selector(delayedUpdate)
                                           userInfo: NULL
                                            repeats: NO];
        }
        
    });
}

- (BOOL)allowsVibrancy {
    return YES;
}

- (void)appendTimestampedLine: (NSString *)message {
    NSString *timeString = [dateFormatter stringFromDate: NSDate.date];

    NSString *finalString = [NSString stringWithFormat: @"[%@] %@", timeString, message];
    
    [self appendLine: finalString];
}

- (void)clear {
    [self.textViewInstance setString:@""];    
}


@end
