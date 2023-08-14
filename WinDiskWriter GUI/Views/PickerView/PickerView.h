//
//  PickerView.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 30.07.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PickerView : NSPopUpButton

- (void)addItemWithTitle: (NSString *)title
       associatedObject: (id)object;

- (void)removeAllItemsWithAssociatedObjects;

- (id)associatedObjectForSelectedItem;

- (void)removeAllItems NS_UNAVAILABLE;

- (void)removeItemAtIndex:(NSInteger)index NS_UNAVAILABLE;

- (void)removeItemWithTitle:(NSString *)title NS_UNAVAILABLE;

- (void)addItemsWithTitles:(NSArray<NSString *> *)itemTitles NS_UNAVAILABLE;

- (void)addItemWithTitle:(NSString *)title NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
