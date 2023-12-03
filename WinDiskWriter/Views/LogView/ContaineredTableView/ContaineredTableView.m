//
//  ContaineredTableView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 02.12.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "ContaineredTableView.h"

@implementation ContaineredTableView

- (instancetype)initWithDocumentView: (NSView *)documentView {
    self = [super init];
    
    _documentView = documentView;
    
    [self setAutoresizesSubviews: NO];

    [self addSubview: self.documentView];
    
    
    [self.documentView setPostsFrameChangedNotifications: YES];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(documentViewFrameDidChange:)
                                                 name: NSViewFrameDidChangeNotification
                                               object: self.documentView];
    
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (self.documentView == NULL) {
        return;
    }
    
}

- (void)documentViewFrameDidChange:(NSNotification *)notification {
    if (self.superview == NULL) {
        return;
    }
    
    NSRect selfFrame = self.frame;
    NSRect documentViewFrame = self.documentView.frame;
    
    documentViewFrame.origin.y = self.paddingTop;
    documentViewFrame.origin.x = self.paddingLeft;
    [self.documentView setFrame:documentViewFrame];
    
    selfFrame.size.height = documentViewFrame.size.height + [self paddingHeight];
    selfFrame.size.width = documentViewFrame.size.width + [self paddingWidth];
    [self setFrame:selfFrame];
}

- (void)setPaddingTop:(CGFloat)paddingTop {
    _paddingTop = paddingTop;
    
    [self setNeedsDisplay: YES];
}

- (void)setPaddingBottom:(CGFloat)paddingBottom {
    _paddingBottom = paddingBottom;
    
    [self setNeedsDisplay: YES];
}

- (void)setPaddingLeft:(CGFloat)paddingLeft {
    _paddingLeft = paddingLeft;
    
    [self setNeedsDisplay: YES];
}

- (void)setPaddingRight:(CGFloat)paddingRight {
    _paddingRight = paddingRight;
    
    [self setNeedsDisplay: YES];
}

- (CGFloat)paddingHeight {
    return self.paddingTop + self.paddingBottom;
}

- (CGFloat)paddingWidth {
    return self.paddingLeft + self.paddingRight;
}

- (CGFloat)requiredHeight {
    if (self.documentView == NULL) {
        return [self paddingHeight];
    }
    
    CGFloat documentViewHeight = self.documentView.frame.size.height;
    
    return [self paddingHeight] + documentViewHeight;
}

- (CGFloat)requiredWidth {
    if (self.documentView == NULL) {
        return [self paddingWidth];
    }
    
    CGFloat documentViewWidth = self.documentView.frame.size.width;
    
    return [self paddingWidth] + documentViewWidth;
}

@end
