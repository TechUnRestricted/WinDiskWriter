//
//  DebugSystem.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

#ifdef DEBUG
    #define DebugLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
    #define DebugLog(...) {}
#endif

NS_ASSUME_NONNULL_END
