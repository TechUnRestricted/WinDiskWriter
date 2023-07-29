//
//  FrameLayoutHorizontal.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 03.07.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "FrameLayoutHorizontal.h"
#import "FrameLayoutVertical.h"

@implementation FrameLayoutHorizontal

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

- (void)appendLayoutElement:(FrameLayoutElement *)element {
    
    [self.layoutElementsArray addObject:element];
    
    if (self.sortedElementsArray.count == 0) {
        [self.sortedElementsArray addObject:element];
        return;
    }
    
    NSUInteger requiredIndex = [self sortedIndexForValue:element.maxWidth];
    [self.sortedElementsArray insertObject:element atIndex:requiredIndex];
    
}

- (void)addView: (NSView *)nsView
       minWidth: (CGFloat)minWidth
       maxWidth: (CGFloat)maxWidth
      minHeight: (CGFloat)minHeight
      maxHeight: (CGFloat)maxHeight {
    
    [super addView: nsView
          minWidth: minWidth
          maxWidth: maxWidth
         minHeight: minHeight
         maxHeight: maxHeight];
    
    [self applyHugFrames];
}

- (void)applyHugHeightFrameWithIndex: (NSUInteger)index
                        newViewFrame: (NSRect *)newViewFrame {

    CGFloat largestHeight = CGFLOAT_MIN;
    
    for (FrameLayoutElement *currentLayoutElement in self.layoutElementsArray) {
        assert(isfinite(currentLayoutElement.maxHeight));
        
        if (currentLayoutElement.maxHeight > largestHeight) {
            largestHeight = currentLayoutElement.maxHeight;
        }
    }
    
    NSMutableArray<FrameLayoutElement *> *parentLayoutElements = self.parentView.sortedElementsArray;
    FrameLayoutElement *selfElement = [parentLayoutElements objectAtIndex:index];

    [selfElement setMaxHeight:largestHeight];
    newViewFrame->size.height = largestHeight;
        
    if ([self.parentView isKindOfClass:FrameLayoutVertical.class]) {
        [parentLayoutElements removeObjectAtIndex:index];
        
        NSUInteger requiredIndex = [self.parentView sortedIndexForValue:largestHeight];
        [parentLayoutElements insertObject:selfElement atIndex:requiredIndex];
    }
}

- (void)applyHugWidthFrameWithIndex: (NSUInteger)index
                       newViewFrame: (NSRect *)newViewFrame {
    
    NSMutableArray<FrameLayoutElement *> *parentLayoutElements = self.parentView.sortedElementsArray;
    
    CGFloat widthsSum = 0;
    for (FrameLayoutElement *currentLayoutElement in self.layoutElementsArray) {
        assert(isfinite(currentLayoutElement.maxWidth));
        
        widthsSum += currentLayoutElement.maxWidth;
    }
    
    widthsSum += [self spaceTakenBySpacing];
    
    FrameLayoutElement *selfElement = [parentLayoutElements objectAtIndex:index];
    [selfElement setMaxWidth:widthsSum];
    newViewFrame->size.width = widthsSum;
    
    if ([self.parentView isKindOfClass:FrameLayoutHorizontal.class]) {
        [parentLayoutElements removeObjectAtIndex:index];
        
        NSUInteger requiredIndex = [self.parentView sortedIndexForValue:widthsSum];
        [parentLayoutElements insertObject:selfElement atIndex:requiredIndex];
    }
}

- (void)updateComputedElementsDimensions {

    NSUInteger elementsCount = self.sortedElementsArray.count;
    CGFloat remainingParentWidth = self.frame.size.width;
    
    CGFloat spaceTakenBySpacing = [self spaceTakenBySpacing];
    
    remainingParentWidth -= spaceTakenBySpacing;
    
    self.viewsWidthTotal = spaceTakenBySpacing;
    self.viewsHeightTotal = spaceTakenBySpacing;
    
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
    
        [currentLayoutElement setComputedWidth:finalViewWidth];
        
        self.viewsWidthTotal += finalViewWidth;
        
        /* [Computing view Height]*/
        
        CGFloat finalViewHeight = self.frame.size.height;
        
        if (finalViewHeight > currentLayoutElement.maxHeight) {
            finalViewHeight = currentLayoutElement.maxHeight;
        } else if (currentLayoutElement.minHeight > finalViewHeight) {
            finalViewHeight = currentLayoutElement.minHeight;
        }
                
        [currentLayoutElement setComputedHeight:finalViewHeight];
        
        self.viewsHeightTotal += finalViewHeight;
    }
    
}

- (void)changeFramePropertiesWithLastXPosition: (CGFloat *)lastXPosition
                                 lastYPosition: (CGFloat *)lastYPosition
                                     viewFrame: (CGRect *)viewFrame
                                   currentView: (FrameLayoutElement *)currentView
                                        isLast: (BOOL)isLast {
    
    /*
     Vertical Alignment
     */
    
    CGFloat layoutHeight = self.frame.size.height;
    
    switch(self.verticalAlignment) {
        case FrameLayoutVerticalTop:
            *lastYPosition = 0;
            break;
        case FrameLayoutVerticalBottom:
            *lastYPosition = layoutHeight - currentView.computedHeight;
            break;
        case FrameLayoutVerticalCenter:
            *lastYPosition = (layoutHeight - currentView.computedHeight) / 2;
            break;
    }
    
    viewFrame->origin.y = *lastYPosition;
    
    /*
     Horizontal Alignment
     */
    
    CGFloat layoutWidth = self.frame.size.width;
    NSInteger elementsCount = self.layoutElementsArray.count;
    
    if (isnan(*lastXPosition)) {
        switch(self.horizontalAlignment) {
            case FrameLayoutHorizontalLeft:
                *lastXPosition = 0;
                break;
            case FrameLayoutHorizontalRight:
                *lastXPosition = layoutWidth;
                break;
            case FrameLayoutHorizontalCenter:
                *lastXPosition = (layoutWidth - self.viewsWidthTotal) / 2;
                break;
        }
    }
    
    switch(self.horizontalAlignment) {
        case FrameLayoutHorizontalLeft:
            viewFrame->origin.x = *lastXPosition;
            *lastXPosition += currentView.computedWidth;
            break;
        case FrameLayoutHorizontalRight:
            viewFrame->origin.x = *lastXPosition - currentView.computedWidth;
            *lastXPosition -= currentView.computedWidth;
            break;
        case FrameLayoutHorizontalCenter:
            viewFrame->origin.x = *lastXPosition;
            *lastXPosition += currentView.computedWidth;
            break;
    }
    
    if (!isLast && elementsCount > 1) {
        switch(self.horizontalAlignment) {
            case FrameLayoutHorizontalCenter:
            case FrameLayoutHorizontalLeft:
                *lastXPosition += self.spacing;
                break;
            case FrameLayoutHorizontalRight:
                *lastXPosition -= self.spacing;
                break;

        }
    }
    
    viewFrame->size.width = currentView.computedWidth;
    viewFrame->size.height = currentView.computedHeight;
}

@end
