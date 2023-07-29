//
//  FrameLayoutBase.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 14.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "FrameLayoutBase.h"
#import "FrameLayoutElement.h"

@interface FrameLayoutBase ()

@end

@implementation FrameLayoutBase

NSString * const overrideMethodString = @"You must override %@ in a subclass";

- (void)commonInit {
    self.layoutElementsArray = [[NSMutableArray alloc] init];
    self.sortedElementsArray = [[NSMutableArray alloc] init];
    
    _spacing = 0;
    _viewsWidthTotal = 0;
    _viewsHeightTotal = 0;
    
    _hugWidthFrame = NO;
    _hugHeightFrame = NO;
    
    // _stackableAxisMaxLimitsSum = 0;
    // _largestUnstackableAxisValue = 0;
    
    _verticalAlignment = FrameLayoutVerticalTop;
    _horizontalAlignment = FrameLayoutHorizontalLeft;
}

- (instancetype)init {
    self = [super init];
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    [self commonInit];
    
    return self;
}

- (void)setSpacing:(CGFloat)padding {
    _spacing = padding;
    
    [self setNeedsDisplay: YES];
}

- (void)setVerticalAlignment:(FrameLayoutVerticalAlignment)verticalAlignment {
    _verticalAlignment = verticalAlignment;
    
    [self setNeedsDisplay: YES];
}

- (void)setHorizontalAlignment:(FrameLayoutHorizontalAlignment)horizontalAlignment {
    _horizontalAlignment = horizontalAlignment;
    
    [self setNeedsDisplay: YES];
}

- (void)setHugWidthFrame:(BOOL)hugWidthFrame {
    _hugWidthFrame = hugWidthFrame;
    
    [self applyHugFrames];
    
    [self setNeedsDisplay: YES];
}

- (void)setHugHeightFrame:(BOOL)hugHeightFrame {
    _hugHeightFrame = hugHeightFrame;
    
    [self applyHugFrames];
    
    [self setNeedsDisplay: YES];
}

- (CGFloat)spaceTakenBySpacing {
    NSUInteger elementsCount = self.sortedElementsArray.count;
    
    if (elementsCount <= 1) {
        return 0;
    }
    
    return self.spacing * (elementsCount - 1);
}

- (void)applyHugHeightFrameWithIndex: (NSUInteger)index
                        newViewFrame: (NSRect *)newViewFrame {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:overrideMethodString, NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
}

- (void)applyHugWidthFrameWithIndex: (NSUInteger)index
                       newViewFrame: (NSRect *)newViewFrame {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:overrideMethodString, NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
}

- (NSUInteger)sortedIndexInParentView {
    if (self.parentView == NULL) {
        return NSNotFound;
    }
    
    NSMutableArray<FrameLayoutElement *> *parentLayoutElements = self.parentView.sortedElementsArray;

    for (NSUInteger i = 0; i < parentLayoutElements.count; i++) {
        FrameLayoutElement *currentLayoutElement = [parentLayoutElements objectAtIndex:i];
        
        if (self != currentLayoutElement.nsView) {
            continue;
        }
        
        return i;
    }
    
    return NSNotFound;
}

- (void)applyHugFrames {
    NSUInteger indexInSortedArray = [self sortedIndexInParentView];
    NSRect newViewFrame = self.frame;
    
    if (indexInSortedArray == NSNotFound) {
        return;
    }
    
    if (self.hugHeightFrame) {
        [self applyHugHeightFrameWithIndex: indexInSortedArray
                              newViewFrame: &newViewFrame];
    }
    
    if (self.hugWidthFrame) {
        [self applyHugWidthFrameWithIndex: indexInSortedArray
                             newViewFrame: &newViewFrame];
    }
    
    [self setFrame:newViewFrame];
    
    [self.parentView applyHugFrames];
}

- (void)addView: (NSView * _Nonnull)nsView {
    [self addView: nsView
         minWidth: 0
         maxWidth: 0 // INFINITY
        minHeight: 0
        maxHeight: 0 // INFINITY
    ];
}

- (void)addView: (NSView * _Nonnull)nsView
       minWidth: (CGFloat)minWidth
       maxWidth: (CGFloat)maxWidth
      minHeight: (CGFloat)minHeight
      maxHeight: (CGFloat)maxHeight {

    assert(isfinite(minWidth));
    assert(isfinite(minHeight));
    
    assert(maxWidth >= minWidth);
    assert(maxHeight >= minHeight);
    
    assert(minHeight >= 0);
    assert(maxHeight >= 0);
    
    assert(minWidth >= 0);
    assert(maxWidth >= 0);
    
    /*
    if (self.hugHeightFrame) {
        assert(isfinite(maxHeight));
    }
    
    if (self.hugWidthFrame) {
        assert(isfinite(maxWidth));
    }
    */
    
    FrameLayoutElement *layoutElement = [[FrameLayoutElement alloc] initWithNSView:nsView];
    
    if ([nsView isKindOfClass: FrameLayoutBase.class]) {
        [(FrameLayoutBase *)nsView setParentView:self];
    }
    
    [layoutElement setMinWidth:minWidth];
    [layoutElement setMaxWidth:maxWidth];
    
    [layoutElement setMinHeight:minHeight];
    [layoutElement setMaxHeight:maxHeight];
    
    [self appendLayoutElement:layoutElement];
        
    assert(self.layoutElementsArray.count == self.sortedElementsArray.count);
    
    [self addSubview: layoutElement.nsView];
}

- (void)addView: (NSView * _Nonnull)nsView
          width: (CGFloat)width
         height: (CGFloat)height {
    
    [self addView: nsView
         minWidth: isinf(width) ? 0 : width
         maxWidth: width
        minHeight: isinf(height) ? 0 : height
        maxHeight: height];
}

- (NSUInteger)sortedIndexForValue:(CGFloat)value {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:overrideMethodString, NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
    return 0;
}


- (void)appendLayoutElement:(FrameLayoutElement *)element {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:overrideMethodString, NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
}

- (void)updateComputedElementsDimensions {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:overrideMethodString, NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
}

- (BOOL)isFlipped {
    return YES;
}

- (void)changeFramePropertiesWithLastXPosition: (CGFloat *)lastXPosition
                                 lastYPosition: (CGFloat *)lastYPosition
                                     viewFrame: (CGRect *)viewFrame
                                   currentView: (FrameLayoutElement *)currentView
                                        isLast: (BOOL)isLast {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:overrideMethodString, NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
}

- (void)drawRect:(NSRect)dirtyRect {
    //[super drawRect:dirtyRect];
    [self updateComputedElementsDimensions];
        
    NSInteger elementsCount = self.layoutElementsArray.count;
    
    CGFloat lastYPosition = NAN;
    CGFloat lastXPosition = NAN;
    
    for (NSInteger i = 0; i < elementsCount; i++) {
        FrameLayoutElement *currentLayoutElement = [self.layoutElementsArray objectAtIndex:i];
                
        CGRect viewFrame = CGRectZero;
        
        BOOL isLastElement = !(i < elementsCount - 1);
        
        [self changeFramePropertiesWithLastXPosition: &lastXPosition
                                       lastYPosition: &lastYPosition
                                           viewFrame: &viewFrame
                                         currentView: currentLayoutElement
                                              isLast: isLastElement];
        
        [currentLayoutElement.nsView setFrame:viewFrame];
    }
}


@end
