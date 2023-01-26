//
//  HDIUtil.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#ifndef HDIUtil_h
#define HDIUtil_h

@interface HDIUtil: NSObject {
    NSString *_imagePath;
}

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithImagePath: (NSString *)imagePath;
- (NSString *)getImagePath;

@end

#endif /* HDIUtil_h */
