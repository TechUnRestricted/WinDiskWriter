//
//  ArgumentObject.h
//  windiskwriter
//
//  Created by Macintosh on 09.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ArgumentObject : NSObject

@property (strong, nonatomic, readonly) NSString *_Nonnull name;
@property (nonatomic, readonly) int identifier;
@property (nonatomic, readonly) BOOL isRequired;
@property (nonatomic, readonly) BOOL isPaired;
@property (nonatomic, readonly) BOOL isUnique;


- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithName: (NSString *_Nonnull)name
                  identifier: (int)identifier
                  isRequired: (BOOL)isRequired
                    isPaired: (BOOL)isPaired
                    isUnique: (BOOL)isUnique;

@end

NS_ASSUME_NONNULL_END
