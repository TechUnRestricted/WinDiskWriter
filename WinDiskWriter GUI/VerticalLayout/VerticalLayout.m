//
//  VerticalLayout.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 14.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "VerticalLayout.h"
#import "LayoutElement.h"

@interface VerticalLayout ()

@property (nonatomic, strong) NSMutableArray<LayoutElement *> *layoutElementsArray;
@property (nonatomic, strong) NSMutableArray<LayoutElement *> *sortedElementsArray;

@end

@implementation VerticalLayout

- (void)commonInit {
    self.layoutElementsArray = [[NSMutableArray alloc] init];
    self.sortedElementsArray = [[NSMutableArray alloc] init];
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
    
    LayoutElement *layoutElement = [[LayoutElement alloc] initWithNSView:nsView];
    
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
    NSUInteger low = 0;
    NSUInteger high = self.sortedElementsArray.count;

    while (low < high) {
        NSInteger mid = (low + high) / 2;
        if ([self.sortedElementsArray objectAtIndex:mid].maxWidth < value) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }

    return low;
}


- (void)appendLayoutElement:(LayoutElement *)element {
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
    
    for (NSInteger i = 0; i < elementsCount; i++) {
        LayoutElement *currentLayoutElement = [self.sortedElementsArray objectAtIndex:i];
        
        CGFloat suggestedEqualWidthForElement = remainingParentWidth / (elementsCount - i);
                
        CGFloat finalViewWidth = suggestedEqualWidthForElement;
        
        if (currentLayoutElement.minWidth > suggestedEqualWidthForElement) {
            finalViewWidth = currentLayoutElement.minWidth;
        }
        
        if (suggestedEqualWidthForElement > currentLayoutElement.maxWidth) {
            finalViewWidth = currentLayoutElement.maxWidth;
        }
        
        remainingParentWidth -= finalViewWidth;
        
        printf("Final Width: %f\n", finalViewWidth);
        printf("Remaing space: %f\n", remainingParentWidth);
        
        [currentLayoutElement setComputedSize:finalViewWidth];
        
        
        printf("");
    }
    
}

- (void)drawRect:(NSRect)dirtyRect {
    //[super drawRect:dirtyRect];
    [self updateComputedElementsWidth];
    
    printf("Drawing!\n");
    
    
    CGFloat currentXPosition = 0;
    
    /*
    for (int i = 0; i < elementsCount - 1; i++) {
        for (int j = 0; j < elementsCount - i - 1; j++) {
            if (layoutElementsArray[j].maxWidth > layoutElementsArray[j + 1].maxWidth) {
                id temp1 = layoutElementsArray[j];
                id temp2 = layoutElementsArray[j + 1];
                
                layoutElementsArray[j] = temp2;
                layoutElementsArray[j + 1] = temp1;
            }
        }
    }*/
    
    NSInteger elementsCount = self.layoutElementsArray.count;

    for (NSInteger i = 0; i < elementsCount; i++) {
        LayoutElement *currentLayoutElement = [self.layoutElementsArray objectAtIndex:i];
        
        [currentLayoutElement.nsView setFrame: CGRectMake(
                                                          // x
                                                          currentXPosition,
                                                          // y
                                                          0,
                                                          // width
                                                          currentLayoutElement.computedSize,
                                                          // height
                                                          self.frame.size.height
                                                          )
        ];
        
        currentXPosition += currentLayoutElement.computedSize;
    }
    
    printf("");
}


@end
