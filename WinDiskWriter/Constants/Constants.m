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

NSString * const APPLICATION_NAME = @"WinDiskWriter";

NSString * const PACKAGE_NAME = @"com.techunrestricted.windiskwriter";
NSString * const DEVELOPER_NAME = @"TechUnRestricted";

NSString * const PACKAGE_VERSION = @"1.2";
NSString * const NSLocalizedDescriptionKey = @"Reason";

NSString * const FORGOT_SOMETHING_TITLE = @"You forgot something...";
NSString * const PATH_FIELD_IS_EMPTY_SUBTITLE = @"The path to the Windows Image or Directory was not specified.";
NSString * const PATH_DOES_NOT_EXIST_SUBTITLE = @"The Path to the Image or Folder you entered does not exist.";
NSString * const CHECK_DATA_CORRECTNESS_TITLE = @"Check the correctness of the entered data.";
NSString * const NO_AVAILABLE_DEVICES_TITLE = @"No writable devices found.";
NSString * const PRESS_UPDATE_BUTTON_SUBTITLE = @"Connect a compatible USB device and click on the Update button.";
NSString * const BSD_DEVICE_IS_NO_LONGER_AVAILABLE_TITLE = @"Chosen Device is no longer available.";
NSString * const BSD_DEVICE_INFO_IS_OUTDATED_OR_INVALID = @"The information about this device is outdated or invalid.";

NSString * const IMAGE_VERIFICATION_ERROR_TITLE = @"Can't verify this Image.";
NSString * const DISK_ERASE_FAILURE_TITLE = @"Can't erase the destination device.";
NSString * const DISK_ERASE_SUCCESS_TITLE = @"The destination device was successfully erased.";

NSString * const IMAGE_WRITING_SUCCESS_TITLE = @"Image writing completed successfully";
NSString * const IMAGE_WRITING_SUCCESS_SUBTITLE = @"Do not forget to properly remove the device to avoid data corruption";

NSString * const IMAGE_WRITING_FAILURE_TITLE = @"Something went wrong while writing files to the destination device.";

NSString * const BUTTON_START_TITLE = @"Start";
NSString * const BUTTON_STOP_TITLE = @"Stop";
NSString * const BUTTON_STOPPING_TITLE = @"Stopping";

NSString * const STOP_PROCESS_PROMPT_TITLE = @"Do you want to stop the process?";
NSString * const STOP_PROCESS_PROMPT_SUBTITLE = @"You will need to wait until the last file finish the copying.";
NSString * const BUTTON_DISMISS_TITLE = @"Dismiss";
NSString * const BUTTON_SCHEDULE_CANCELLATION_TITLE = @"Schedule the cancellation";

NSString * const START_PROCESS_PROMPT_TITLE = @"Are you sure you want to start?";
NSString * const START_PROCESS_PROMPT_SUBTITLE = @"You will lose all data on the selected device.";
NSString * const BUTTON_CANCEL_TITLE = @"Cancel";

NSString * const PARTITION_SCHEME_TYPE_MBR_TITLE = @"MBR";
NSString * const PARTITION_SCHEME_TYPE_GPT_TITLE = @"GPT";

NSString * const FILESYSTEM_TYPE_FAT32_TITLE = @"FAT32";
NSString * const FILESYSTEM_TYPE_EXFAT_TITLE = @"ExFAT";

NSString * const MENU_ITEM_QUIT_TITLE = @"Quit";
NSString * const MENU_ITEM_ABOUT_TITLE = @"About";

NSString * const MENU_EDIT_TITLE = @"Edit";
NSString * const MENU_ITEM_CUT_TITLE = @"Cut";
NSString * const MENU_ITEM_COPY_TITLE = @"Copy";
NSString * const MENU_ITEM_PASTE_TITLE = @"Paste";
NSString * const MENU_ITEM_SELECT_ALL_TITLE = @"Select All";

NSString * const MENU_WINDOW_TITLE = @"Window";
NSString * const MENU_MINIMIZE_TITLE = @"Minimize";
NSString * const MENU_HIDE_TITLE = @"Hide";

NSString * const MENU_DONATE_ME_TITLE = @"❤️ Donate Me ❤️";
NSString * const MENU_ITEM_OPEN_DONATION_WEB_PAGE_TITLE = @"Open Donation Web Page";

@end
