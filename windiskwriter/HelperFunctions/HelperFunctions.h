//
//  HelperFunctions.h
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define IOLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

@interface HelperFunctions : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (BOOL) hasElevatedRights;
+ (NSString *)randomStringWithLength: (uint64_t)requiredLength;
@end

NS_ASSUME_NONNULL_END
