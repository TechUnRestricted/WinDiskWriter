//
//  NSColor+Common.h
//  ObjectiveC
//
//  Created by Macintosh on 26.02.2023.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSColor(Additions)
- (CGColorRef)toCGColor;
@end

NS_ASSUME_NONNULL_END
