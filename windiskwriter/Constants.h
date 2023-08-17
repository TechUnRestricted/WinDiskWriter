//
//  Constants.h
//  windiskwriter
//
//  Created by Macintosh on 05.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern NSString * const APPLICATION_NAME;

extern NSString * const PACKAGE_NAME;
extern NSString * const PACKAGE_VERSION;
extern NSString * const DEFAULT_ERROR_KEY;

extern NSString * const FORGOT_SOMETHING_TITLE;
extern NSString * const PATH_FIELD_IS_EMPTY_SUBTITLE;
extern NSString * const PATH_DOES_NOT_EXIST_SUBTITLE;
extern NSString * const CHECK_DATA_CORRECTNESS_TITLE;
extern NSString * const NO_AVAILABLE_DEVICES_TITLE;
extern NSString * const PRESS_UPDATE_BUTTON_SUBTITLE;
extern NSString * const BSD_DEVICE_IS_NO_LONGER_AVAILABLE_TITLE;
extern NSString * const IMAGE_VERIFICATION_ERROR_TITLE;
extern NSString * const DISK_ERASE_FAILURE_TITLE;
extern NSString * const DISK_ERASE_SUCCESS_TITLE;

extern NSString * const IMAGE_WRITING_SUCCESS_TITLE;
extern NSString * const IMAGE_WRITING_SUCCESS_SUBTITLE;

extern NSString * const IMAGE_WRITING_FAILURE_TITLE;

extern NSString * const BUTTON_START_TITLE;
extern NSString * const BUTTON_STOP_TITLE;
extern NSString * const BUTTON_STOPPING_TITLE;

extern NSString * const STOP_PROCESS_PROMPT_TITLE;
extern NSString * const STOP_PROCESS_PROMPT_SUBTITLE;
extern NSString * const BUTTON_DISMISS_TITLE;
extern NSString * const BUTTON_SCHEDULE_CANCELLATION_TITLE;

extern NSString * const START_PROCESS_PROMPT_TITLE;
extern NSString * const START_PROCESS_PROMPT_SUBTITLE;
extern NSString * const BUTTON_CANCEL_TITLE;

@end

#endif /* Constants_h */
