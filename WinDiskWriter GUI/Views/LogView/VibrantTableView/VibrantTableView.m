//
//  VibrantTableView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.11.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "VibrantTableView.h"
#import "VerticalCenteredTextFieldCell.h"

@implementation VibrantTableView

NSString *MAIN_COLUMN = @"MAIN_COLUMN";

- (instancetype)init {
    self = [super init];
    
    _rowData = [[NSMutableArray alloc] init];
    _requiredFont = [NSFont systemFontOfSize: NSFont.systemFontSize / 1.1];
    
    [self setAllowsMultipleSelection: YES];
    [self setHeaderView: NULL];
    [self setFocusRingType: NSFocusRingTypeNone];
    
    if (@available(macOS 11.0, *)) {
        [self setStyle: NSTableViewStylePlain];
    }
        
    NSTextField *dummyTextField = [[NSTextField alloc] init];
    [dummyTextField setFont: self.requiredFont];
    
    [self setRowHeight: dummyTextField.cell.cellSize.height + 2];
    
    _mainColumn = [[NSTableColumn alloc] initWithIdentifier: MAIN_COLUMN];
    [self.mainColumn.dataCell setFont: self.requiredFont];

    [self addTableColumn: self.mainColumn];
    
    [self setDelegate: self];
    [self setDataSource: self];
        
    return self;
}

- (NSInteger)numberOfRowsInTableView: (NSTableView *)tableView {
    return self.rowData.count;
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return NO;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *rowLine = [self.rowData objectAtIndex: row];
        
    return rowLine;
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
