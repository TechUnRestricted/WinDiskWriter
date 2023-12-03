//
//  VibrantTableView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.11.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "VibrantTableView.h"
#import "MiddleAlignedCell.h"

@implementation VibrantTableView {
    NSTableColumn *tableColumn;
}

NSString *MAIN_COLUMN = @"MainTableColumn";

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
    
    tableColumn = [[NSTableColumn alloc] initWithIdentifier: MAIN_COLUMN];
    
    MiddleAlignedCell *middleAlignedCell = [[MiddleAlignedCell alloc] init];
    [middleAlignedCell setFont: self.requiredFont];
    
    [tableColumn setDataCell: middleAlignedCell];
    
    [self addTableColumn: tableColumn];
    
    [self setDelegate: self];
    [self setDataSource: self];
        
    return self;
}

- (void)setFrameSize:(NSSize)newSize {
    NSSize currentSize = self.frame.size;
    
    newSize.width = currentSize.width;
        
    [super setFrameSize:newSize];
}

- (CGFloat)columnWidth {
    return tableColumn.width;
}

- (void)setColumnWidth: (CGFloat)width {
    NSSize selfSize = self.frame.size;
        
    selfSize.width = width;
    
    [super setFrameSize: selfSize];
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
