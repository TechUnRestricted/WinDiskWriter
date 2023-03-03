//
//  ContentViewController.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "ContentViewController.h"
#import "VerticalStackLayout.h"
#import "NSView+QuickConstraints.h"
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
    
    NSButton *button1 = [[NSButton alloc] init];
    [button1 setTitle: @"Objective-C Rocks"];
    [button1 setTranslatesAutoresizingMaskIntoConstraints: NO];
    [mainView addSubview: button1];
    
    [mainView addConstraints: @[
        [NSLayoutConstraint constraintWithItem: button1
                                     attribute: NSLayoutAttributeTop
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: mainView
                                     attribute: NSLayoutAttributeTop
                                    multiplier: 1.0
                                      constant: 0.0],
        [NSLayoutConstraint constraintWithItem: button1
                                     attribute: NSLayoutAttributeLeading
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: mainView
                                     attribute: NSLayoutAttributeLeading
                                    multiplier: 1.0
                                      constant: 0.0],
        [NSLayoutConstraint constraintWithItem: button1
                                     attribute: NSLayoutAttributeWidth
                                     relatedBy: NSLayoutRelationGreaterThanOrEqual
                                        toItem: nil
                                     attribute: NSLayoutAttributeNotAnAttribute
                                    multiplier: 1.0
                                      constant: 100],
        [NSLayoutConstraint constraintWithItem: button1
                                     attribute: NSLayoutAttributeWidth
                                     relatedBy: NSLayoutRelationLessThanOrEqual
                                        toItem: nil
                                     attribute: NSLayoutAttributeNotAnAttribute
                                    multiplier: 1.0
                                      constant: 300]
    ]];
    
    {
        NSButton *button2 = [[NSButton alloc] init];
        button2.title = @"Goodbye Objective-C";
        [button2 setTranslatesAutoresizingMaskIntoConstraints: NO];
        
        [mainView addSubview: button2];
        
        NSLayoutConstraint *weakLeadingConstraint = [NSLayoutConstraint constraintWithItem: button2
                                                                                 attribute: NSLayoutAttributeLeading
                                                                                 relatedBy: NSLayoutRelationLessThanOrEqual
                                                                                    toItem: button1
                                                                                 attribute: NSLayoutAttributeTrailing
                                                                                multiplier: 1.0
                                                                                  constant: 0.0];
        
        NSLayoutConstraint *weakTrailingConstraint = [NSLayoutConstraint constraintWithItem: button2
                                                                                  attribute: NSLayoutAttributeTrailing
                                                                                  relatedBy: NSLayoutRelationGreaterThanOrEqual
                                                                                     toItem: mainView
                                                                                  attribute: NSLayoutAttributeTrailing
                                                                                 multiplier: 1.0
                                                                                   constant: 0.0];
        
        weakLeadingConstraint.priority = NSLayoutPriorityDragThatCannotResizeWindow;
        weakTrailingConstraint.priority = NSLayoutPriorityDragThatCannotResizeWindow;
        
        [NSLayoutConstraint activateConstraints:@[
            [NSLayoutConstraint constraintWithItem: button2
                                         attribute: NSLayoutAttributeTop
                                         relatedBy: NSLayoutRelationEqual
                                            toItem: mainView
                                         attribute: NSLayoutAttributeTop
                                        multiplier: 1.0
                                          constant: 0.0],
            [NSLayoutConstraint constraintWithItem: button2
                                         attribute: NSLayoutAttributeLeading
                                         relatedBy: NSLayoutRelationGreaterThanOrEqual
                                            toItem: button1
                                         attribute: NSLayoutAttributeTrailing
                                        multiplier: 1.0
                                          constant: 0.0],
            [NSLayoutConstraint constraintWithItem: button2
                                         attribute: NSLayoutAttributeTrailing
                                         relatedBy: NSLayoutRelationLessThanOrEqual
                                            toItem: mainView
                                         attribute: NSLayoutAttributeTrailing
                                        multiplier: 1.0
                                          constant: 0.0],
            weakLeadingConstraint,
            weakTrailingConstraint,
            [NSLayoutConstraint constraintWithItem: button2
                                         attribute: NSLayoutAttributeWidth
                                         relatedBy: NSLayoutRelationGreaterThanOrEqual
                                            toItem: nil
                                         attribute: NSLayoutAttributeNotAnAttribute
                                        multiplier: 1.0
                                          constant: 200],
            [NSLayoutConstraint constraintWithItem: button2
                                         attribute: NSLayoutAttributeWidth
                                         relatedBy: NSLayoutRelationLessThanOrEqual
                                            toItem: nil
                                         attribute: NSLayoutAttributeNotAnAttribute
                                        multiplier: 1.0
                                          constant: 400]
        ]];
    }
    
    [self setView: mainView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

@end
