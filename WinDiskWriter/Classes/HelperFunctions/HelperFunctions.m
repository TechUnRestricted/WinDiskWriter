//
//  HelperFunctions.m
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "LocalizedStrings.h"
#import "HelperFunctions.h"
#import "NSString+Common.h"
#import "NSError+Common.h"
#import <AppKit/AppKit.h>
#import "DiskManager.h"
#import "Constants.h"
#import "HDIUtil.h"

NSString * const MSDOSCompliantSymbols = @"ABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";

@implementation HelperFunctions

+ (BOOL)hasElevatedRights {
    return geteuid() == 0;
}

+ (void)openDonationsPage {
    NSURL *url = [NSURL URLWithString: @"https://github.com/TechUnRestricted/windiskwriter"];
    [[NSWorkspace sharedWorkspace] openURL: url];
}

+ (void)printTimeElapsedWhenRunningCode: (NSString *)title
                              operation: (void (^)(void))operation {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    operation();
    CFAbsoluteTime timeElapsed = CFAbsoluteTimeGetCurrent() - startTime;
    
    // Doesn't need to be translated, since it's only used for debugging purposes
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
            *error = [NSError errorWithStringValue: [LocalizedStrings errorTextApplicationArgumentsListIsEmpty]];
        }
        
        return NO;
    }
    
    NSString *executablePath = [argumentsList firstObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath: executablePath]) {
        if (error) {
            *error = [NSError errorWithStringValue: [LocalizedStrings errorTextApplicationArgumentsBadStructure]];
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
            executionErrorString = [LocalizedStrings authorizationErrorInvalidSet];
            break;
        case errAuthorizationInvalidRef:
            executionErrorString = [LocalizedStrings authorizationErrorInvalidRef];
            break;
        case errAuthorizationInvalidTag:
            executionErrorString = [LocalizedStrings authorizationErrorInvalidTag];
            break;
        case errAuthorizationInvalidPointer:
            executionErrorString = [LocalizedStrings authorizationErrorInvalidPointer];
            break;
        case errAuthorizationDenied:
            executionErrorString = [LocalizedStrings authorizationErrorDenied];
            break;
        case errAuthorizationCanceled:
            executionErrorString = [LocalizedStrings authorizationErrorCanceled];
            break;
        case errAuthorizationInteractionNotAllowed:
            executionErrorString = [LocalizedStrings authorizationErrorInteractionNotAllowed];
            break;
        case errAuthorizationInternal:
            executionErrorString = [LocalizedStrings authorizationErrorInternal];
            break;
        case errAuthorizationExternalizeNotAllowed:
            executionErrorString = [LocalizedStrings authorizationErrorExternalizeNotAllowed];
            break;
        case errAuthorizationInternalizeNotAllowed:
            executionErrorString = [LocalizedStrings authorizationErrorInternalizeNotAllowed];
            break;
        case errAuthorizationInvalidFlags:
            executionErrorString = [LocalizedStrings authorizationErrorInvalidFlags];
            break;
        case errAuthorizationToolExecuteFailure:
            executionErrorString = [LocalizedStrings authorizationErrorToolExecuteFailure];
            break;
        case errAuthorizationToolEnvironmentError:
            executionErrorString = [LocalizedStrings authorizationErrorToolEnvironmentError];
            break;
        case errAuthorizationBadAddress:
            executionErrorString = [LocalizedStrings authorizationErrorBadAddress];
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
            // ERROR_FILE_OR_DIRECTORY_DOESNT_EXIST
            *error = [NSError errorWithStringValue: [LocalizedStrings errorFileOrDirectoryDoesntExistWithArgument1: sourcePath]];
        }
        
        return NULL;
    }
    
    if (isDirectory) {
        return sourcePath;
    }
    
    if (![[[sourcePath lowercaseString] pathExtension] isEqualToString: @"iso"]) {
        if (error) {
            *error = [NSError errorWithStringValue: [LocalizedStrings errorTextFileTypeIsNotIso]];
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
                *error = [NSError errorWithStringValue: [LocalizedStrings errorTextDestinationPathDoesNotExist]];
            }
            
            return NULL;
        }
        
        /* Received device destination path was defined as Mounted Volume. */
        if (@available(macOS 10.7, *)) {
            return [[DiskManager alloc] initWithVolumePath:devicePath];
        } else {
            // TODO: Fix Mac OS X 10.6 Snow Leopard support
            if (error) {
                *error = [NSError errorWithStringValue: [LocalizedStrings errorTextInitWithVolumePathUnsupported]];
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
