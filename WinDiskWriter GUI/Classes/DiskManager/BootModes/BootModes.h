//
//  BootModes.h
//  windiskwriter
//
//  Created by Macintosh on 04.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *BootMode NS_TYPED_ENUM;
extern BootMode const BootModeUEFI;
extern BootMode const BootModeLegacy;

NS_ASSUME_NONNULL_END
