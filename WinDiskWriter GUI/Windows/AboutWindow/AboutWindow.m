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
#import "AdvancedTextView.h"

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
    NSView *spacerView = [[NSView alloc] init];
    
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
                NSAttributedString *attributedStringResult = [NSMutableAttributedString attributedStringWithString: APPLICATION_NAME
                                                                                                            weight: 4
                                                                                                              size: NSFont.systemFontSize * 1.5];
                
                [applicationNameLabelView setAttributedStringValue:attributedStringResult];
                
                [textHolderVerticalLayout addView:applicationNameLabelView
                                            width: applicationNameLabelView.cell.cellSize.width
                                           height: applicationNameLabelView.cell.cellSize.height];
            }
            
            LabelView *applicationVersionLabelView = [[LabelView alloc] init]; {
                
                NSAttributedString *attributedStringResult = [NSMutableAttributedString attributedStringWithString: [NSString stringWithFormat:@"Version: (%@)", PACKAGE_VERSION]
                                                                                                            weight: 3
                                                                                                              size: NSFont.systemFontSize];
                
                [applicationVersionLabelView setAttributedStringValue:attributedStringResult];
                
                [textHolderVerticalLayout addView:applicationVersionLabelView
                                            width: applicationVersionLabelView.cell.cellSize.width
                                           height: applicationVersionLabelView.cell.cellSize.height];
            }
            
        }
        
        [mainVerticalLayout addView:spacerView width:0 height:14];
        
        FrameLayoutVertical *openSourceLicensesVerticalLayout = [[FrameLayoutVertical alloc] init]; {
            [mainVerticalLayout addView:openSourceLicensesVerticalLayout width:INFINITY height:INFINITY];
            
            //[openSourceLicensesVerticalLayout setHugHeightFrame: YES];
            
            [openSourceLicensesVerticalLayout setSpacing: 8];
            
            LabelView *openSourceLicensesLabelView = [[LabelView alloc] init]; {
                NSAttributedString *attributedStringResult = [NSMutableAttributedString attributedStringWithString: [NSString stringWithFormat:@"Additional Information"]
                                                                                                            weight: 6
                                                                                                              size: NSFont.systemFontSize];
                
                [openSourceLicensesLabelView setAttributedStringValue:attributedStringResult];
                
                [openSourceLicensesVerticalLayout addView:openSourceLicensesLabelView
                                                    width: openSourceLicensesLabelView.cell.cellSize.width
                                                   height: openSourceLicensesLabelView.cell.cellSize.height];
            }
            
            AdvancedTextView *openSourceLicensesAdvancedTextView = [[AdvancedTextView alloc] init]; {
                [openSourceLicensesAdvancedTextView appendLine:
                 @"WinDiskWriter is an application for macOS that enables users to create bootable flash drives with the Windows operating system, which belongs to Microsoft Corporation." "\n\n"
                 "The application is an Open Source product developed by TechUnRestricted." "\n"
                 
                 "It relies on the wimlib library, which is licensed under the GNU LESSER GENERAL PUBLIC LICENSE Version 3." "\n\n"
                 "The library has been slightly modified to avoid application crashes caused by assertions." "\n"
                 "This allowed the integration of wimlib as a part of the project, instead of a separate binary file that is invoked through the console." "\n\n"
                 
                 "The application is written in Objective-C programming language, with backward compatibility for older operating systems." "\n"
                 "This is achieved by using legacy code and custom solutions, instead of reinventing the wheel." "\n"
                 "The user interface and the logic of element placement are coded manually, without using xib and storyboards." "\n\n"
                 
                 "This software has two versions: GUI and CLI." "\n"
                 "At the moment, WinDiskWriter supports writing Windows Vista, 7, 8, 8.1, 10 and 11 in UEFI mode." "\n"
                 "Future improvements will include support for Legacy systems and other features." "\n\n\n"
                 
                 "[WIMLIB: GNU LESSER GENERAL PUBLIC LICENSE Version 3]" "\n"
                 
                ];
                

                
                [openSourceLicensesVerticalLayout addView: openSourceLicensesAdvancedTextView
                                                 minWidth: 0
                                                 maxWidth: INFINITY
                                                minHeight: 100
                                                maxHeight: INFINITY];
                
            }
            
        }
        
        [mainVerticalLayout addView:spacerView width:0 height:8];
        
        LabelView *developerNameLabelView = [[LabelView alloc] init]; {
            [developerNameLabelView setStringValue: DEVELOPER_NAME];
            
            [mainVerticalLayout addView: developerNameLabelView
                                  width: developerNameLabelView.cell.cellSize.width
                                 height: developerNameLabelView.cell.cellSize.height];
        }
        
        
    }
    
    
    
}

@end
