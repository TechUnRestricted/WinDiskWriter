//
//  HDIUtil.m
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandLine.h"
#import "Constants.h"
#import "HDIUtil.h"

@implementation HDIUtil: NSObject

- (BOOL)attachImageWithArguments: (NSArray * _Nullable)arguments
                           error: (NSError *_Nullable *_Nullable)error {
    NSMutableArray *localArgumentsArray = [NSMutableArray arrayWithArray:@[@"attach", _imagePath, @"-plist"]];
    
    if (arguments != NULL) {
        /* Adding custom arguments to the HDIUtil attach command */
        [localArgumentsArray addObjectsFromArray:arguments];
    }
    
    struct CommandLineReturn commandLineReturn = [CommandLine execute:_hdiutilPath arguments:localArgumentsArray];
    
    if (commandLineReturn.terminationStatus != EXIT_SUCCESS) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: -1
                                     userInfo: @{DEFAULT_ERROR_KEY:
                                                     @"hdiutil exited not with EXIT_SUCCESS status."}];
        }
        return NO;
    }
    
    NSString *plistLoadErrorDescription;
    NSDictionary *plist = [NSPropertyListSerialization
                           propertyListFromData: commandLineReturn.data
                           mutabilityOption: NSPropertyListImmutable
                           format: NULL
                           errorDescription: &plistLoadErrorDescription];
    
    if (plist == NULL) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: -1
                                     userInfo: @{DEFAULT_ERROR_KEY:
                                                     @"An error occurred while reading output from hdiutil."}];
        }
        return NO;
    }
    
    /* Output from hdiutil was successfully parsed into NSDictionary */
    
    NSArray *systemEntities = [plist objectForKey:@"system-entities"];
    if (systemEntities == NULL) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: -1
                                     userInfo: @{DEFAULT_ERROR_KEY:
                                                     @"Can't load \"system-entities\" from parsed plist."}];
        }
        return NO;
    }
    
    if ([systemEntities count] == 0) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: -1
                                     userInfo: @{DEFAULT_ERROR_KEY:
                                                     @"This image does not contain any System Entity."}];
        }
        return NO;
    }
    
    if ([systemEntities count] > 1) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: -1
                                     userInfo: @{DEFAULT_ERROR_KEY:
                                                     @"The number of System Entities in this image is >1. The required Entity could not be determined. Try to specify the path to an already mounted image."}];
        }
        return NO;
    }
    
    NSDictionary *firstSystemEntity = [systemEntities firstObject];
    _BSDEntry = [firstSystemEntity objectForKey:@"dev-entry"];
    _mountPoint = [firstSystemEntity objectForKey:@"mount-point"];
    _volumeKind = [firstSystemEntity objectForKey:@"volume-kind"];
    
    return YES;
}

- (BOOL)attachImageWithError: (NSError *_Nullable *_Nullable)attachImageError {
    NSError *attachWithArgumentsError = NULL;
    [self attachImageWithArguments:NULL
                             error: &attachWithArgumentsError];
    if (attachImageError != NULL) {
        *attachImageError = attachWithArgumentsError;
    }
    return YES;
}

- (void)initDefaultProperties {
    _hdiutilPath = @"/usr/bin/hdiutil";
}

- (instancetype)initWithImagePath: (NSString *)imagePath {
    [self initDefaultProperties];
    
    _imagePath = imagePath;
    
    return self;
}

- (NSString *)getImagePath {
    return _imagePath;
}

- (NSString *)getBSDEntry {
    return _BSDEntry;
}

- (NSString *)getMountPoint {
    return _mountPoint;
}

- (NSString *)getVolumeKind {
    return _volumeKind;
}

@end

