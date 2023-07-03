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

- (void)commonInit {
    self.layoutElementsArray = [[NSMutableArray alloc] init];
    self.sortedElementsArray = [[NSMutableArray alloc] init];
    _spacing = 0;
    _verticalAlignment = FrameLayoutVerticalCenter;
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

- (void)addView: (NSView * _Nonnull)nsView {
    [self addView: nsView
         minWidth: 0
         maxWidth: INFINITY
        minHeight: 0
        maxHeight: INFINITY];
}

- (void)addView: (NSView * _Nonnull)nsView
       minWidth: (CGFloat)minWidth
       maxWidth: (CGFloat)maxWidth
      minHeight: (CGFloat)minHeight
      maxHeight: (CGFloat)maxHeight {
    
    assert(maxWidth >= minWidth);
    assert(maxHeight >= minHeight);
    
    FrameLayoutElement *layoutElement = [[FrameLayoutElement alloc] initWithNSView:nsView];
    
    [layoutElement setMinWidth:minWidth];
    [layoutElement setMaxWidth:maxWidth];
    
    [layoutElement setMinHeight:minWidth];
    [layoutElement setMaxHeight:maxHeight];
    
    [self appendLayoutElement:layoutElement];

    assert(self.layoutElementsArray.count == self.sortedElementsArray.count);
    
    [self addSubview: layoutElement.nsView];
}

- (void)addView: (NSView * _Nonnull)nsView
          width: (CGFloat)width
         height: (CGFloat)height {
    
    [self addView: nsView
         minWidth: width
         maxWidth: width
        minHeight: height
        maxHeight: height];
}

- (NSUInteger)sortedIndexForValue:(CGFloat)value {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
    return 0;
}


- (void)appendLayoutElement:(FrameLayoutElement *)element {
    [self.layoutElementsArray addObject:element];
    
    if (self.sortedElementsArray.count == 0) {
        [self.sortedElementsArray addObject:element];
        return;
    }

    NSUInteger requiredIndex = [self sortedIndexForValue:element.maxWidth];
    [self.sortedElementsArray insertObject:element atIndex:requiredIndex];
    
    printf("Inserted at index: %lud, ElementMaxWidth: %f\n", (unsigned long)requiredIndex, element.maxWidth);
}

- (void)updateComputedElementsWidth {
    NSUInteger elementsCount = self.sortedElementsArray.count;
    CGFloat remainingParentWidth = self.frame.size.width;

    if (elementsCount > 1) {
        remainingParentWidth -= _spacing * (elementsCount - 1);
    }
    
    for (NSInteger i = 0; i < elementsCount; i++) {
        FrameLayoutElement *currentLayoutElement = [self.sortedElementsArray objectAtIndex:i];
        
        /* [Computing view Width] */
        
        CGFloat suggestedEqualWidthForElement = remainingParentWidth / (elementsCount - i);
                
        CGFloat finalViewWidth = suggestedEqualWidthForElement;
        
        if (currentLayoutElement.minWidth > suggestedEqualWidthForElement) {
            finalViewWidth = currentLayoutElement.minWidth;
        } else if (suggestedEqualWidthForElement > currentLayoutElement.maxWidth) {
            finalViewWidth = currentLayoutElement.maxWidth;
        }
        
        remainingParentWidth -= finalViewWidth;
        
        printf("Final Width: %f\n", finalViewWidth);
        printf("Remaing horizontal space: %f\n", remainingParentWidth);
        
        [currentLayoutElement setComputedWidth:finalViewWidth];
        
        /* [Computing view Height]*/
        
        CGFloat finalViewHeight = self.frame.size.height;
        
        if (finalViewHeight > currentLayoutElement.maxHeight) {
            finalViewHeight = currentLayoutElement.maxHeight;
        } else if (currentLayoutElement.minHeight > finalViewWidth) {
            finalViewHeight = currentLayoutElement.minHeight;
        }
        
        printf("Final Height: %f\n", finalViewHeight);

        [currentLayoutElement setComputedHeight:finalViewHeight];        
    }
    
}

- (BOOL)isFlipped {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    //[super drawRect:dirtyRect];
    [self updateComputedElementsWidth];
    
    printf("Drawing!\n");
    
    CGFloat currentXPosition = 0;
    
    NSInteger elementsCount = self.layoutElementsArray.count;

    CGFloat layoutHeight = self.frame.size.height;
    
    for (NSInteger i = 0; i < elementsCount; i++) {
        FrameLayoutElement *currentLayoutElement = [self.layoutElementsArray objectAtIndex:i];
        
        CGFloat currentYPosition;
        
        switch(self.verticalAlignment) {
            case FrameLayoutVerticalTop:
                currentYPosition = 0;
                break;
            case FrameLayoutVerticalBottom:
                currentYPosition = layoutHeight - currentLayoutElement.computedHeight;
                break;
            case FrameLayoutVerticalCenter:
                currentYPosition = (layoutHeight - currentLayoutElement.computedHeight) / 2;
                break;
        }
        
        if (currentYPosition < 0 || currentYPosition > layoutHeight) {
            printf("[BIBOOOP!!!]\n");
            currentYPosition = 0;
            
            // Temp fatal crash
            
            exit(69);
        }
        
        [currentLayoutElement.nsView setFrame: CGRectMake(
                                                          // x
                                                          currentXPosition,
                                                          // y
                                                          currentYPosition,
                                                          // width
                                                          currentLayoutElement.computedWidth,
                                                          // height
                                                          currentLayoutElement.computedHeight
                                                          )
        ];
        
        currentXPosition += currentLayoutElement.computedWidth;
        
        if (i < elementsCount - 1 && elementsCount > 1) {
            currentXPosition += self.spacing;
        }
    }
    
    printf("");
}


@end
