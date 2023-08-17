//
//  DWFile.m
//  windiskwriter
//
//  Created by Macintosh on 18.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "DWFile.h"
#import "HelperFunctions.h"

@implementation DWFile

- (instancetype)initWithSourcePath: (NSString *_Nonnull)sourcePath {
    
    _sourcePath = sourcePath;
    
    return self;
}

- (NSString *)unitFormattedSize {
    return [HelperFunctions unitFormattedSizeFor: _size];
}

@end
