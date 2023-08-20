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

- (NSUInteger)firstArgumentContainsProgramPath {
    NSUInteger processArgumentsCount = [_processArguments count];
    if (processArgumentsCount == 0) {
        return 0;
    }
    
    if (processArgumentsCount >= 1) {
        BOOL firstArgumentIsProgramPath = [[NSFileManager defaultManager] fileExistsAtPath:[_processArguments firstObject]];
        return firstArgumentIsProgramPath ? 1 : 0;
    }
    
    return 0;
}

- (BOOL) loopThroughArgumentsWithErrorHandler: (NSError *_Nullable *_Nullable)error
                          prohibitUnknownKeys: (BOOL)prohibitUnknownKeys
                                     callback: (ArgumentsHandlerCallback)callback {
    NSUInteger stringArgumentsCount = [_processArguments count];
    NSUInteger objectArgumentsCount = [_argumentObjects count];
    
    NSMutableArray *processedUniqueArguments = [[NSMutableArray alloc] init];
    NSMutableArray *processedRequiredArguments = [[NSMutableArray alloc] init];
    
    for (NSUInteger stringIndex = [self firstArgumentContainsProgramPath]; stringIndex < stringArgumentsCount; stringIndex++) {
        NSString *currentArgumentString = [_processArguments objectAtIndex:stringIndex];
        
        for (NSUInteger objectIndex = 0; objectIndex <= objectArgumentsCount; objectIndex++) {
            if (objectIndex == objectArgumentsCount) {
                if (!prohibitUnknownKeys) {
                    continue;
                }
                
                if (error) {
                    *error = [NSError errorWithDomain: PACKAGE_NAME
                                                 code: AHErrorCodeUnknownArgument
                                             userInfo: @{NSLocalizedDescriptionKey: [NSString stringWithFormat: @"An unknown key [%@] was found in arguments.",
                                                                             currentArgumentString
                                             ]}];
                }
                
                return NO;
            }
            
            ArgumentObject *currentArgumentObject = [_argumentObjects objectAtIndex:objectIndex];
            
            if (![currentArgumentObject.name isEqualToString:currentArgumentString]) {
                continue;
            }
            
            if ([processedUniqueArguments containsObject:currentArgumentObject]) {
                if (error) {
                    *error = [NSError errorWithDomain: PACKAGE_NAME
                                                 code: AHErrorCodeDuplicateUniqueArgumentKeys
                                             userInfo: @{NSLocalizedDescriptionKey: @"Duplicate unique keys were found in arguments."}];
                }
                return NO;
            }
            
            if (currentArgumentObject.isUnique) {
                [processedUniqueArguments addObject:currentArgumentObject];
            }
            
            if (currentArgumentObject.isRequired) {
                [processedRequiredArguments addObject:currentArgumentObject];
            }
            
            if (currentArgumentObject.isPaired) {
                if (stringIndex + 1 < stringArgumentsCount) {
                    callback(currentArgumentObject, [_processArguments objectAtIndex: ++stringIndex]);
                    break;
                } else {
                    if (error) {
                        *error = [NSError errorWithDomain: PACKAGE_NAME
                                                     code: AHErrorCodeCantFindPairValue
                                                 userInfo: @{NSLocalizedDescriptionKey:
                                                                 [NSString stringWithFormat: @"\"%@\" argument requires the presence of a pair that was not found.", currentArgumentString]}
                        ];
                    }
                    return NO;
                }
            }
            
            /* Not paired Argument */
            callback(currentArgumentObject, NULL);
            break;
        }
    }
    
    for (ArgumentObject *currentObject in _argumentObjects) {
        if (!currentObject.isRequired) {
            continue;
        }
        
        if (![processedRequiredArguments containsObject:currentObject]) {
            if (error) {
                *error = [NSError errorWithDomain: PACKAGE_NAME
                                             code: AHErrorCodeMissingRequiredArgument
                                         userInfo: @{NSLocalizedDescriptionKey:
                                                         [NSString stringWithFormat: @"The required Argument '%@' is missing.", currentObject.name]}
                ];
            }
            return NO;
        }
    }
    
    return YES;
}

- (instancetype)initWithProcessArguments: (NSArray *_Nonnull)processArguments
                         argumentObjects: (NSArray<ArgumentObject *> *_Nonnull)argumentObjects {
    
    _processArguments = processArguments;
    _argumentObjects = argumentObjects;
    
    return self;
}

@end
