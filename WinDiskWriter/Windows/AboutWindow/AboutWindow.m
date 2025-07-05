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
#import "ButtonView.h"
#import "Constants.h"
#import "CustomImageView.h"
#import "NSMutableAttributedString+Common.h"
#import "AdvancedTextView.h"
#import "Licenses-Constants.h"
#import "HelperFunctions.h"
#import "LocalizedStrings.h"

@implementation AboutWindow

- (instancetype)initWithNSRect: (NSRect)nsRect
                         title: (NSString *)title
                       padding: (CGFloat)padding
        paddingIsTitleBarAware: (BOOL)paddingIsTitleBarAware{
    self = [super initWithNSRect: nsRect
                           title: title
                         padding: padding
          paddingIsTitleBarAware: paddingIsTitleBarAware];
    
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
                NSAttributedString *attributedStringResult = [NSMutableAttributedString attributedStringWithString: [Constants applicationName]
                                                                                                            weight: 4
                                                                                                              size: NSFont.systemFontSize * 1.5];
                
                [applicationNameLabelView setAttributedStringValue:attributedStringResult];
                
                [textHolderVerticalLayout addView:applicationNameLabelView
                                            width: applicationNameLabelView.cell.cellSize.width
                                           height: applicationNameLabelView.cell.cellSize.height];
            }
            
            LabelView *applicationVersionLabelView = [[LabelView alloc] init]; {
                
                NSAttributedString *attributedStringResult = [NSMutableAttributedString attributedStringWithString: [NSString stringWithFormat:@"%@: %@", [LocalizedStrings labelviewTitleVersion], [Constants applicationVersion]]
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
                NSAttributedString *attributedStringResult = [NSMutableAttributedString attributedStringWithString: [NSString stringWithFormat: @"%@", [LocalizedStrings labelviewTitleAdditionalInformation]]
                                                                                                            weight: 6
                                                                                                              size: NSFont.systemFontSize];
                
                [openSourceLicensesLabelView setAttributedStringValue:attributedStringResult];
                
                [openSourceLicensesVerticalLayout addView:openSourceLicensesLabelView
                                                    width: openSourceLicensesLabelView.cell.cellSize.width
                                                   height: openSourceLicensesLabelView.cell.cellSize.height];
            }
            
            // TODO: Replace with external text loading
            AdvancedTextView *openSourceLicensesAdvancedTextView = [[AdvancedTextView alloc] init]; {
                [openSourceLicensesAdvancedTextView appendLine:
                 @"WinDiskWriter is a macOS application that allows users to create bootable USB Windows installers." "\n\n"
                 "This is an open source project developed by TechUnRestricted." "\n\n"
                 
                 "WinDiskWriter uses the wimlib library, which is licensed under the GNU Lesser General Public License Version 3. The library has been slightly modified to prevent application crashes caused by assertions. This enables the integration of wimlib as a part of the project, instead of as a separate binary file that is invoked through the console." "\n\n"
                 
                 "The application can optionally download and use grub4dos, which is a GPL v2 licensed software." "\n"
                 "Grub4dos is used to enable legacy booting for older systems." "\n\n"
                 
                 "WinDiskWriter is written in the Objective-C programming language to achieve backward compatibility with older operating systems. This is achieved by using legacy code and custom solutions instead of relying on external frameworks. For example, the user interface and the logic of element placement are coded manually, without using xib and storyboards." "\n\n"
                 
                 "This software supports making bootable USB drives with Windows Vista, 7, 8, 8.1, 10 and 11 in both UEFI and Legacy modes. It also supports 32-bit Windows images. Future updates will include more features and enhancements." "\n\n\n"

            

                 "——————————————————" "\n"
                 "[ —  WIMLIB Open Source License  — ]" "\n"
                 "——————————————————" "\n\n"
                 
                ];
                
                [openSourceLicensesAdvancedTextView appendLine: WIMLIB_LICENSE_TEXT];
                
                [openSourceLicensesAdvancedTextView appendLine:
                 @"\n\n"
                 "——————————————————" "\n"
                 "[ —  grub4dos Open Source License  — ]" "\n"
                 "——————————————————" "\n\n"];
                
                [openSourceLicensesAdvancedTextView appendLine: GRUB4DOS_LICENSE_TEXT];
                
                [openSourceLicensesVerticalLayout addView: openSourceLicensesAdvancedTextView
                                                 minWidth: 0
                                                 maxWidth: INFINITY
                                                minHeight: 100
                                                maxHeight: INFINITY];
                
            }
            
        }
        
        [mainVerticalLayout addView:spacerView width:0 height:8];
        
        ButtonView *openDonationWebPageButtonView = [[ButtonView alloc] init]; {
            [openDonationWebPageButtonView setTitle: [LocalizedStrings menuTitleDonateMe]];
            
            [openDonationWebPageButtonView setTarget: [HelperFunctions class]];
            [openDonationWebPageButtonView setAction: @selector(openDonationsPage)];
                        
            [mainVerticalLayout addView: openDonationWebPageButtonView
                                  width: openDonationWebPageButtonView.cell.cellSize.width
                                 height: openDonationWebPageButtonView.cell.cellSize.height];
        }
        
        LabelView *developerNameLabelView = [[LabelView alloc] init]; {
            [developerNameLabelView setStringValue: [Constants developerName]];
            
            [mainVerticalLayout addView: developerNameLabelView
                                  width: developerNameLabelView.cell.cellSize.width
                                 height: developerNameLabelView.cell.cellSize.height];
        }
        
    }
    
    
    
}

@end
