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

+ (CommandLineData *_Nullable)execute: (NSString *)executable
                            arguments: (NSArray *_Nullable)arguments
                            exception: (NSException *_Nullable *_Nullable)nsException {
        
    @try {
        NSTask *task = [[NSTask alloc] init];
        
        NSPipe *standartPipe = [NSPipe pipe];
        [task setStandardOutput: standartPipe];
        
        NSPipe *errorPipe = [NSPipe pipe];
        [task setStandardError: errorPipe];
        
        [task setLaunchPath: executable];
        
        if (arguments) {
            [task setArguments: arguments];
        }
        
        NSFileHandle *fileHandleStandardPipe = [standartPipe fileHandleForReading];
        NSFileHandle *fileHandleErrorPipe = [errorPipe fileHandleForReading];
        
        [task launch];
        [task waitUntilExit];
        
        CommandLineData *commandLineData = [[CommandLineData alloc] initWithProcessIdentifier: [task processIdentifier]
                                                                            terminationStatus: [task terminationStatus]
                                                                            terminationReason: [task terminationReason]
                                                                                 standardData: [fileHandleStandardPipe readDataToEndOfFile]
                                                                                    errorData: [fileHandleErrorPipe readDataToEndOfFile]];
        
        fileHandleStandardPipe = NULL;
        fileHandleErrorPipe = NULL;
        
        return commandLineData;
    } @catch (NSException *exception) {
        /* An error occurred while executing a terminal command */
        if (nsException) {
            *nsException = exception;
        }
    }
    
    return NULL;
}

@end
