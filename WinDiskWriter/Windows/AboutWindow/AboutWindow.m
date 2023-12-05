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
            
            // TODO: Replace with external text loading
            AdvancedTextView *openSourceLicensesAdvancedTextView = [[AdvancedTextView alloc] init]; {
                [openSourceLicensesAdvancedTextView appendLine:
                 @"WinDiskWriter is a macOS application that allows users to create bootable flash drives with the Windows operating system, which is a product of Microsoft Corporation." "\n\n"
                 "The application is an open source project developed by TechUnRestricted." "\n\n"
                 
                 "It uses the wimlib library, which is licensed under the GNU Lesser General Public License Version 3. The library has been slightly modified to prevent application crashes caused by assertions. This enabled the integration of wimlib as a part of the project, instead of a separate binary file that is invoked through the console." "\n\n"
                 
                 "The application also uses the grub4dos tool, which is licensed under the GNU General Public License Version 2. The tool is not built into the code, but it is a separate binary file in the Resources folder." "\n"
                 "Grub4dos used to enable legacy booting for older systems." "\n\n"
                 "!!! The user is free to modify, replace or remove grub4dos binaries from the WinDiskWriter.app !!!" "\n\n"
                 
                 "The application is written in Objective-C programming language, with backward compatibility for older operating systems. This is achieved by using legacy code and custom solutions, instead of relying on external frameworks. The user interface and the logic of element placement are coded manually, without using xib and storyboards." "\n\n"
                 
                 "The application has only one version: GUI. It supports writing Windows Vista, 7, 8, 8.1, 10 and 11 in both UEFI and Legacy modes. It also supports x32 bit Windows images. Future improvements will include more features and enhancements." "\n\n\n"

            

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
            [openDonationWebPageButtonView setTitle: MENU_DONATE_ME_TITLE];
            
            [openDonationWebPageButtonView setTarget: [HelperFunctions class]];
            [openDonationWebPageButtonView setAction: @selector(openDonationsPage)];
                        
            [mainVerticalLayout addView: openDonationWebPageButtonView
                                  width: openDonationWebPageButtonView.cell.cellSize.width
                                 height: openDonationWebPageButtonView.cell.cellSize.height];
        }
        
        LabelView *developerNameLabelView = [[LabelView alloc] init]; {
            [developerNameLabelView setStringValue: DEVELOPER_NAME];
            
            [mainVerticalLayout addView: developerNameLabelView
                                  width: developerNameLabelView.cell.cellSize.width
                                 height: developerNameLabelView.cell.cellSize.height];
        }
        
    }
    
    
    
}

@end
