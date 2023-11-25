//
//  HelperFunctions.m
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "HelperFunctions.h"
#import "NSString+Common.h"
#import "NSError+Common.h"
#import "DiskManager.h"
#import "Constants.h"
#import "HDIUtil.h"

NSString const *MSDOSCompliantSymbols  = @"ABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";

@implementation HelperFunctions

+ (BOOL)hasElevatedRights {
    return geteuid() == 0;
}

+ (void)printTimeElapsedWhenRunningCode: (NSString *)title
                              operation: (void (^)(void))operation {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    operation();
    CFAbsoluteTime timeElapsed = CFAbsoluteTimeGetCurrent() - startTime;
    
    NSLog(@"Time elapsed for %@: %f s.", title, timeElapsed);
}

+ (NSString *)randomStringWithLength: (UInt64)requiredLength {
    NSMutableString *generatedString = [NSMutableString stringWithCapacity:requiredLength];
    
    for (NSUInteger i = 0U; i < requiredLength; i++) {
        u_int32_t r = arc4random() % [MSDOSCompliantSymbols length];
        unichar c = [MSDOSCompliantSymbols characterAtIndex:r];
        [generatedString appendFormat:@"%C", c];
    }
    
    return generatedString;
}

+ (BOOL)restartWithElevatedPermissionsWithError: (NSError *_Nonnull *_Nonnull)error {
    NSArray<NSString *> *argumentsList = NSProcessInfo.processInfo.arguments;
    if (argumentsList.count == 0) {
        if (error) {
            *error = [NSError errorWithStringValue: @"Application arguments list is empty."];
        }
        
        return NO;
    }
    
    NSString *executablePath = [argumentsList firstObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath: executablePath]) {
        if (error) {
            *error = [NSError errorWithStringValue: @"The first object of application arguments list is not a file."];
        }
        
        return NO;
    }
    
    AuthorizationRef authorizationRef;
    AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagPreAuthorize, &authorizationRef);
    
    char *cExecutablePath = (char *)[executablePath cStringUsingEncoding: NSUTF8StringEncoding];
    char *args[] = {NULL};
    
    OSStatus executionStatus = AuthorizationExecuteWithPrivileges(authorizationRef, cExecutablePath, kAuthorizationFlagDefaults, args, NULL);
    
    NSString *executionErrorString = NULL;
    
    switch (executionStatus) {
        case errAuthorizationSuccess:
            [[NSApplication sharedApplication] terminate:nil];
            break;
        case errAuthorizationInvalidSet:
            executionErrorString = @"The authorization rights are invalid.";
            break;
        case errAuthorizationInvalidRef:
            executionErrorString = @"The authorization reference is invalid.";
            break;
        case errAuthorizationInvalidTag:
            executionErrorString = @"The authorization tag is invalid.";
            break;
        case errAuthorizationInvalidPointer:
            executionErrorString = @"The returned authorization is invalid.";
            break;
        case errAuthorizationDenied:
            executionErrorString = @"The authorization was denied.";
            break;
        case errAuthorizationCanceled:
            executionErrorString = @"The authorization was canceled by the user.";
            break;
        case errAuthorizationInteractionNotAllowed:
            executionErrorString = @"The authorization was denied since no user interaction was possible.";
            break;
        case errAuthorizationInternal:
            executionErrorString = @"Unable to obtain authorization for this operation.";
            break;
        case errAuthorizationExternalizeNotAllowed:
            executionErrorString = @"The authorization is not allowed to be converted to an external format.";
            break;
        case errAuthorizationInternalizeNotAllowed:
            executionErrorString = @"The authorization is not allowed to be created from an external format.";
            break;
        case errAuthorizationInvalidFlags:
            executionErrorString = @"The provided option flag(s) are invalid for this authorization operation.";
            break;
        case errAuthorizationToolExecuteFailure:
            executionErrorString = @"The specified program could not be executed.";
            break;
        case errAuthorizationToolEnvironmentError:
            executionErrorString = @"An invalid status was returned during execution of a privileged tool.";
            break;
        case errAuthorizationBadAddress:
            executionErrorString = @"The requested socket address is invalid (must be 0-1023 inclusive).";
            break;
    }

    if (authorizationRef != NULL) {
        AuthorizationFree(authorizationRef, kAuthorizationFlagPreAuthorize);
    }
    
    if (error) {
        *error = [NSError errorWithStringValue: executionErrorString];
    }
    
    return NO;
}

+ (NSString *_Nullable)windowsSourceMountPath: (NSString *_Nonnull)sourcePath
                                        error: (NSError *_Nullable *_Nullable)error {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    BOOL isDirectory;
    BOOL exists = [fileManager fileExistsAtPath:sourcePath isDirectory:&isDirectory];
    
    if (!exists) {
        if (error) {
            *error = [NSError errorWithStringValue: [NSString stringWithFormat: @"File [directory] \"%@\" doesn't exist.", sourcePath]];
        }
        
        return NULL;
    }
    
    if (isDirectory) {
        return sourcePath;
    }
    
    if (![[[sourcePath lowercaseString] pathExtension] isEqualToString: @"iso"]) {
        if (error) {
            *error = [NSError errorWithStringValue: @"This file does not have an .iso extension."];
        }
        
        return NULL;
    }
    
    HDIUtil *hdiutil = [[HDIUtil alloc] initWithImagePath:sourcePath];
    if([hdiutil attachImageWithArguments:@[@"-readonly", @"-noverify", @"-noautofsck", @"-noautoopen"]
                                   error: error]) {
        return [hdiutil mountPoint];
    }
    
    return NULL;
}

+ (DiskManager *_Nullable)diskManagerWithDevicePath: (NSString *)devicePath
                                        isBSDDevice: (BOOL *_Nullable)isBSDDevice
                                              error: (NSError *_Nullable *_Nullable)error {
    
    if ([DiskManager isBSDPath:devicePath]) {
        if (isBSDDevice != NULL) {
            *isBSDDevice = YES;
        }
        
        /* Received device destination path was defined as BSD Name. */
        return [[DiskManager alloc] initWithBSDName:devicePath];
    }
    else if ([devicePath hasPrefix:@"/Volumes/"]) {
        if (isBSDDevice != NULL) {
            *isBSDDevice = NO;
        }
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        BOOL isDirectory;
        BOOL exists = [fileManager fileExistsAtPath:devicePath isDirectory:&isDirectory];
        
        if (!exists) {
            if (error) {
                *error = [NSError errorWithStringValue: @"The given Destination path does not exist."];
            }
            
            return NULL;
        }
        
        /* Received device destination path was defined as Mounted Volume. */
        if (@available(macOS 10.7, *)) {
            return [[DiskManager alloc] initWithVolumePath:devicePath];
        } else {
            // TODO: Fix Mac OS X 10.6 Snow Leopard support
            if (error) {
                *error = [NSError errorWithStringValue: @"Can't load Destination device info from Mounted Volume on this Mac OS X version."];
            }
            
            return NULL;
        }
    }
    return NULL;
}

+ (NSString *)unitFormattedSizeFor: (UInt64)bytes {
    double doubleBytes = bytes;
    
    NSArray *units = @[
        @"B", @"KB", @"MB", @"GB", @"TB", @"PB", @"EB"
    ];
    
    UInt8 unitPosition = 0;
    
    while (doubleBytes > 1000) {
        doubleBytes /= 1000;
        unitPosition += 1;
    }
    
    return [NSString stringWithFormat:@"%.2f %@",
            doubleBytes,
            [units objectAtIndex:unitPosition]
    ];
}

@end
