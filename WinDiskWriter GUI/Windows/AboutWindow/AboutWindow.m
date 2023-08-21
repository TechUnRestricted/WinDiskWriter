//
//  AboutWindow.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 21.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "AboutWindow.h"
#import "FrameLayout.h"
#import "LabelView.h"
#import "Constants.h"
#import "CustomImageView.h"
#import "NSMutableAttributedString+Common.h"

@implementation AboutWindow

- (instancetype)initWithNSRect: (NSRect)nsRect
                         title: (NSString *)title
                       padding: (CGFloat)padding {
    self = [super initWithNSRect: nsRect
                           title: title
                         padding: padding];
    
    NSButton *windowZoomButton = [self standardWindowButton:NSWindowZoomButton];
    [windowZoomButton setEnabled: NO];
    
    NSButton *minimizeZoomButton = [self standardWindowButton:NSWindowMiniaturizeButton];
    [minimizeZoomButton setEnabled: NO];
    
    [self setupViews];
    
    return self;
}

- (void)setupViews {
    FrameLayoutVertical *mainVerticalLayout = (FrameLayoutVertical *)self.containerView;
    
    [mainVerticalLayout setHorizontalAlignment: FrameLayoutHorizontalCenter];
    
    FrameLayoutVertical *pictureHolderVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:pictureHolderVerticalLayout width:INFINITY height:0];
        
        [pictureHolderVerticalLayout setHorizontalAlignment: FrameLayoutHorizontalCenter];
        
        [pictureHolderVerticalLayout setHugHeightFrame: YES];
        
        [pictureHolderVerticalLayout setSpacing: 8];
        
        CustomImageView *customImageView = [[CustomImageView alloc] init]; {
            [customImageView setImage: NSApp.applicationIconImage];
            [customImageView setImageScaling: NSScaleProportionally];
            CGFloat minSize = 100;
            CGFloat maxSize = 120;

            [pictureHolderVerticalLayout addView: customImageView
                                        minWidth: minSize
                                        maxWidth: maxSize
                                       minHeight: minSize
                                       maxHeight: maxSize];
        }
        
        
        FrameLayoutVertical *textHolderVerticalLayout = [[FrameLayoutVertical alloc] init]; {
            [pictureHolderVerticalLayout addView:textHolderVerticalLayout width:INFINITY height:0];
            
            [textHolderVerticalLayout setHorizontalAlignment: FrameLayoutHorizontalCenter];
            
            [textHolderVerticalLayout setHugHeightFrame: YES];
            
            [textHolderVerticalLayout setSpacing: 2];
            
            LabelView *applicationNameLabelView = [[LabelView alloc] init]; {
                [applicationNameLabelView setStringValue: APPLICATION_NAME];
                
                NSAttributedString *attributedStringResult = [NSMutableAttributedString attributedStringWithString: APPLICATION_NAME
                                                                                                            weight: 4
                                                                                                              size: NSFont.systemFontSize + 6];
                
                [applicationNameLabelView setAttributedStringValue:attributedStringResult];
                
                [textHolderVerticalLayout addView:applicationNameLabelView
                                            width: applicationNameLabelView.cell.cellSize.width
                                           height: applicationNameLabelView.cell.cellSize.height];
            }
        }
        
        
    }
    
    
    
}

@end
