//
//  WimlibSplitInfo.h
//  windiskwriter
//
//  Created by Macintosh on 31.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WimlibWrapper.h"
#import "wimlib.h"

NS_ASSUME_NONNULL_BEGIN

@interface WimlibSplitInfo : NSObject

@property (readwrite, nonatomic) struct wimlib_progress_info_split lastSplittedPartInfo;
@property (readwrite, nonatomic) WimLibWrapperSplitImageCallback callback;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCallback: (WimLibWrapperSplitImageCallback)callback;

@end

NS_ASSUME_NONNULL_END
