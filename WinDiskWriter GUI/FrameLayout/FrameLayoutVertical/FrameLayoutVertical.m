//
//  FrameLayoutVertical.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 09.07.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "FrameLayoutVertical.h"

@implementation FrameLayoutVertical

- (NSUInteger)sortedIndexForValue:(CGFloat)value {
    NSUInteger low = 0;
    NSUInteger high = self.sortedElementsArray.count;
    
    while (low < high) {
        NSInteger mid = (low + high) / 2;
        if ([self.sortedElementsArray objectAtIndex:mid].maxHeight < value) {
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
    
    NSUInteger requiredIndex = [self sortedIndexForValue:element.maxHeight];
    [self.sortedElementsArray insertObject:element atIndex:requiredIndex];
    
}

- (void)applyHugHeightFrameWithIndex: (NSUInteger)index
                        newViewFrame: (NSRect *)newViewFrame {
    
    NSMutableArray<FrameLayoutElement *> *parentLayoutElements = self.parentView.sortedElementsArray;
    
    CGFloat heightsSum = 0;
    for (FrameLayoutElement *currentLayoutElement in self.layoutElementsArray) {
        assert(isfinite(currentLayoutElement.maxHeight));
        
        heightsSum += currentLayoutElement.maxHeight;
    }
    
    heightsSum += [self spaceTakenBySpacing];
    
    FrameLayoutElement *selfElement = [parentLayoutElements objectAtIndex:index];
    [selfElement setMaxHeight:heightsSum];
    newViewFrame->size.height = heightsSum;
    
    [parentLayoutElements removeObjectAtIndex:index];
    
    NSUInteger requiredIndex = [self.parentView sortedIndexForValue:heightsSum];
    [parentLayoutElements insertObject:selfElement atIndex:requiredIndex];
}

- (void)applyHugWidthFrameWithIndex: (NSUInteger)index
                       newViewFrame: (NSRect *)newViewFrame {
    
    CGFloat largestWidth = 0;
    
    for (FrameLayoutElement *currentLayoutElement in self.layoutElementsArray) {
        if (isfinite(currentLayoutElement.maxWidth) && currentLayoutElement.maxWidth > largestWidth) {
            largestWidth = currentLayoutElement.maxWidth;
        }
    }
    
    NSMutableArray<FrameLayoutElement *> *parentLayoutElements = self.parentView.sortedElementsArray;
    FrameLayoutElement *selfElement = [parentLayoutElements objectAtIndex:index];

    [selfElement setMaxWidth:largestWidth];
    newViewFrame->size.width = largestWidth;
}

- (void)updateComputedElementsDimensions {    
    NSUInteger elementsCount = self.sortedElementsArray.count;
    CGFloat remainingParentHeight = self.frame.size.height;
    
    CGFloat spaceTakenBySpacing = [self spaceTakenBySpacing];
    
    remainingParentHeight -= spaceTakenBySpacing;
    
    self.viewsHeightTotal = spaceTakenBySpacing;
    self.viewsWidthTotal = spaceTakenBySpacing;
    
    for (NSInteger i = 0; i < elementsCount; i++) {
        FrameLayoutElement *currentLayoutElement = [self.sortedElementsArray objectAtIndex:i];
        
        /* [Computing view Height] */
        
        CGFloat suggestedEqualHeightForElement = remainingParentHeight / (elementsCount - i);
        
        CGFloat finalViewHeight = suggestedEqualHeightForElement;
        
        if (currentLayoutElement.minHeight > suggestedEqualHeightForElement) {
            finalViewHeight = currentLayoutElement.minHeight;
        } else if (suggestedEqualHeightForElement > currentLayoutElement.maxHeight) {
            finalViewHeight = currentLayoutElement.maxHeight;
        }
        
        remainingParentHeight -= finalViewHeight;
        
        [currentLayoutElement setComputedHeight:finalViewHeight];
        
        self.viewsHeightTotal += finalViewHeight;
        
        /* [Computing view Width]*/
        
        CGFloat finalViewWidth = self.frame.size.width;
        
        if (finalViewWidth > currentLayoutElement.maxWidth) {
            finalViewWidth = currentLayoutElement.maxWidth;
        } else if (currentLayoutElement.minWidth > finalViewWidth) {
            finalViewWidth = currentLayoutElement.minWidth;
        }
        
        [currentLayoutElement setComputedWidth:finalViewWidth];
        
        self.viewsWidthTotal += finalViewWidth;
        
        /*
        printf("[Index: %ld]\n"
               "\tcomputed_view_width: %f, self_width: %f\n"
               "\tcomputed_view_height: %f, self_height: %f\n"
               "\tsuggested_height: %f\n",
               (long)i,
               currentLayoutElement.computedWidth, self.frame.size.width,
               currentLayoutElement.computedHeight, self.frame.size.height,
               suggestedEqualHeightForElement
        );
        */
    }
    
}

- (void)changeFramePropertiesWithLastXPosition: (CGFloat *)lastXPosition
                                 lastYPosition: (CGFloat *)lastYPosition
                                     viewFrame: (CGRect *)viewFrame
                                   currentView: (FrameLayoutElement *)currentView
                                        isLast: (BOOL)isLast {
    /*
     Horizontal Alignment
     */
    
    CGFloat layoutWidth = self.frame.size.width;
    
    switch(self.horizontalAlignment) {
        case FrameLayoutHorizontalLeft:
            *lastXPosition = 0;
            break;
        case FrameLayoutHorizontalRight:
            *lastXPosition = layoutWidth - currentView.computedWidth;
            break;
        case FrameLayoutHorizontalCenter:
            *lastXPosition = (layoutWidth - currentView.computedWidth) / 2;
            break;
    }
    
    viewFrame->origin.x = *lastXPosition;
    
    /*
     Vertical Alignment
     */
    
    CGFloat layoutHeight = self.frame.size.height;
    NSInteger elementsCount = self.layoutElementsArray.count;
    
    if (isnan(*lastYPosition)) {
        switch(self.verticalAlignment) {
            case FrameLayoutVerticalTop:
                *lastYPosition = 0;
                break;
            case FrameLayoutVerticalBottom:
                *lastYPosition = layoutHeight;
                break;
            case FrameLayoutVerticalCenter:
                *lastYPosition = (layoutHeight - self.viewsHeightTotal) / 2;
                break;
        }
    }
    
    switch(self.verticalAlignment) {
        case FrameLayoutVerticalTop:
            viewFrame->origin.y = *lastYPosition;
            *lastYPosition += currentView.computedHeight;
            break;
        case FrameLayoutVerticalBottom:
            viewFrame->origin.y = *lastYPosition - currentView.computedHeight;
            *lastYPosition -= currentView.computedHeight;
            break;
        case FrameLayoutVerticalCenter:
            viewFrame->origin.y = *lastYPosition;
            *lastYPosition += currentView.computedHeight;
            break;
    }
    
    if (!isLast && elementsCount > 1) {
        switch(self.verticalAlignment) {
            case FrameLayoutVerticalCenter:
            case FrameLayoutVerticalTop:
                *lastYPosition += self.spacing;
                break;
            case FrameLayoutVerticalBottom:
                *lastYPosition -= self.spacing;
                break;
        }
    }
    
    viewFrame->size.width = currentView.computedWidth;
    viewFrame->size.height = currentView.computedHeight;
}


@end
