//
//  LegacyExceptionHandler.h
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LegacyExceptionHandler : NSObject

+ (NSException *_Nullable)catchException: (void(^)(void))tryBlock;

@end

NS_ASSUME_NONNULL_END
