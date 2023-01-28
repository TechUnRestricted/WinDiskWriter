//
//  PartitionSchemes.h
//  windiskwriter
//
//  Created by Macintosh on 28.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *PartitionScheme NS_TYPED_ENUM;
extern PartitionScheme const PartitionSchemeMBR;
extern PartitionScheme const PartitionSchemeGPT;
extern PartitionScheme const PartitionSchemeAPM;

NS_ASSUME_NONNULL_END
