//
//  LocalizedStrings.h
//  WinDiskWriter
//
//  Created by Macintosh on 12.12.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalizedStrings : NSObject

/// @brief Do not forget to properly remove the device to avoid data corruption.;
+ (NSString *)ALERT_SUBTITLE_IMAGE_WRITING_SUCCESS;

/// @brief The Path to the Image or Folder you entered does not exist.;
+ (NSString *)ALERT_SUBTITLE_PATH_DOES_NOT_EXIST;

/// @brief The path to the Windows Image or Directory was not specified.;
+ (NSString *)ALERT_SUBTITLE_PATH_FIELD_IS_EMPTY;

/// @brief Connect a compatible USB device and click on the Update button.;
+ (NSString *)ALERT_SUBTITLE_PRESS_UPDATE_BUTTON;

/// @brief You will need to wait until the last file finish the copying.;
+ (NSString *)ALERT_SUBTITLE_STOP_PROCESS;

/// @brief The information about this device is outdated or invalid.;
+ (NSString *)ALERT_TITLE_BSD_DEVICE_INFO_IS_OUTDATED_OR_INVALID;

/// @brief Chosen Device is no longer available.;
+ (NSString *)ALERT_TITLE_BSD_DEVICE_IS_NO_LONGER_AVAILABLE;

/// @brief Cancel;
+ (NSString *)BUTTON_TITLE_CANCEL;

/// @brief Schedule the cancellation;
+ (NSString *)BUTTON_TITLE_CANCELLATION_SCHEDULE;

/// @brief Choose;
+ (NSString *)BUTTON_TITLE_CHOOSE;

/// @brief Dismiss;
+ (NSString *)BUTTON_TITLE_DISMISS;

/// @brief Start;
+ (NSString *)BUTTON_TITLE_START;

/// @brief Stop;
+ (NSString *)BUTTON_TITLE_STOP;

/// @brief Stopping;
+ (NSString *)BUTTON_TITLE_STOPPING;

/// @brief Check the correctness of the entered data.;
+ (NSString *)ALERT_TITLE_CHECK_DATA_CORRECTNESS;

/// @brief Can't erase the destination device.;
+ (NSString *)ALERT_TITLE_DISK_ERASE_FAILURE;

/// @brief The destination device was successfully erased.;
+ (NSString *)PROGRESS_TITLE_DISK_ERASE_SUCCESS;

/// @brief You forgot something...;
+ (NSString *)ALERT_TITLE_FORGOT_SOMETHING;

/// @brief Can't verify this Image.;
+ (NSString *)ALERT_TITLE_IMAGE_VERIFICATION_ERROR;

/// @brief Something went wrong while writing files to the destination device.;
+ (NSString *)ALERT_TITLE_IMAGE_WRITING_FAILURE;

/// @brief Image writing completed successfully.;
+ (NSString *)ALERT_TITLE_IMAGE_WRITING_SUCCESS;

/// @brief Image File or Directory;
+ (NSString *)INPUTVIEW_PLACEHOLDER_IMAGE_FILE_OR_DIRECTORY;

/// @brief Windows Image;
+ (NSString *)LABELVIEW_TITLE_WINDOWS_IMAGE;

/// @brief ❤️ Donate Me ❤️;
+ (NSString *)MENU_TITLE_DONATE_ME;

/// @brief Edit;
+ (NSString *)MENU_TITLE_EDIT;

/// @brief Hide;
+ (NSString *)MENU_TITLE_HIDE;

/// @brief About;
+ (NSString *)MENU_TITLE_ITEM_ABOUT;

/// @brief Copy;
+ (NSString *)MENU_TITLE_ITEM_COPY;

/// @brief Cut;
+ (NSString *)MENU_TITLE_ITEM_CUT;

/// @brief Open Donation Web Page;
+ (NSString *)MENU_TITLE_ITEM_OPEN_DONATION_WEB_PAGE;

/// @brief Paste;
+ (NSString *)MENU_TITLE_ITEM_PASTE;

/// @brief Quit;
+ (NSString *)MENU_TITLE_ITEM_QUIT;

/// @brief Select All;
+ (NSString *)MENU_TITLE_ITEM_SELECT_ALL;

/// @brief Minimize;
+ (NSString *)MENU_TITLE_MINIMIZE;

/// @brief Window;
+ (NSString *)MENU_TITLE_WINDOW;

/// @brief No writable devices found.;
+ (NSString *)ALERT_TITLE_NO_WRITABLE_DEVICES;

/// @brief Are you sure you want to start?;
+ (NSString *)ALERT_SUBTITLE_PROMPT_START_PROCESS;

/// @brief Ready for action;
+ (NSString *)PROGRESS_TITLE_READY_FOR_ACTION;

/// @brief Do you want to stop the process?;
+ (NSString *)ALERT_TITLE_STOP_PROCESS;

/// @brief Target Device;
+ (NSString *)LABELVIEW_TITLE_TARGET_DEVICE;

/// @brief Update;
+ (NSString *)BUTTON_TITLE_UPDATE;

/// @brief Patch Installer Requirements;
+ (NSString *)CHECKBOXVIEW_TITLE_PATCH_INSTALLER_REQUIREMENTS;

/// @brief Remove TPM, Secure Boot and RAM requirements from the installer.\n(Windows 11 only);
+ (NSString *)CHECKBOXVIEW_TOOLTIP_PATCH_INSTALLER_REQUIREMENTS;

/// @brief Install Legacy Boot Sector;
+ (NSString *)CHECKBOXVIEW_TITLE_INSTALL_LEGACY_BOOT_SECTOR;

/// @brief Add support for older firmwares that don't support booting from EFI.;
+ (NSString *)CHECKBOXVIEW_TOOLTIP_INSTALL_LEGACY_BOOT_SECTOR;

/// @brief Desired filesystem for the destination device.\n(FAT32 is the best choice for compatibility);
+ (NSString *)TOOLTIP_FRAMELAYOUT_FORMATTING_SECTION;

/// @brief File System;
+ (NSString *)LABELVIEW_TITLE_FILESYSTEM;

/// @brief Failed to restart;
+ (NSString *)ALERT_TITLE_FAILED_TO_RESTART;

/// @brief This option requires the application to be relaunched with Root Permissions;
+ (NSString *)ALERT_TITLE_REQUIRE_RESTART_AS_ROOT;

/// @brief All unsaved changes will be lost;
+ (NSString *)ALERT_SUBTITLE_REQUIRE_RESTART_AS_ROOT;

/// @brief Relaunch;
+ (NSString *)BUTTON_TITLE_RELAUNCH;

/// @brief Formatting the drive;
+ (NSString *)PROGRESS_TITLE_FORMATTING_THE_DRIVE;

/// @brief Create directory;
+ (NSString *)PROGRESS_TITLE_CREATE_DIRECTORY;

/// @brief Write File;
+ (NSString *)PROGRESS_TITLE_WRITE_FILE;

/// @brief Split Image;
+ (NSString *)PROGRESS_TITLE_SPLIT_IMAGE;

/// @brief Extract Bootloader;
+ (NSString *)PROGRESS_TITLE_EXTRACT_BOOTLOADER;

/// @brief Patch Installer Requirements;
+ (NSString *)PROGRESS_TITLE_PATCH_INSTALLER_REQUIREMENTS;

/// @brief Install Legacy Bootloader;
+ (NSString *)PROGRESS_TITLE_INSTALL_LEGACY_BOOTLOADER;

/// @brief (Error message: '%@');
+ (NSString *)LOGVIEW_ROW_PARTIAL_TITLE_ERROR_MESSAGE: (NSString *)argument;

/// @brief Image was successfully mounted on '%@'.;
+ (NSString *)LOGVIEW_ROW_TITLE_IMAGE_MOUNT_SUCCESS;

/// @brief Generated partition name: '%@'.;
+ (NSString *)LOGVIEW_ROW_TITLE_GENERATED_PARTITION_NAME;

/// @brief Target partition path: '%@'.;
+ (NSString *)LOGVIEW_ROW_TITLE_TARGET_PARTITION_PATH;

/// @brief Device %@ (%@ %@) is ready to be erased with the following properties: (partition_name: '%@', partition_scheme: '%@', filesystem: '%@', patch_security_checks: '%d', install_legacy_boot: '%d').;
+ (NSString *)LOGVIEW_ROW_TITLE_DISK_ERASE_OPERATION_OPTIONS;

/// @brief A problem occurred when writing the file to disk;
+ (NSString *)ALERT_TITLE_WRITE_FILE_PROBLEM_OCCURRED;

/// @brief Would you like to skip this file, or stop writing?;
+ (NSString *)ALERT_SUBTITLE_WRITE_FILE_PROBLEM_OCCURRED;

/// @brief (Reason: %@);
+ (NSString *)PLACEHOLDER_REASON: (NSString *)argument;

/// @brief Stop Writing;
+ (NSString *)ALERT_BUTTON_TITLE_STOP_WRITING;

/// @brief Skip File;
+ (NSString *)ALERT_BUTTON_TITLE_SKIP_FILE;

/// @brief Clearing the device picker list.;
+ (NSString *)LOGVIEW_ROW_TITLE_CLEARING_DEVICE_PICKER_LIST;

/// @brief Found devices;
+ (NSString *)LOGVIEW_ROW_PARTIAL_TITLE_FOUND_DEVICES;

@end

NS_ASSUME_NONNULL_END
