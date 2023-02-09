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
typedef BOOL (^ArgumentsHandlerCallback)(ArgumentObject * _Nonnull argumentObject, BOOL success, NSString *_Nullable pair);

enum AHErrorCode {
    AHErrorCodeObjectCastingFailure,
    AHErrorCodeObjectNamesCheckingFailure
};

@interface ArgumentsHandler : NSObject

@property (strong, nonatomic, readonly) NSArray *_Nonnull processArguments;
@property (strong, nonatomic, readonly) NSArray *_Nonnull argumentObjects;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithProcessArguments: (NSArray *_Nonnull)processArguments
                         argumentObjects: (NSArray *_Nonnull)argumentObjects;

- (BOOL) loopThroughArgumentsWithCallback: (ArgumentsHandlerCallback)callback
                                    error: (NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
