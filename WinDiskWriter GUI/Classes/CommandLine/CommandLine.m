//
//  CommandLine.m
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandLine.h"

@implementation CommandLine

+ (struct CommandLineReturn)execute: (NSString *)executable
                          arguments: (NSArray *)arguments {
    struct CommandLineReturn commandLineReturn;
    @try {
        NSTask *task = [[NSTask alloc] init];
        
        NSPipe *standartdPipe = [NSPipe pipe];
        [task setStandardOutput: standartdPipe];

        NSPipe *errorPipe = [NSPipe pipe];
        [task setStandardError: errorPipe];

        [task setLaunchPath: executable];
        [task setArguments: arguments];
        
        NSFileHandle *fileHandleStandardPipe = [standartdPipe fileHandleForReading];
        NSFileHandle *fileHandleErrorPipe = [errorPipe fileHandleForReading];

        [task launch];
        [task waitUntilExit];
        
        commandLineReturn.standardData = [fileHandleStandardPipe readDataToEndOfFile];
        commandLineReturn.errorData = [fileHandleErrorPipe readDataToEndOfFile];

        commandLineReturn.terminationStatus = [task terminationStatus];
        commandLineReturn.processIdentifier = [task processIdentifier];
        commandLineReturn.terminationReason = [task terminationReason];
                
        return commandLineReturn;
    } @catch (NSException *exception) {
        /* An error occurred while executing a terminal command */
    }
    
    return commandLineReturn;
}

@end
