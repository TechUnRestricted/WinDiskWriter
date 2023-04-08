//
//  ContentViewController.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "ContentViewController.h"
#import "NSView+QuickConstraints.h"
#import "NSColor+Common.h"
#import "LabelView.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "NSView+QuickConstraints.h"

#import "VerticalStackView.h"
#import "HorizontalStackView.h"

@interface ContentViewController ()

@end

NSView *mainView;
CGFloat _titleBarPaddingValue = 0;
CGFloat defaultMainContentPadding = 10;
CGFloat defaultElementVerticalPadding = 4;

/* Views */

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
    
    VerticalStackView *mainStackView = [[VerticalStackView alloc] init];
    [mainStackView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [mainStackView setSpacing: defaultElementVerticalPadding];
    
    [mainView addSubview: mainStackView];
    
    [mainStackView setQuickPinFillParentWithPaddingTop: defaultMainContentPadding + _titleBarPaddingValue
                                                bottom: defaultMainContentPadding
                                               leading: defaultMainContentPadding
                                              trailing: defaultMainContentPadding];
    
    NSView *containerForHorizontal = [[NSView alloc] init];
    [containerForHorizontal setTranslatesAutoresizingMaskIntoConstraints: NO];
    [mainStackView addSubview:containerForHorizontal];
    
    [containerForHorizontal setConstraintAttribute:NSLayoutAttributeHeight toItem:mainStackView itemAttribute:NSLayoutAttributeHeight relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];
    [containerForHorizontal setConstraintAttribute:NSLayoutAttributeLeading toItem:mainStackView itemAttribute:NSLayoutAttributeLeading relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];
    
    [containerForHorizontal setConstraintAttribute:NSLayoutAttributeTrailing toItem:mainStackView itemAttribute:NSLayoutAttributeTrailing relation:NSLayoutRelationGreaterThanOrEqual priority:499 constant:0 multiplier:1.0 identifier:NULL];
    [containerForHorizontal setConstraintAttribute:NSLayoutAttributeTrailing toItem:mainStackView itemAttribute:NSLayoutAttributeTrailing relation:NSLayoutRelationLessThanOrEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];
        
    
    [containerForHorizontal setWantsLayer: YES];
    [containerForHorizontal.layer setBackgroundColor: NSColor.redColor.toCGColor];
    
    
    NSButton *button1 = [[NSButton alloc] init]; {
        [button1 setTranslatesAutoresizingMaskIntoConstraints: NO];
        [button1 setTitle: @"Button1"];
        
        [containerForHorizontal addSubview: button1];
        [button1 setConstraintAttribute:NSLayoutAttributeTop toItem:containerForHorizontal itemAttribute:NSLayoutAttributeTop relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];
        [button1 setConstraintAttribute:NSLayoutAttributeLeading toItem:containerForHorizontal itemAttribute:NSLayoutAttributeLeading relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];
        
        [button1 setMinWidth:100];
        [button1 setMaxWidth:200];
    }
    
    NSButton *button2 = [[NSButton alloc] init]; {
        [button2 setTranslatesAutoresizingMaskIntoConstraints: NO];
        [button2 setTitle: @"Button2"];
        
        [containerForHorizontal addSubview: button2];
        [button2 setMaxWidth:300];

        [button2 setConstraintAttribute:NSLayoutAttributeTop toItem:containerForHorizontal itemAttribute:NSLayoutAttributeTop relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];
        [button2 setConstraintAttribute:NSLayoutAttributeLeading toItem:button1 itemAttribute:NSLayoutAttributeTrailing relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];
    }

    
    NSTextField *button3 = [[NSTextField alloc] init]; {
        [button3 setTranslatesAutoresizingMaskIntoConstraints: NO];
        [button3 setStringValue: @"Button3"];
        
        [containerForHorizontal addSubview: button3];
        [button3 setMinWidth:300];
        [button3 setMaxWidth:500];

        [button3 setConstraintAttribute:NSLayoutAttributeTop toItem:containerForHorizontal itemAttribute:NSLayoutAttributeTop relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];
        [button3 setConstraintAttribute:NSLayoutAttributeLeading toItem:button2 itemAttribute:NSLayoutAttributeTrailing relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];
    }
    
    [button1 setConstraintAttribute:NSLayoutAttributeTrailing toItem:button2 itemAttribute:NSLayoutAttributeLeading relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];
    [button2 setConstraintAttribute:NSLayoutAttributeTrailing toItem:button3 itemAttribute:NSLayoutAttributeLeading relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];
    [button3 setConstraintAttribute:NSLayoutAttributeTrailing toItem:containerForHorizontal itemAttribute:NSLayoutAttributeTrailing relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];

    [button2 setConstraintAttribute:NSLayoutAttributeWidth toItem:button1 itemAttribute:NSLayoutAttributeWidth relation:NSLayoutRelationEqual isWeak:YES constant:0 multiplier:1.0 identifier:NULL];
    [button3 setConstraintAttribute:NSLayoutAttributeWidth toItem:button1 itemAttribute:NSLayoutAttributeWidth relation:NSLayoutRelationEqual isWeak:YES constant:0 multiplier:1.0 identifier:NULL];

    [self setView: mainView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (instancetype)initWithTitleBarPaddingValue: (CGFloat)titleBarPaddingValue {
    self = [super init];
    _titleBarPaddingValue = titleBarPaddingValue;
    
    return self;
}

@end
