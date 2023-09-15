//
//  AutoUnattendBuilder.h
//  windiskwriter
//
//  Created by Macintosh on 14.09.2023.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AutoUnattendBuilder : NSObject

/* Bypass options */
@property (nonatomic, readwrite) BOOL bypassTPMCheck;
@property (nonatomic, readwrite) BOOL bypassSecureBoot;
@property (nonatomic, readwrite) BOOL bypassRAMCheck;
@property (nonatomic, readwrite) BOOL bypassCPUCheck;
@property (nonatomic, readwrite) BOOL bypassStorageCheck;

/* User Data options */
@property (nonatomic, readwrite) BOOL acceptEULA;
@property (nonatomic, readwrite) BOOL skipProductKeyCheck;

/* Out-of-Box Experience */
@property (nonatomic, readwrite) BOOL hideOnlineAccountScreens;
@property (nonatomic, readwrite) BOOL hideWirelessSetup;

- (NSXMLElement *)buildXML;

@end

NS_ASSUME_NONNULL_END
