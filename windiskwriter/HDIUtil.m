//
//  HDIUtil.m
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDIUtil.h"

@implementation HDIUtil: NSObject

- (instancetype)initWithImagePath: (NSString *)imagePath {
    _imagePath = imagePath;
    
    return self;
}

- (NSString *)getImagePath {
    return _imagePath;
}

@end

