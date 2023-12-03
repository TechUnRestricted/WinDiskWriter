//
//  ContaineredTableView.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 02.12.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContaineredTableView : NSView

@property (strong, nonatomic, readonly) NSView *documentView;

@property (nonatomic, readwrite) CGFloat paddingTop;
@property (nonatomic, readwrite) CGFloat paddingBottom;
@property (nonatomic, readwrite) CGFloat paddingLeft;
@property (nonatomic, readwrite) CGFloat paddingRight;

- (instancetype)initWithDocumentView: (NSView *)documentView;

- (CGFloat)paddingHeight;
- (CGFloat)paddingWidth;

- (CGFloat)requiredHeight;
- (CGFloat)requiredWidth;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
