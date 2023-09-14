//
//  CChar2DArray.m
//  windiskwriter
//
//  Created by Macintosh on 13.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "CChar2DArray.h"

@implementation CChar2DArray {
    char **_cStringArray;
    NSArray *_nsArray;
}

- (instancetype)initWithNSArray: (NSArray *_Nonnull)nsArray {
    _nsArray = nsArray;
    
    return self;
}

- (char *_Nullable *_Nullable)getArray {
    NSUInteger count = [_nsArray count];
    _cStringArray = (char **)malloc((count + 1) * sizeof(char*));
    
    for (NSUInteger i = 0; i < count; i++) {
        _cStringArray[i] = strdup([[_nsArray objectAtIndex:i] UTF8String]);
    }
    _cStringArray[count] = NULL;
    
    return _cStringArray;
}

- (void)dealloc {
    if (_cStringArray != NULL) {
        for (NSUInteger index = 0; _cStringArray[index] != NULL; index++) {
            free(_cStringArray[index]);
        }
        free(_cStringArray);
    }
}

@end
