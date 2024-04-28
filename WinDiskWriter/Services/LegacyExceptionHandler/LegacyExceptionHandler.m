//
//  LegacyExceptionHandler.m
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

#import "LegacyExceptionHandler.h"

@implementation LegacyExceptionHandler

+ (NSException *_Nullable)catchException:(void(^)(void))tryBlock {
    @try {
        tryBlock();
        
        return nil;
    } @catch (NSException *exception) {
        return exception;
    }
}

@end
