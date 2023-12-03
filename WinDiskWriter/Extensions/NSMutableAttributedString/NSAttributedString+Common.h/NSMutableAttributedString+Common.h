//
//  NSAttributedString.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 21.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (Common)

+ (NSMutableAttributedString *)attributedStringWithString: (NSString *)string
                                                   weight: (NSInteger)weight
                                                     size: (CGFloat)size;

+ (NSMutableAttributedString *)attributedStringWithNormalFormatting: (NSString *)string;

@end

NS_ASSUME_NONNULL_END
