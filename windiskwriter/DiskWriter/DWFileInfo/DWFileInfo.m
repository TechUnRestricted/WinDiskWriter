//
//  DWFileInfo.m
//  windiskwriter
//
//  Created by Macintosh on 18.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "DWFileInfo.h"

@implementation DWFileInfo

- (instancetype)initWithSourcePath: (NSString *_Nonnull)sourcePath
                   destinationPath: (NSString *_Nonnull)destinationPath {
    
    _sourcePath = sourcePath;
    _destinationPath = destinationPath;
    
    return self;
}

@end
