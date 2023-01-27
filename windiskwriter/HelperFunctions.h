//
//  HelperFunctions.h
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HelperFunctions : NSObject
+ (BOOL) hasElevatedRights;
//+ (BOOL) hasOneOfThePrefixes:(NSString *)prefixes, ... NS_REQUIRES_NIL_TERMINATION;
@end

NS_ASSUME_NONNULL_END
