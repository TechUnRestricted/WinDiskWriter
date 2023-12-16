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

/// @brief Do not forget to properly remove the device to avoid data corruption.
+ (NSString *)alertSubtitleImageWritingSuccess;

/// @brief The Path to the Image or Folder you entered does not exist.
+ (NSString *)alertSubtitlePathDoesNotExist;

/// @brief The path to the Windows Image or Directory was not specified.
+ (NSString *)alertSubtitlePathFieldIsEmpty;

/// @brief Connect a compatible USB device and click on the Update button.
+ (NSString *)alertSubtitlePressUpdateButton;

/// @brief You will need to wait until the last file finish the copying.
+ (NSString *)alertSubtitleStopProcess;

/// @brief The information about this device is outdated or invalid.
+ (NSString *)alertTitleBsdDeviceInfoIsOutdatedOrInvalid;

/// @brief Chosen Device is no longer available.
+ (NSString *)alertTitleBsdDeviceIsNoLongerAvailable;

/// @brief Cancel
+ (NSString *)buttonTitleCancel;

/// @brief Schedule the cancellation
+ (NSString *)buttonTitleCancellationSchedule;

/// @brief Choose
+ (NSString *)buttonTitleChoose;

/// @brief Dismiss
+ (NSString *)buttonTitleDismiss;

/// @brief Start
+ (NSString *)buttonTitleStart;

/// @brief Stop
+ (NSString *)buttonTitleStop;

/// @brief Stopping
+ (NSString *)buttonTitleStopping;

/// @brief Check the correctness of the entered data.
+ (NSString *)alertTitleCheckDataCorrectness;

/// @brief Can't erase the destination device.
+ (NSString *)alertTitleDiskEraseFailure;

/// @brief The destination device was successfully erased.
+ (NSString *)progressTitleDiskEraseSuccess;

/// @brief You forgot something...
+ (NSString *)alertTitleForgotSomething;

/// @brief Can't verify this Image.
+ (NSString *)alertTitleImageVerificationError;

/// @brief Something went wrong while writing files to the destination device.
+ (NSString *)alertTitleImageWritingFailure;

/// @brief Image writing completed successfully.
+ (NSString *)alertTitleImageWritingSuccess;

/// @brief Image File or Directory
+ (NSString *)inputviewPlaceholderImageFileOrDirectory;

/// @brief Windows Image
+ (NSString *)labelviewTitleWindowsImage;

/// @brief ❤️ Donate Me ❤️
+ (NSString *)menuTitleDonateMe;

/// @brief Edit
+ (NSString *)menuTitleEdit;

/// @brief Hide
+ (NSString *)menuTitleHide;

/// @brief About
+ (NSString *)menuTitleItemAbout;

/// @brief Copy
+ (NSString *)menuTitleItemCopy;

/// @brief Cut
+ (NSString *)menuTitleItemCut;

/// @brief Open Donation Web Page
+ (NSString *)menuTitleItemOpenDonationWebPage;

/// @brief Paste
+ (NSString *)menuTitleItemPaste;

/// @brief Quit
+ (NSString *)menuTitleItemQuit;

/// @brief Select All
+ (NSString *)menuTitleItemSelectAll;

/// @brief Minimize
+ (NSString *)menuTitleMinimize;

/// @brief Window
+ (NSString *)menuTitleWindow;

/// @brief No writable devices found.
+ (NSString *)alertTitleNoWritableDevices;

/// @brief Are you sure you want to start?
+ (NSString *)alertSubtitlePromptStartProcess;

/// @brief Ready for action
+ (NSString *)progressTitleReadyForAction;

/// @brief Do you want to stop the process?
+ (NSString *)alertTitleStopProcess;

/// @brief Target Device
+ (NSString *)labelviewTitleTargetDevice;

/// @brief Update
+ (NSString *)buttonTitleUpdate;

/// @brief Patch Installer Requirements
+ (NSString *)checkboxviewTitlePatchInstallerRequirements;

/// @brief Remove TPM, Secure Boot and RAM requirements from the installer.\n(Windows 11 only)
+ (NSString *)checkboxviewTooltipPatchInstallerRequirements;

/// @brief Install Legacy BIOS Boot Sector
+ (NSString *)checkboxviewTitleInstallLegacyBootSector;

/// @brief Add support for older firmwares that don't support booting from EFI.
+ (NSString *)checkboxviewTooltipInstallLegacyBootSector;

/// @brief Desired filesystem for the destination device.\n(FAT32 is the best choice for compatibility)
+ (NSString *)tooltipFramelayoutFormattingSection;

/// @brief File System
+ (NSString *)labelviewTitleFilesystem;

/// @brief Failed to restart
+ (NSString *)alertTitleFailedToRestart;

/// @brief This option requires the application to be relaunched with Root Permissions
+ (NSString *)alertTitleRequireRestartAsRoot;

/// @brief All unsaved changes will be lost
+ (NSString *)alertSubtitleRequireRestartAsRoot;

/// @brief Relaunch
+ (NSString *)buttonTitleRelaunch;

/// @brief Formatting the drive
+ (NSString *)progressTitleFormattingTheDrive;

/// @brief Create directory
+ (NSString *)progressTitleCreateDirectory;

/// @brief Write File
+ (NSString *)progressTitleWriteFile;

/// @brief Split Image
+ (NSString *)progressTitleSplitImage;

/// @brief Extract Bootloader
+ (NSString *)progressTitleExtractBootloader;

/// @brief Patch Installer Requirements
+ (NSString *)progressTitlePatchInstallerRequirements;

/// @brief Install Legacy Bootloader
+ (NSString *)progressTitleInstallLegacyBootloader;

/// @brief (Error message: '%@')
+ (NSString *)logviewRowPartialTitleErrorMessageWithArgument1:(NSString *)argument1;

/// @brief Image was successfully mounted
+ (NSString *)logviewRowTitleImageMountSuccess;

/// @brief Generated partition name
+ (NSString *)logviewRowTitleGeneratedPartitionName;

/// @brief Target partition path
+ (NSString *)logviewRowTitleTargetPartitionPath;

/// @brief Device %@ (%@ %@) is ready to be erased with the following properties: (partition_name: '%@', partition_scheme: '%@', filesystem: '%@', patch_installer_requirements: '%d', install_legacy_boot: '%d').
+ (NSString *)logviewRowTitleDiskEraseOperationOptionsWithArgument1:(NSString *)argument1 argument2:(NSString *)argument2 argument3:(NSString *)argument3 argument4:(NSString *)argument4 argument5:(NSString *)argument5 argument6:(NSString *)argument6 argument7:(NSInteger)argument7 argument8:(NSInteger)argument8;

/// @brief A problem occurred when writing the file to disk
+ (NSString *)alertTitleWriteFileProblemOccurred;

/// @brief Would you like to skip this file, or stop writing?
+ (NSString *)alertSubtitleWriteFileProblemOccurred;

/// @brief (Reason: %@)
+ (NSString *)placeholderReasonWithArgument1:(NSString *)argument1;

/// @brief Stop Writing
+ (NSString *)alertButtonTitleStopWriting;

/// @brief Skip File
+ (NSString *)alertButtonTitleSkipFile;

/// @brief Clearing the device picker list.
+ (NSString *)logviewRowTitleClearingDevicePickerList;

/// @brief Found devices
+ (NSString *)logviewRowPartialTitleFoundDevices;

/// @brief Close
+ (NSString *)menuTitleItemClose;

/// @brief Can't determine the BSD path for the destination device.
+ (NSString *)errorTextCantDetermineBsdPath;

/// @brief Bootloader MBR file doesn't exist.
+ (NSString *)errorTextBootloaderMbrFileDoesntExist;

/// @brief Bootloader Grldr file doesn't exist.
+ (NSString *)errorTextBootloaderGrldrFileDoesntExist;

/// @brief Bootloader Menu file doesn't exist.
+ (NSString *)errorTextBootloaderMenuFileDoesntExist;

/// @brief Can't open the input handle for the MBR file.
+ (NSString *)errorTextBootloaderMbrOpenFileInputHandleFailure;

/// @brief Can't open the output device.
+ (NSString *)errorTextOutputDeviceOpenFailure;

/// @brief Can't get the available space for the specified path.
+ (NSString *)errorTextGetAvailableSpaceFailure;

/// @brief Not enough free disk space.
+ (NSString *)errorTextDiskSpaceNotEnough;

/// @brief Can't copy this file to the FAT32 volume due to filesystem limitations.
+ (NSString *)errorTextFileCopyFailureOverFat32SizeLimit;

/// @brief Couldn't open the source file.
+ (NSString *)errorTextOpenSourceFileFailure;

/// @brief Couldn't open the destination file path.
+ (NSString *)errorTextOpenDestinationPathFailure;

/// @brief Couldn't allocate memory for buffer.
+ (NSString *)errorTextAllocateMemoryBufferFailure;

/// @brief Can't write data to destination path.
+ (NSString *)errorTextWriteDestinationPathDataFailure;

/// @brief Splitting Windows Install Images with .esd and .swm extensions is currently not supported.
+ (NSString *)errorTextSplittingEsdSwmNotSupported;

/// @brief Destination path does not exist.
+ (NSString *)errorTextDestinationPathDoesNotExist;

/// @brief Can't get the available space for the destination disk.
+ (NSString *)errorTextGetAvailableDestinationDiskSpaceFailure;

/// @brief Source is too large for the destination disk.
+ (NSString *)errorTextSourceIsTooLargeForTheDestinationDisk;

/// @brief Version
+ (NSString *)labelviewTitleVersion;

/// @brief Additional Information
+ (NSString *)labelviewTitleAdditionalInformation;

/// @brief An unspecified error occurred.
+ (NSString *)dadiskErrorTextUnspecified;

/// @brief The disk is busy.
+ (NSString *)dadiskErrorTextBusy;

/// @brief An invalid argument was passed to the function.
+ (NSString *)dadiskErrorTextBadArgument;

/// @brief The disk is locked and cannot be modified.
+ (NSString *)dadiskErrorTextExclusiveAccess;

/// @brief There are not enough resources to complete the operation.
+ (NSString *)dadiskErrorTextNoResources;

/// @brief The disk or the volume was not found.
+ (NSString *)dadiskErrorTextNotFound;

/// @brief The disk is not mounted.
+ (NSString *)dadiskErrorTextNotMounted;

/// @brief The operation is not permitted.
+ (NSString *)dadiskErrorTextNotPermitted;

/// @brief The user does not have the required privileges.
+ (NSString *)dadiskErrorTextNotPrivileged;

/// @brief The disk is not ready.
+ (NSString *)dadiskErrorTextNotReady;

/// @brief The disk or the volume is not writable.
+ (NSString *)dadiskErrorTextNotWritable;

/// @brief The operation is not supported by the disk.
+ (NSString *)dadiskErrorTextUnsupported;

/// @brief Specified BSD name does not exist. Can't erase this volume.
+ (NSString *)errorTextSpecifiedBsdNameDoesntExistCantErase;

/// @brief An error occurred while executing the command.
+ (NSString *)errorTextCommandLineExecuteFailure;

/// @brief Can't retrieve the information from the command line error output pipe.
+ (NSString *)errorTextCantGetErrorOutputPipe;

/// @brief An error occurred while reading output from hdiutil.
+ (NSString *)errorTextCantParseHdiutilOutput;

/// @brief Can't load \"system-entities\" from parsed plist.
+ (NSString *)errorTextPlistCantLoadSystemEntities;

/// @brief This image does not contain any System Entity.
+ (NSString *)errorTextPlistSystemEntitiesIsEmpty;

/// @brief The number of System Entities in this image is >1. The required Entity could not be determined. Try to specify the path to an already mounted image.
+ (NSString *)errorTextPlistSystemEntitiesCountMoreThanOne;

/// @brief The exit status of hdiutil was not EXIT_SUCCESS.
+ (NSString *)errorTextHdiutilStatusWasNotExitSuccess;

/// @brief Can't unmount the destination device
+ (NSString *)errorTextUnmountDestinationDeviceFailure;

/// @brief Application arguments list is empty.
+ (NSString *)errorTextApplicationArgumentsListIsEmpty;

/// @brief The first object of application arguments list is not a file.
+ (NSString *)errorTextApplicationArgumentsBadStructure;

/// @brief The set parameter is invalid.
+ (NSString *)authorizationErrorInvalidSet;

/// @brief The authorization parameter is invalid.
+ (NSString *)authorizationErrorInvalidRef;

/// @brief The authorization tag is invalid.
+ (NSString *)authorizationErrorInvalidTag;

/// @brief The authorization parameter is invalid.
+ (NSString *)authorizationErrorInvalidPointer;

/// @brief The authorization was denied.
+ (NSString *)authorizationErrorDenied;

/// @brief The authorization was canceled by the user.
+ (NSString *)authorizationErrorCanceled;

/// @brief The authorization was denied since no user interaction was possible.
+ (NSString *)authorizationErrorInteractionNotAllowed;

/// @brief An unrecognized internal error occurred.
+ (NSString *)authorizationErrorInternal;

/// @brief The Security Server denied externalization of the authorization reference.
+ (NSString *)authorizationErrorExternalizeNotAllowed;

/// @brief The Security Server denied internalization of the authorization reference.
+ (NSString *)authorizationErrorInternalizeNotAllowed;

/// @brief The provided option flag(s) are invalid for this authorization operation.
+ (NSString *)authorizationErrorInvalidFlags;

/// @brief The tool failed to execute.
+ (NSString *)authorizationErrorToolExecuteFailure;

/// @brief The attempt to execute the tool failed to return a success or an error code.
+ (NSString *)authorizationErrorToolEnvironmentError;

/// @brief The requested socket address is invalid (must be 0-1023 inclusive).
+ (NSString *)authorizationErrorBadAddress;

/// @brief This file does not have an .iso extension.
+ (NSString *)errorTextFileTypeIsNotIso;

/// @brief Can't load the destination device info from mounted volume on this Mac OS X version.
+ (NSString *)errorTextInitWithVolumePathUnsupported;

@end

NS_ASSUME_NONNULL_END
