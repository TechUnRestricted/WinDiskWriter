//
//  HDIUtil.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface HDIUtil: NSObject {
    NSString *_imagePath;
    NSString *_mountPoint;
    NSString *_BSDEntry;
    NSString *_volumeKind;
}

@property(strong, nonatomic, readwrite) NSString *hdiutilPath;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithImagePath: (NSString *)imagePath;
- (BOOL)attachImageWithArguments: (NSArray * _Nullable)arguments;
- (BOOL)attachImage;

- (NSString *)getImagePath;

@end

NS_ASSUME_NONNULL_END
