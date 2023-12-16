//
//  VibrantTableView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.11.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "VibrantTableView.h"
#import "MiddleAlignedCell.h"
#import "Constants.h"
#import "LocalizedStrings.h"

@implementation VibrantTableView {
    NSTableColumn *tableColumn;
    NSMenuItem *contextMenuCopyItem;
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
    
    // Create a menu object and add a menu item for copy
    NSMenu *menu = [[NSMenu alloc] init];
    contextMenuCopyItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings menuTitleItemCopy]
                                                     action: NULL
                                              keyEquivalent: @"c"];
    
    [menu addItem: contextMenuCopyItem];
    
    [self setMenu: menu];
    
    return self;
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent {
    NSMenu *menu = [super menuForEvent: theEvent];
    
    NSInteger selectedRowCount = [self numberOfSelectedRows];
    
    if (selectedRowCount > 0 || selectedRowCount != -1) {
        [contextMenuCopyItem setAction: @selector(copy:)];
    } else {
        [contextMenuCopyItem setAction: NULL];
    }

    return menu;
}

- (void)setFrameSize:(NSSize)newSize {
    NSSize currentSize = self.frame.size;
    
    newSize.width = currentSize.width;
    
    [super setFrameSize:newSize];
}

- (void)copy:(id)sender {
    NSIndexSet *selectedRows = [self selectedRowIndexes];
    NSInteger selectedRowCount = [selectedRows count];
    
    NSInteger clickedRow = [self clickedRow];
    NSMutableString *copiedString = [NSMutableString string];
    
    // If there are selected rows, iterate over them and append them to the copied string
    if (selectedRowCount > 0) {
        [selectedRows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *rowLine = [self.rowData objectAtIndex:idx];
            [copiedString appendFormat:@"%@\n", rowLine];
            
        }];
    } else {
        // If there are no selected rows, but the user clicked on a valid row, append that row to the copied string
        if (clickedRow != -1) {
            NSString *rowLine = [self.rowData objectAtIndex:clickedRow];
            [copiedString appendFormat:@"%@\n", rowLine];
        }
    }
    
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    
    [pasteboard setString: copiedString
                  forType: NSPasteboardTypeString];
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
