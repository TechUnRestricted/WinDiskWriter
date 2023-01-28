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

+ (struct CommandLineReturn)execute: (NSString *)executable
                      withArguments: (NSArray *)arguments {
    struct CommandLineReturn commandLineReturn;
    @try {
        NSPipe *pipe = [NSPipe pipe];
        
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath: executable];
        [task setArguments: arguments];
        [task setStandardOutput: pipe];
        
        NSFileHandle *file = [pipe fileHandleForReading];
        [task launch];
        
        commandLineReturn.data = [file readDataToEndOfFile];
        commandLineReturn.terminationStatus = [task terminationStatus];
        commandLineReturn.processIdentifier = [task processIdentifier];
        commandLineReturn.terminationReason = [task terminationReason];
        
        return commandLineReturn;
    } @catch (NSException *exception) {
        DebugLog(@"An error occurred while executing a terminal command [Arguments: %@], [Error: {%@, %@}]",
                 [arguments componentsJoinedByString:@", "],
                 [exception reason],
                 [exception name]
                 );
    }
    
    return commandLineReturn;
}

@end
