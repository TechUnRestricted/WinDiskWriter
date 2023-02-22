//
//  DWFile.h
//  windiskwriter
//
//  Created by Macintosh on 18.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWFile : NSObject

@property (nonatomic, strong, readonly) NSString *_Nonnull sourcePath;
@property (nonatomic, strong, readwrite) NSFileAttributeType fileType;
@property (nonatomic, readwrite) uint64_t size;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSourcePath: (NSString *_Nonnull)sourcePath;

@end

NS_ASSUME_NONNULL_END
