//
//  DWFile.m
//  windiskwriter
//
//  Created by Macintosh on 18.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "DWFile.h"

@implementation DWFile

- (instancetype)initWithSourcePath: (NSString *_Nonnull)sourcePath {
    
    _sourcePath = sourcePath;
    
    return self;
}

- (NSString *)unitFormattedSize {
    NSArray *units = @[
        @"B", @"KB", @"MB", @"GB", @"TB", @"PB", @"EB"
    ];
    
    UInt8 unitPosition = 0;
    double doubleBytes = _size;

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
