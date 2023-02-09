//
//  ArgumentsHandler.h
//  windiskwriter
//
//  Created by Macintosh on 09.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArgumentObject/ArgumentObject.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^ArgumentsHandlerCallback)(ArgumentObject * _Nonnull argumentObject, NSString *_Nullable pair);

enum AHErrorCode {
    AHErrorCodeObjectCastingFailure,
    AHErrorCodeObjectNamesCheckingFailure,
    AHErrorCodeDuplicateArgumentKeys,
    AHErrorCodeCantFindPairValue
};

@interface ArgumentsHandler : NSObject

@property (strong, nonatomic, readonly) NSArray *_Nonnull processArguments;
@property (strong, nonatomic, readonly) NSArray *_Nonnull argumentObjects;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithProcessArguments: (NSArray *_Nonnull)processArguments
                         argumentObjects: (NSArray *_Nonnull)argumentObjects;

- (BOOL) loopThroughArgumentsWithErrorHandler: (NSError *_Nullable *_Nullable)error
                                     callback: (ArgumentsHandlerCallback)callback;

@end

NS_ASSUME_NONNULL_END
