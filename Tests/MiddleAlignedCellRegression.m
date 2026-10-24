#import <Cocoa/Cocoa.h>
#import "MiddleAlignedCell.h"

@interface LogRows : NSObject <NSTableViewDataSource>
@end
@implementation LogRows
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView { return 3; }
- (id)tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row {
    return @[@"[Start] Preparing Windows installer", @"[Log] Copying setup files",
             @"[Success] Finished copying"][(NSUInteger)row];
}
@end

int main(void) {
    @autoreleasepool {
        @try {
            [NSApplication sharedApplication];
            // LogView attaches this cell to a text field; font/string updates
            // exercise AppKit's text-cell hooks, including those added in Tahoe.
            NSTextField *field = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 500, 30)];
            [field setCell:[[MiddleAlignedCell alloc] init]];
            [field setFont:[NSFont systemFontOfSize:13]];
            [field setStringValue:@"[Start] Preparing Windows installer"];
            [field setAttributedStringValue:[[NSAttributedString alloc]
                initWithString:@"[Success] Finished copying"
                attributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:13]}]];
            NSSize measured = field.cell.cellSize;
            if (measured.width <= 0 || measured.height <= 0) return 2;

            // Exercise the cell-based log table's value, font, sizing and drawing.
            NSTableView *table = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 500, 100)];
            NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"log"];
            column.width = 500;
            MiddleAlignedCell *cell = [[MiddleAlignedCell alloc] init];
            cell.font = [NSFont systemFontOfSize:13];
            column.dataCell = cell;
            [table addTableColumn:column];
            LogRows *rows = [[LogRows alloc] init];
            table.dataSource = rows;
            [table reloadData];
            NSCell *rowCell = [table preparedCellAtColumn:0 row:0];
            if (![rowCell.stringValue containsString:@"Preparing Windows installer"]) return 3;
            NSBitmapImageRep *bitmap = [table bitmapImageRepForCachingDisplayInRect:table.bounds];
            [table cacheDisplayInRect:table.bounds toBitmapImageRep:bitmap];
            if (table.numberOfRows != 3 || bitmap == nil) return 4;
            puts("PASS: log text updates and cell-based table rendering");
            return 0;
        } @catch (NSException *exception) {
            fprintf(stderr, "FAIL: %s: %s\n", exception.name.UTF8String,
                    exception.reason.UTF8String);
            return 1;
        }
    }
}
