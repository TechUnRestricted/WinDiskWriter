//
//  HDIUtil.m
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandLine.h"
#import "HDIUtil.h"
#import "DebugSystem.h"

@implementation HDIUtil: NSObject

- (BOOL)attachImageWithArguments: (NSArray * _Nullable)arguments {
    NSMutableArray *localArgumentsArray = [NSMutableArray arrayWithArray:@[@"attach", _imagePath, @"-plist"]];
    
    if (arguments != NULL) {
        [localArgumentsArray addObjectsFromArray:arguments];
        DebugLog(@"Adding custom arguments to the HDIUtil attach command [%@].", [arguments componentsJoinedByString:@", "]);
    }
    
    NSData *commandLineData = [CommandLine execute:_hdiutilPath withArguments:localArgumentsArray];
    
    NSString *plistLoadErrorDescription;
    NSDictionary *plist = [NSPropertyListSerialization
                           propertyListFromData: commandLineData
                           mutabilityOption: NSPropertyListImmutable
                           format: NULL
                           errorDescription: &plistLoadErrorDescription];
    
    if (plist == NULL) {
        DebugLog(@"An error occurred while reading output from hdiutil. [%@]", plistLoadErrorDescription);
        return NO;
    }
    
    DebugLog(@"Output from hdiutil was successfully parsed into NSDictionary. [%@]", plist);
    
    NSArray *systemEntities = [plist objectForKey:@"system-entities"];
    if (systemEntities == NULL) {
        DebugLog(@"Can't load \"system-entities\" from parsed plist.");
        return NO;
    }
    
    if ([systemEntities count] == 0) {
        DebugLog(@"This image does not contain any System Entity.");
        return NO;
    }
    
    if ([systemEntities count] > 1) {
        DebugLog(@"The number of System Entities in this image is >1. The required Entity could not be determined. Try to specify the path to an already mounted image.");
        return NO;
    }
    
    NSDictionary *firstSystemEntity = [systemEntities firstObject];
    _BSDEntry = [firstSystemEntity objectForKey:@"dev-entry"];
    _mountPoint = [firstSystemEntity objectForKey:@"mount-point"];
    _volumeKind = [firstSystemEntity objectForKey:@"volume-kind"];
    
    return YES;
}

- (BOOL)attachImage {
    [self attachImageWithArguments:NULL];
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

