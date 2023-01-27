//
//  DAWrapper.h
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DAWrapper : NSObject
- (instancetype)init NS_UNAVAILABLE;
- (instancetype _Nullable)initWithBSDName: (NSString * _Nonnull)bsdName;
- (instancetype _Nullable)initWithVolumePath: (NSString * _Nonnull)volumePath;
@end

NS_ASSUME_NONNULL_END
