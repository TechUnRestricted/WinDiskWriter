//
//  PickerView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 30.07.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "PickerView.h"
#import <objc/runtime.h>

// Declare a static variable as a key
static char *stringValueKey;

@implementation PickerView

- (instancetype)init {
    self = [super init];
    
    [self setBezelStyle:NSBezelStyleTexturedRounded];
    
    return self;
}

- (void)addItemWithTitle: (NSString *)title
       associatedObject: (id)object {

    [self addItemWithTitle: title];

    NSMenuItem *lastItem = [self lastItem];
    objc_setAssociatedObject(lastItem, &stringValueKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)removeAllItemsWithAssociatedObjects {
    
    for (NSMenuItem *item in self.menu.itemArray) {
        objc_setAssociatedObject(item, &stringValueKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    [self removeAllItems];
    
}

- (id)associatedObjectForSelectedItem {
    NSMenuItem *selectedItem = [self selectedItem];

    id associatedObject = objc_getAssociatedObject(selectedItem, &stringValueKey);

    return associatedObject;
}

@end
