//
//  VibrantTableView.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.11.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface VibrantTableView : NSTableView <NSTableViewDelegate, NSTableViewDataSource>

@property (strong, nonatomic, readonly) NSMutableArray *rowData;
@property (strong, nonatomic, readonly) NSFont *requiredFont;

- (CGFloat)columnWidth;
- (void)setColumnWidth: (CGFloat)width;

@end

NS_ASSUME_NONNULL_END
