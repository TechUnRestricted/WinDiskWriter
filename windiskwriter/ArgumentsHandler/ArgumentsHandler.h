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
    AHErrorCodeCollectionCastingFailure,
    AHErrorCadeNamesAreNotUnique
};

@interface ArgumentsHandler : NSObject
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
