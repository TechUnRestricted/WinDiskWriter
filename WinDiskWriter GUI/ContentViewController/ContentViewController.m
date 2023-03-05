//
//  ContentViewController.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "ContentViewController.h"
#import "VerticalStackLayout.h"
#import "HorizontalStackLayout.h"
#import "NSView+QuickConstraints.h"
#import "NSColor+Common.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface ContentViewController ()

@end

NSView *mainView;

@implementation ContentViewController

- (void)loadView {
    if (@available(macOS 10.10, *)) {
        NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] init];
        [visualEffectView setState: NSVisualEffectStateActive];
        [visualEffectView setBlendingMode: NSVisualEffectBlendingModeBehindWindow];
        
        mainView = visualEffectView;
    } else {
        mainView = [[NSView alloc] init];
    }
    
    VerticalStackLayout *verticalStackView = [[VerticalStackLayout alloc] init];
    [verticalStackView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [mainView addSubview: verticalStackView];
    
    [verticalStackView setQuickPinFillParentWithPadding: 0];
    
    [verticalStackView setWantsLayer: YES];
    [verticalStackView.layer setBackgroundColor: NSColor.redColor.toCGColor];
    
    for (int i = 0; i < 5; i++) {
        NSButton *button1 = [[NSButton alloc] init];
        [button1 setTitle: @"Magic Keyboard"];
        [verticalStackView addView: button1 spacing: 0];
        
        [button1 setMaxWidth: 500 - i * 50];
        [button1 setMinWidth: 200];
    }
    
    {
        NSTextField *textField = [[NSTextField alloc] init];
        [textField setStringValue: @"Behind the bar"];
        [textField setMaxWidth: 300];
        [textField setMinWidth: 200];
        
        [verticalStackView addView:textField spacing:0];
    }
    
    HorizontalStackLayout *horizontalView = [[HorizontalStackLayout alloc] init];
    [horizontalView setWantsLayer: YES];
    [horizontalView.layer setBackgroundColor:NSColor.greenColor.toCGColor];
    [verticalStackView addView:horizontalView spacing:0];
    
    for (NSUInteger i = 0; i < 15; i++) {
        NSButton *button1 = [[NSButton alloc] init];
        [button1 setTranslatesAutoresizingMaskIntoConstraints: NO];
        [button1 setTitle: @"ATM"];
        [horizontalView addView:button1 spacing:0];
      
        [button1 setMinWidth:100];
        [button1 setMaxWidth:300 - 5 * i];
    }
    
    
    
    
    
    [self setView: mainView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

@end
