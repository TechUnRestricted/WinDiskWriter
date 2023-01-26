//
//  CommandLine.m
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandLine.h"
#import "DebugSystem.h"

@implementation CommandLine

+ (NSString * _Nullable)execute: (NSString *)executable
                  withArguments: (NSArray *)arguments {
    @try {
        NSPipe *pipe = [NSPipe pipe];

        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath: executable];
        [task setArguments: arguments];
        [task setStandardOutput: pipe];

        NSFileHandle *file = [pipe fileHandleForReading];
        [task launch];

        return [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    } @catch (NSException *exception) {
        DebugLog(@"An error occurred while executing a terminal command [Arguments: %@], [Error: {%@, %@}]",
                 [arguments componentsJoinedByString:@", "],
                 [exception reason],
                 [exception name]
        );
    }
    
    return NULL;
}

@end
