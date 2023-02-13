//
//  CChar2DArray.h
//  windiskwriter
//
//  Created by Macintosh on 13.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CChar2DArray : NSObject
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNSArray: (NSArray *_Nonnull)nsArray;
- (char *_Nullable *_Nullable)getArray;
@end

NS_ASSUME_NONNULL_END
