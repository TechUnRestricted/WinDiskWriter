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
                  identifier: (int)identifier
                  isRequired: (BOOL)isRequired
                    isPaired: (BOOL)isPaired
                    isUnique: (BOOL)isUnique {
    _name = name;
    _identifier = identifier;
    _isRequired = isRequired;
    _isPaired = isPaired;
    _isUnique = isUnique;
    
    return self;
}
@end
