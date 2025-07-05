//
//  LogView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.11.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "LogView.h"
#import "NSColor+Common.h"
#import "VibrantTableView.h"
#import "NSMutableAttributedString+Common.h"
#import "LocalizedStrings.h"
#import "ContaineredTableView.h"
#import "MiddleAlignedCell.h"

/*
ASLogType ASLogTypeStart = @"Start";
ASLogType ASLogTypeSuccess = @"Success";
ASLogType ASLogTypeFailure = @"Failure";
ASLogType ASLogTypeSkipped = @"Skipped";

ASLogType ASLogTypeLog = @"Log";
ASLogType ASLogTypeWarning = @"Warning";
ASLogType ASLogTypeFatal = @"Fatal";
ASLogType ASLogTypeAssertionError = @"AssertionFailure";
*/
 
@implementation LogView {
    NSDateFormatter *dateFormatter;
    NSTextField *dummyTextField;
}

+ (NSString *)logTypeStringForKey: (ASLogType)logType {
    switch (logType) {
        case ASLogTypeStart:
            return [LocalizedStrings asLogTypeStart];
        case ASLogTypeSuccess:
            return [LocalizedStrings asLogTypeSuccess];
        case ASLogTypeFailure:
            return [LocalizedStrings asLogTypeFailure];
        case ASLogTypeSkipped:
            return [LocalizedStrings asLogTypeSkipped];
        case ASLogTypeLog:
            return [LocalizedStrings asLogTypeLog];
        case ASLogTypeWarning:
            return [LocalizedStrings asLogTypeWarning];
        case ASLogTypeFatal:
            return [LocalizedStrings asLogTypeFatal];
        case ASLogTypeAssertionError:
            return [LocalizedStrings asLogTypeAssertionError];
    }
    
    // Fallback value
    return [LocalizedStrings asLogTypeLog];
}

- (instancetype)init {
    self = [super init];
    
    _tableViewInstance = [[VibrantTableView alloc] init];
    // [self.tableViewInstance setWantsLayer: YES];
    // [self.tableViewInstance.layer setBackgroundColor: NSColor.purpleColor.toCGColor];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    
    dummyTextField = [[NSTextField alloc] init];
    
    MiddleAlignedCell *middleAlignedCell = [[MiddleAlignedCell alloc] init];
    [dummyTextField setCell:middleAlignedCell];
    [dummyTextField setFont: ((VibrantTableView *)self.documentView).requiredFont];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];

    [self setHasVerticalScroller: YES];
    [self setHasHorizontalScroller: YES];

    [self setAutohidesScrollers: YES];
    [self setDrawsBackground: NO];
        
    ContaineredTableView *paddingView = [[ContaineredTableView alloc] initWithDocumentView: self.tableViewInstance];
    [paddingView setPaddingTop: 4];
    [paddingView setPaddingBottom: 4];

    // [paddingView setWantsLayer: YES];
    // [paddingView.layer setBackgroundColor: NSColor.brownColor.toCGColor];
     
    [self setDocumentView: paddingView];
    
    const CGFloat CORNER_RADIUS = 10.0f;
    
    // Give the NSScrollView a backing layer and set it's corner radius.
    [self setWantsLayer:YES];
    [self.layer setCornerRadius:CORNER_RADIUS];

    // Give the NSScrollView's internal clip view a backing layer and set it's corner radius.
    [self.contentView setWantsLayer:YES];
    [self.contentView.layer setCornerRadius:CORNER_RADIUS];

    [self.contentView.layer setBorderColor: [NSColor.textColor colorWithAlphaComponent: 0.25].toCGColor];
    
    [self.contentView.layer setBorderWidth: 1.5f];
    
    return self;
}

- (NSString *)timeString {    
    return [dateFormatter stringFromDate: NSDate.date];
}

- (void)appendRow:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
        VibrantTableView *childView = (VibrantTableView *)self.tableViewInstance;
        
        if (@available(macOS 26.0, *)) {
            
        } else {
            [self->dummyTextField setStringValue: string];
        }
        
        CGFloat requiredCellWidth = self->dummyTextField.cell.cellSize.width;
        
        CGFloat currentColumnWidth = childView.frame.size.width;
        
        if (requiredCellWidth > currentColumnWidth) {
            [childView setColumnWidth: requiredCellWidth + 12];
        }
        
        [childView.rowData addObject: string];
        [childView reloadData];
        
        if ([childView numberOfRows] > 0) {
            [childView scrollRowToVisible: [childView numberOfRows] - 1];
        }
    });
}

- (void)appendTimestampedRow: (NSString *)string
                     logType: (ASLogType)logType {
    NSString *timestampedString = [NSString stringWithFormat: @"[(%@) %@] %@", [LogView logTypeStringForKey: logType], [self timeString], string];
    
    [self appendRow: timestampedString];
}

- (void)appendRow: (NSString *)string
          logType: (ASLogType)logType {
    NSString *logTypedString = [NSString stringWithFormat: @"[%@] %@", [LogView logTypeStringForKey: logType], string];
    
    [self appendRow:logTypedString];
}

- (void)appendTimestampedRow: (NSString *)string {
    NSString *finalString = [NSString stringWithFormat: @"[%@] %@", [self timeString], string];
    
    [self appendRow: finalString];
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
