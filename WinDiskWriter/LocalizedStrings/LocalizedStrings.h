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

/// @brief Skip File
+ (NSString *)alertButtonTitleSkipFile;

/// @brief Stop Writing
+ (NSString *)alertButtonTitleStopWriting;

/// @brief Do not forget to properly remove the device to avoid data corruption.
+ (NSString *)alertSubtitleImageWritingSuccess;

/// @brief To enable Legacy Boot, WinDiskWriter needs to download grub4dos bootloader files.\nGrub4dos is distributed under the GNU General Public License version 2.0.
+ (NSString *)alertSubtitleLegacyBootSupport;

/// @brief The Path to the Image or Folder you entered does not exist.
+ (NSString *)alertSubtitlePathDoesNotExist;

/// @brief The path to the Windows Image or Directory was not specified.
+ (NSString *)alertSubtitlePathFieldIsEmpty;

/// @brief Connect a compatible USB device and click on the Update button.
+ (NSString *)alertSubtitlePressUpdateButton;

/// @brief This operation will clear all Application Data for the '%@' user.
+ (NSString *)alertSubtitlePromptResetSettingsWithArgument1:(id)argument1;

/// @brief The application can try to fix these errors by relaunching as Root.
+ (NSString *)alertSubtitlePromptStartFailsafeRecovery;

/// @brief You will lose all data on the selected device.
+ (NSString *)alertSubtitlePromptStartProcess;

/// @brief All unsaved changes will be lost
+ (NSString *)alertSubtitleRequireRestartAsRoot;

/// @brief You will need to wait until the last file finish the copying.
+ (NSString *)alertSubtitleStopProcess;

/// @brief Would you like to skip this file, or stop writing?
+ (NSString *)alertSubtitleWriteFileProblemOccurred;

/// @brief The information about this device is outdated or invalid.
+ (NSString *)alertTitleBsdDeviceInfoIsOutdatedOrInvalid;

/// @brief Chosen Device is no longer available.
+ (NSString *)alertTitleBsdDeviceIsNoLongerAvailable;

/// @brief Check the correctness of the entered data.
+ (NSString *)alertTitleCheckDataCorrectness;

/// @brief Can't erase the destination device.
+ (NSString *)alertTitleDiskEraseFailure;

/// @brief Failed to restart
+ (NSString *)alertTitleFailedToRestart;

/// @brief You forgot something...
+ (NSString *)alertTitleForgotSomething;

/// @brief Can't verify this Image.
+ (NSString *)alertTitleImageVerificationError;

/// @brief Something went wrong while writing files to the destination device.
+ (NSString *)alertTitleImageWritingFailure;

/// @brief Image writing completed successfully.
+ (NSString *)alertTitleImageWritingSuccess;

/// @brief Legacy Boot Support
+ (NSString *)alertTitleLegacyBootSupport;

/// @brief No writable devices found.
+ (NSString *)alertTitleNoWritableDevices;

/// @brief Are you sure you want to start?
+ (NSString *)alertTitlePromptStartProcess;

/// @brief This option requires the application to be relaunched with Root Permissions
+ (NSString *)alertTitleRequireRestartAsRoot;

/// @brief Do you want to stop the process?
+ (NSString *)alertTitleStopProcess;

/// @brief A problem occurred while writing the file to disk
+ (NSString *)alertTitleWriteFileProblemOccurred;

/// @brief AssertionFailure
+ (NSString *)asLogTypeAssertionError;

/// @brief Failure
+ (NSString *)asLogTypeFailure;

/// @brief Fatal
+ (NSString *)asLogTypeFatal;

/// @brief Log
+ (NSString *)asLogTypeLog;

/// @brief Skipped
+ (NSString *)asLogTypeSkipped;

/// @brief Start
+ (NSString *)asLogTypeStart;

/// @brief Success
+ (NSString *)asLogTypeSuccess;

/// @brief Warning
+ (NSString *)asLogTypeWarning;

/// @brief The requested socket address is invalid (must be 0-1023 inclusive).
+ (NSString *)authorizationErrorBadAddress;

/// @brief The authorization was canceled by the user.
+ (NSString *)authorizationErrorCanceled;

/// @brief The authorization was denied.
+ (NSString *)authorizationErrorDenied;

/// @brief The Security Server denied externalization of the authorization reference.
+ (NSString *)authorizationErrorExternalizeNotAllowed;

/// @brief The authorization was denied since no user interaction was possible.
+ (NSString *)authorizationErrorInteractionNotAllowed;

/// @brief An unrecognized internal error occurred.
+ (NSString *)authorizationErrorInternal;

/// @brief The Security Server denied internalization of the authorization reference.
+ (NSString *)authorizationErrorInternalizeNotAllowed;

/// @brief The provided option flag(s) are invalid for this authorization operation.
+ (NSString *)authorizationErrorInvalidFlags;

/// @brief The authorizedRights parameter is invalid.
+ (NSString *)authorizationErrorInvalidPointer;

/// @brief The authorization parameter is invalid.
+ (NSString *)authorizationErrorInvalidRef;

/// @brief The set parameter is invalid.
+ (NSString *)authorizationErrorInvalidSet;

/// @brief The authorization tag is invalid.
+ (NSString *)authorizationErrorInvalidTag;

/// @brief The attempt to execute the tool failed to return a success or an error code.
+ (NSString *)authorizationErrorToolEnvironmentError;

/// @brief The tool failed to execute.
+ (NSString *)authorizationErrorToolExecuteFailure;

/// @brief Cancel
+ (NSString *)buttonTitleCancel;

/// @brief Schedule the cancellation
+ (NSString *)buttonTitleCancellationSchedule;

/// @brief Choose
+ (NSString *)buttonTitleChoose;

/// @brief Dismiss
+ (NSString *)buttonTitleDismiss;

/// @brief Relaunch
+ (NSString *)buttonTitleRelaunch;

/// @brief Start
+ (NSString *)buttonTitleStart;

/// @brief Stop
+ (NSString *)buttonTitleStop;

/// @brief Stopping
+ (NSString *)buttonTitleStopping;

/// @brief Update
+ (NSString *)buttonTitleUpdate;

/// @brief Install Legacy BIOS Boot Sector
+ (NSString *)checkboxviewTitleInstallLegacyBootSector;

/// @brief Patch Installer Requirements
+ (NSString *)checkboxviewTitlePatchInstallerRequirements;

/// @brief Add support for older firmwares that don't support booting from EFI.
+ (NSString *)checkboxviewTooltipInstallLegacyBootSector;

/// @brief Remove TPM, Secure Boot and RAM requirements from the installer.\n(Windows 11 only)
+ (NSString *)checkboxviewTooltipPatchInstallerRequirements;

/// @brief An invalid argument was passed to the function.
+ (NSString *)dadiskErrorTextBadArgument;

/// @brief The disk is busy.
+ (NSString *)dadiskErrorTextBusy;

/// @brief The disk is locked and cannot be modified.
+ (NSString *)dadiskErrorTextExclusiveAccess;

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

/// @brief There are not enough resources to complete the operation.
+ (NSString *)dadiskErrorTextNoResources;

/// @brief An unspecified error occurred.
+ (NSString *)dadiskErrorTextUnspecified;

/// @brief The operation is not supported by the disk.
+ (NSString *)dadiskErrorTextUnsupported;

/// @brief Can't copy '%@' to the destination device.
+ (NSString *)errorCantCopyFileToDestinationDeviceWithArgument1:(id)argument1;

/// @brief File (directory) '%@' doesn't exist.
+ (NSString *)errorFileOrDirectoryDoesntExistWithArgument1:(id)argument1;

/// @brief Couldn't allocate memory for buffer.
+ (NSString *)errorTextAllocateMemoryBufferFailure;

/// @brief The first object of application arguments list is not a file.
+ (NSString *)errorTextApplicationArgumentsBadStructure;

/// @brief Application arguments list is empty.
+ (NSString *)errorTextApplicationArgumentsListIsEmpty;

/// @brief The bootloader files could not be downloaded.
+ (NSString *)errorTextBootloaderFilesCantBeDownloaded;

/// @brief Bootloader Grldr file doesn't exist.
+ (NSString *)errorTextBootloaderGrldrFileDoesntExist;

/// @brief Bootloader MBR file doesn't exist.
+ (NSString *)errorTextBootloaderMbrFileDoesntExist;

/// @brief Can't open the input handle for the MBR file.
+ (NSString *)errorTextBootloaderMbrOpenFileInputHandleFailure;

/// @brief Bootloader Menu file doesn't exist.
+ (NSString *)errorTextBootloaderMenuFileDoesntExist;

/// @brief Can't cleanup temporary directories
+ (NSString *)errorTextCantCleanupTemporaryDirectories;

/// @brief Can't create base directories
+ (NSString *)errorTextCantCreateBaseDirectories;

/// @brief Can't create a base directory at path: '%@' [Error: '%@']
+ (NSString *)errorTextCantCreateBaseDirectoryAtPathWithArgument1:(id)argument1 argument2:(id)argument2;

/// @brief Can't create a blank file for storing a file in a temporary directory: '%@'.
+ (NSString *)errorTextCantCreateTemporaryBlankFileWithArgument1:(id)argument1;

/// @brief Can't determine the BSD path for the destination device.
+ (NSString *)errorTextCantDetermineBsdPath;

/// @brief Can't fix permissions for base directories
+ (NSString *)errorTextCantFixPermissionsForBaseDirectories;

/// @brief Can't retrieve the information from the command line error output pipe.
+ (NSString *)errorTextCantGetErrorOutputPipe;

/// @brief Can't open file handle for temporary file path: '%@'.
+ (NSString *)errorTextCantOpenFilehandleForTempFilePathWithArgument1:(id)argument1;

/// @brief An error occurred while reading output from hdiutil.
+ (NSString *)errorTextCantParseHdiutilOutput;

/// @brief Can't set 777 permissions for directory: '%@' [Error: '%@']
+ (NSString *)errorTextCantSetAllPermissionsForDirectoryWithArgument1:(id)argument1 argument2:(id)argument2;

/// @brief An error occurred while executing the command.
+ (NSString *)errorTextCommandLineExecuteFailure;

/// @brief Destination path does not exist.
+ (NSString *)errorTextDestinationPathDoesNotExist;

/// @brief Not enough free disk space.
+ (NSString *)errorTextDiskSpaceNotEnough;

/// @brief Can't copy this file to the FAT32 volume due to filesystem limitations.
+ (NSString *)errorTextFileCopyFailureOverFat32SizeLimit;

/// @brief This file does not have an .iso extension.
+ (NSString *)errorTextFileTypeIsNotIso;

/// @brief Can't get the available space for the destination disk.
+ (NSString *)errorTextGetAvailableDestinationDiskSpaceFailure;

/// @brief Can't get the available space for the specified path.
+ (NSString *)errorTextGetAvailableSpaceFailure;

/// @brief The exit status of hdiutil was not EXIT_SUCCESS.
+ (NSString *)errorTextHdiutilStatusWasNotExitSuccess;

/// @brief HTTP Response has incorrect status status code: %ld.
+ (NSString *)errorTextHttpResponseIncorrectStatusWithArgument1:(long)argument1;

/// @brief Can't load the destination device info from mounted volume on this Mac OS X version.
+ (NSString *)errorTextInitWithVolumePathUnsupported;

/// @brief Couldn't open the destination file path.
+ (NSString *)errorTextOpenDestinationPathFailure;

/// @brief Couldn't open the source file.
+ (NSString *)errorTextOpenSourceFileFailure;

/// @brief Can't open the output device.
+ (NSString *)errorTextOutputDeviceOpenFailure;

/// @brief Can't load \"system-entities\" from parsed plist.
+ (NSString *)errorTextPlistCantLoadSystemEntities;

/// @brief The number of System Entities in this image is >1. The required Entity could not be determined. Try to specify the path to an already mounted image.
+ (NSString *)errorTextPlistSystemEntitiesCountMoreThanOne;

/// @brief This image does not contain any System Entity.
+ (NSString *)errorTextPlistSystemEntitiesIsEmpty;

/// @brief Source is too large for the destination disk.
+ (NSString *)errorTextSourceIsTooLargeForTheDestinationDisk;

/// @brief Specified BSD name does not exist. Can't erase this volume.
+ (NSString *)errorTextSpecifiedBsdNameDoesntExistCantErase;

/// @brief Splitting Windows Install Images with .esd and .swm extensions is currently not supported.
+ (NSString *)errorTextSplittingEsdSwmNotSupported;

/// @brief Can't unmount the destination device
+ (NSString *)errorTextUnmountDestinationDeviceFailure;

/// @brief NSURLConnection Response length is unknown.
+ (NSString *)errorTextUrlConnectionUnknownResponseLength;

/// @brief Can't write data to destination path.
+ (NSString *)errorTextWriteDestinationPathDataFailure;

/// @brief Cancel
+ (NSString *)genericCancel;

/// @brief Continue
+ (NSString *)genericContinue;

/// @brief No
+ (NSString *)genericNo;

/// @brief Yes
+ (NSString *)genericYes;

/// @brief Image File or Directory
+ (NSString *)inputviewPlaceholderImageFileOrDirectory;

/// @brief Additional Information
+ (NSString *)labelviewTitleAdditionalInformation;

/// @brief File System
+ (NSString *)labelviewTitleFilesystem;

/// @brief Target Device
+ (NSString *)labelviewTitleTargetDevice;

/// @brief Version
+ (NSString *)labelviewTitleVersion;

/// @brief Windows Image
+ (NSString *)labelviewTitleWindowsImage;

/// @brief Create directory at Application Folder path: '%@'.
+ (NSString *)logviewRowCreateDirectoryAtAppFolderPathWithArgument1:(id)argument1;

/// @brief Found Legacy Bootloader files.
+ (NSString *)logviewRowFoundLegacyBootloaderFiles;

/// @brief Legacy Bootloader files were not found.
+ (NSString *)logviewRowLegacyBootloaderFilesNotFound;

/// @brief (Error message: '%@')
+ (NSString *)logviewRowPartialTitleErrorMessageWithArgument1:(id)argument1;

/// @brief Found devices
+ (NSString *)logviewRowPartialTitleFoundDevices;

/// @brief Clearing the device picker list.
+ (NSString *)logviewRowTitleClearingDevicePickerList;

/// @brief Device %@ (%@ %@) is ready to be erased with the following properties: (partition_name: '%@', partition_scheme: '%@', filesystem: '%@', patch_installer_requirements: '%d', install_legacy_boot: '%d').
+ (NSString *)logviewRowTitleDiskEraseOperationOptionsWithArgument1:(id)argument1 argument2:(id)argument2 argument3:(id)argument3 argument4:(id)argument4 argument5:(id)argument5 argument6:(id)argument6 argument7:(NSInteger)argument7 argument8:(NSInteger)argument8;

/// @brief Generated partition name
+ (NSString *)logviewRowTitleGeneratedPartitionName;

/// @brief Image was successfully mounted
+ (NSString *)logviewRowTitleImageMountSuccess;

/// @brief Target partition path
+ (NSString *)logviewRowTitleTargetPartitionPath;

/// @brief ❤️ Donate Me ❤️
+ (NSString *)menuTitleDonateMe;

/// @brief Edit
+ (NSString *)menuTitleEdit;

/// @brief Hide
+ (NSString *)menuTitleHide;

/// @brief About
+ (NSString *)menuTitleItemAbout;

/// @brief Close
+ (NSString *)menuTitleItemClose;

/// @brief Copy
+ (NSString *)menuTitleItemCopy;

/// @brief Cut
+ (NSString *)menuTitleItemCut;

/// @brief Debug
+ (NSString *)menuTitleItemDebug;

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

/// @brief Reset All Settings
+ (NSString *)menuTitleResetAllSettings;

/// @brief Scan All Whole Disks
+ (NSString *)menuTitleScanAllWholeDisks;

/// @brief Window
+ (NSString *)menuTitleWindow;

/// @brief [Error: '%@']
+ (NSString *)placeholderErrorWithArgument1:(id)argument1;

/// @brief (Reason: %@)
+ (NSString *)placeholderReasonWithArgument1:(id)argument1;

/// @brief Create directory
+ (NSString *)progressTitleCreateDirectory;

/// @brief The destination device was successfully erased.
+ (NSString *)progressTitleDiskEraseSuccess;

/// @brief Extract Bootloader
+ (NSString *)progressTitleExtractBootloader;

/// @brief Formatting the drive
+ (NSString *)progressTitleFormattingTheDrive;

/// @brief Install Legacy Bootloader
+ (NSString *)progressTitleInstallLegacyBootloader;

/// @brief Patch Installer Requirements
+ (NSString *)progressTitlePatchInstallerRequirements;

/// @brief Ready for action
+ (NSString *)progressTitleReadyForAction;

/// @brief Set File Permissions
+ (NSString *)progressTitleSetFilePermissions;

/// @brief Split Image
+ (NSString *)progressTitleSplitImage;

/// @brief Write File
+ (NSString *)progressTitleWriteFile;

/// @brief %@ -> [Downloaded: '%@', Expected File Size: '%@']
+ (NSString *)sdmMessageDidFinishLoadingWithArgument1:(id)argument1 argument2:(id)argument2 argument3:(id)argument3;

/// @brief %@ -> [Chunk Size: '%@', Downloaded: '%@', Chunk Number: '%lld']
+ (NSString *)sdmMessageDownloadDidReceiveDataWithArgument1:(id)argument1 argument2:(id)argument2 argument3:(id)argument3 argument4:(SInt64)argument4;

/// @brief %@ -> [URL: '%@', Expected Content Length: '%@']
+ (NSString *)sdmMessageDownloadDidReceiveResponseWithArgument1:(id)argument1 argument2:(id)argument2 argument3:(id)argument3;

/// @brief Desired filesystem for the destination device.\n(FAT32 is the best choice for compatibility)
+ (NSString *)tooltipFramelayoutFormattingSection;

@end

NS_ASSUME_NONNULL_END
