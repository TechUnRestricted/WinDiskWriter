//
//  ArgumentsHandler.m
//  windiskwriter
//
//  Created by Macintosh on 09.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "ArgumentsHandler.h"
#import "Constants.h"

@implementation ArgumentsHandler

- (BOOL)hasIncompatibleNames {
    NSUInteger objectsCount = [_argumentObjects count];
    
    for (int i = 0; i < objectsCount; i++) {
        ArgumentObject *objectA = [_argumentObjects objectAtIndex:i];
        
        if (objectA.name == NULL || [objectA.name length] == 0) {
            return YES;
        }
        
        for(int j = i + 1; j < objectsCount; j++) {
            ArgumentObject *objectB = [_argumentObjects objectAtIndex:j];
            
            if(objectA.name == objectB.name) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL) loopThroughArgumentsWithCallback: (ArgumentsHandlerCallback)callback
                                    error: (NSError *_Nullable *_Nullable)error {
    
    if (_argumentObjects == NULL || _processArguments == NULL) {
        return NO;
    }
    
    if ([self hasIncompatibleNames]) {
        *error = [NSError errorWithDomain: PACKAGE_NAME
                                     code: AHErrorCodeObjectNamesCheckingFailure
                                 userInfo: @{DEFAULT_ERROR_KEY: @"Incompatible names detected in ArgumentObjects."}
        ];
        return NO;
    }
    
    NSUInteger stringArgsCount = [_processArguments count];
    for (NSUInteger stringIndex = 0; stringIndex < stringArgsCount; stringIndex++) {
        NSString *currentArgString = [_processArguments objectAtIndex:stringIndex];
        
        for (ArgumentObject *currentArgObject in _argumentObjects) {
            if ([currentArgString isEqualToString:currentArgObject.name]) {
                if (!currentArgObject.isPaired) {
                    callback(currentArgObject, YES, NULL);
                    break;
                }
                
                if (stringIndex + 1 < stringArgsCount) {
                    callback(currentArgObject, YES, [_processArguments objectAtIndex: ++stringIndex]);
                } else {
                    callback(currentArgObject, NO, NULL);
                }
            } /* else {
                NSLog(@"{{Current Arg: %@}} != {{Object: %@}}", currentArgString, currentArgObject.name);
            } */
        }
    }
    
    return YES;
    
    /* Checking for the possibility of safe type casting [] */
    /* for (id currentCollection in argumentObjects) {
     if (![currentCollection isKindOfClass:[ArgumentObject class]]) {
     if (error != NULL) {
     *error = [NSError errorWithDomain: PACKAGE_NAME
     code: AHErrorCodeCollectionCastingFailure
     userInfo: @{DEFAULT_ERROR_KEY: @"(NSArray *) contains values that cannot be casted to the type (ArgumentObjects *)."}
     ];
     }
     return NO;
     }
     } */
}

- (instancetype)initWithProcessArguments: (NSArray *_Nonnull)processArguments
                         argumentObjects: (NSArray *_Nonnull)argumentObjects {
    if (argumentObjects == NULL || processArguments == NULL) {
        return NULL;
    }
    
    _processArguments = processArguments;
    _argumentObjects = argumentObjects;
    
    return self;
}

@end
