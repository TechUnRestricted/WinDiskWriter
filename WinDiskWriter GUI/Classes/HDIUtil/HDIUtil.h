//
//  HDIUtil.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface HDIUtil: NSObject

@property (copy, nonatomic, readwrite) NSString *hdiutilPath;
@property (copy, nonatomic, readwrite) NSString *imagePath;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithImagePath: (NSString *)imagePath;

- (BOOL)attachImageWithArguments: (NSArray * _Nullable)arguments
                           error: (NSError *_Nullable *_Nullable)error;

- (BOOL)attachImageWithError: (NSError *_Nullable *_Nullable)attachImageError;


- (NSString *)BSDEntry;
- (NSString *)mountPoint;
- (NSString *)volumeKind;

@end

NS_ASSUME_NONNULL_END
