//
//  DebugSystem.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

#ifdef DEBUG
#   define DebugLog(...) NSLog(__VA_ARGS__)
#else
#   define DebugLog(...) (void)0
#endif

NS_ASSUME_NONNULL_END
