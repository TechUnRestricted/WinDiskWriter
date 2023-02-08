//
//  ArgumentObject.m
//  windiskwriter
//
//  Created by Macintosh on 09.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "ArgumentObject.h"

@implementation ArgumentObject

- (instancetype)initWithName: (NSString *_Nonnull)name
                    uniqueID: (id _Nullable)uniqueID
                  isRequired: (BOOL)isRequired
                    isPaired: (BOOL)isPaired {
    _name = name;
    _uniqueID = uniqueID;
    _isRequired = isRequired;
    _isPaired = isPaired;
    
    return self;
}
@end
