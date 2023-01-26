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
    //NSMutableArray *completesetArguments = ["-plist"];
    //[completesetArguments]
    
    NSMutableArray *localArgumentsArray = [NSMutableArray arrayWithArray:@[@"attach", _imagePath, @"-plist"]];
    
    if (arguments != NULL) {
        [localArgumentsArray addObjectsFromArray:arguments];
        DebugLog(@"Adding custom arguments to the HDIUtil attach command.");
    }
    
    NSString *commandLineOutput = [CommandLine execute:_hdiutilPath withArguments:localArgumentsArray];
    [NSDictionary diction]
    
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

@end

