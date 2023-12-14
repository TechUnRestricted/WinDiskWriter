//
//  Constants.m
//  windiskwriter
//
//  Created by Macintosh on 18.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "Constants.h"

@implementation Constants

const CGFloat MAIN_CONTENT_SPACING = 6;
const CGFloat CHILD_CONTENT_SPACING = 6;

+ (NSString *_Nullable)valueFromBundleByKey: (NSString *)key {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSDictionary<NSString *, id> *dictionary = [mainBundle infoDictionary];
    
    return [dictionary objectForKey: key];
}

+ (NSString *)applicationName {
    return [Constants valueFromBundleByKey: @"CFBundleExecutable"];
}

+ (NSString *)applicationVersion {
    return [Constants valueFromBundleByKey: @"CFBundleShortVersionString"];
}

+ (NSString *)bundleIndentifier {
    return [Constants valueFromBundleByKey: @"CFBundleIdentifier"];
}

+ (NSString *)developerName {
    return @"TechUnRestricted";
}

NSString * const NSLocalizedDescriptionKey = @"Reason";

NSString * const PARTITION_SCHEME_TYPE_MBR_TITLE = @"MBR";
NSString * const PARTITION_SCHEME_TYPE_GPT_TITLE = @"GPT";

NSString * const FILESYSTEM_TYPE_FAT32_TITLE = @"FAT32";
NSString * const FILESYSTEM_TYPE_EXFAT_TITLE = @"ExFAT";


@end
