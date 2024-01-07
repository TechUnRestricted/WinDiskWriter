//
//  LocalizedStrings.m
//  WinDiskWriter
//
//  Created by Macintosh on 12.12.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "LocalizedStrings.h"

@implementation LocalizedStrings

+ (NSString *)alertButtonTitleSkipFile {
    return NSLocalizedString(@"ALERT_BUTTON_TITLE_SKIP_FILE", NULL);
}

+ (NSString *)alertButtonTitleStopWriting {
    return NSLocalizedString(@"ALERT_BUTTON_TITLE_STOP_WRITING", NULL);
}

+ (NSString *)alertSubtitleImageWritingSuccess {
    return NSLocalizedString(@"ALERT_SUBTITLE_IMAGE_WRITING_SUCCESS", NULL);
}

+ (NSString *)alertSubtitleLegacyBootSupport {
    return NSLocalizedString(@"ALERT_SUBTITLE_LEGACY_BOOT_SUPPORT", NULL);
}

+ (NSString *)alertSubtitlePathDoesNotExist {
    return NSLocalizedString(@"ALERT_SUBTITLE_PATH_DOES_NOT_EXIST", NULL);
}

+ (NSString *)alertSubtitlePathFieldIsEmpty {
    return NSLocalizedString(@"ALERT_SUBTITLE_PATH_FIELD_IS_EMPTY", NULL);
}

+ (NSString *)alertSubtitlePressUpdateButton {
    return NSLocalizedString(@"ALERT_SUBTITLE_PRESS_UPDATE_BUTTON", NULL);
}

+ (NSString *)alertSubtitlePromptResetSettingsWithArgument1:(id)argument1 {
    NSString *unformattedString = NSLocalizedString(@"ALERT_SUBTITLE_PROMPT_RESET_SETTINGS", NULL);
    return [NSString stringWithFormat: unformattedString, argument1];
}

+ (NSString *)alertSubtitlePromptStartFailsafeRecovery {
    return NSLocalizedString(@"ALERT_SUBTITLE_PROMPT_START_FAILSAFE_RECOVERY", NULL);
}

+ (NSString *)alertSubtitlePromptStartProcess {
    return NSLocalizedString(@"ALERT_SUBTITLE_PROMPT_START_PROCESS", NULL);
}

+ (NSString *)alertSubtitleRequireRestartAsRoot {
    return NSLocalizedString(@"ALERT_SUBTITLE_REQUIRE_RESTART_AS_ROOT", NULL);
}

+ (NSString *)alertSubtitleStopProcess {
    return NSLocalizedString(@"ALERT_SUBTITLE_STOP_PROCESS", NULL);
}

+ (NSString *)alertSubtitleWriteFileProblemOccurred {
    return NSLocalizedString(@"ALERT_SUBTITLE_WRITE_FILE_PROBLEM_OCCURRED", NULL);
}

+ (NSString *)alertTitleBsdDeviceInfoIsOutdatedOrInvalid {
    return NSLocalizedString(@"ALERT_TITLE_BSD_DEVICE_INFO_IS_OUTDATED_OR_INVALID", NULL);
}

+ (NSString *)alertTitleBsdDeviceIsNoLongerAvailable {
    return NSLocalizedString(@"ALERT_TITLE_BSD_DEVICE_IS_NO_LONGER_AVAILABLE", NULL);
}

+ (NSString *)alertTitleCheckDataCorrectness {
    return NSLocalizedString(@"ALERT_TITLE_CHECK_DATA_CORRECTNESS", NULL);
}

+ (NSString *)alertTitleDiskEraseFailure {
    return NSLocalizedString(@"ALERT_TITLE_DISK_ERASE_FAILURE", NULL);
}

+ (NSString *)alertTitleFailedToRestart {
    return NSLocalizedString(@"ALERT_TITLE_FAILED_TO_RESTART", NULL);
}

+ (NSString *)alertTitleForgotSomething {
    return NSLocalizedString(@"ALERT_TITLE_FORGOT_SOMETHING", NULL);
}

+ (NSString *)alertTitleImageVerificationError {
    return NSLocalizedString(@"ALERT_TITLE_IMAGE_VERIFICATION_ERROR", NULL);
}

+ (NSString *)alertTitleImageWritingFailure {
    return NSLocalizedString(@"ALERT_TITLE_IMAGE_WRITING_FAILURE", NULL);
}

+ (NSString *)alertTitleImageWritingSuccess {
    return NSLocalizedString(@"ALERT_TITLE_IMAGE_WRITING_SUCCESS", NULL);
}

+ (NSString *)alertTitleLegacyBootSupport {
    return NSLocalizedString(@"ALERT_TITLE_LEGACY_BOOT_SUPPORT", NULL);
}

+ (NSString *)alertTitleNoWritableDevices {
    return NSLocalizedString(@"ALERT_TITLE_NO_WRITABLE_DEVICES", NULL);
}

+ (NSString *)alertTitlePromptStartProcess {
    return NSLocalizedString(@"ALERT_TITLE_PROMPT_START_PROCESS", NULL);
}

+ (NSString *)alertTitleRequireRestartAsRoot {
    return NSLocalizedString(@"ALERT_TITLE_REQUIRE_RESTART_AS_ROOT", NULL);
}

+ (NSString *)alertTitleStopProcess {
    return NSLocalizedString(@"ALERT_TITLE_STOP_PROCESS", NULL);
}

+ (NSString *)alertTitleWriteFileProblemOccurred {
    return NSLocalizedString(@"ALERT_TITLE_WRITE_FILE_PROBLEM_OCCURRED", NULL);
}

+ (NSString *)asLogTypeAssertionError {
    return NSLocalizedString(@"AS_LOG_TYPE_ASSERTION_ERROR", NULL);
}

+ (NSString *)asLogTypeFailure {
    return NSLocalizedString(@"AS_LOG_TYPE_FAILURE", NULL);
}

+ (NSString *)asLogTypeFatal {
    return NSLocalizedString(@"AS_LOG_TYPE_FATAL", NULL);
}

+ (NSString *)asLogTypeLog {
    return NSLocalizedString(@"AS_LOG_TYPE_LOG", NULL);
}

+ (NSString *)asLogTypeSkipped {
    return NSLocalizedString(@"AS_LOG_TYPE_SKIPPED", NULL);
}

+ (NSString *)asLogTypeStart {
    return NSLocalizedString(@"AS_LOG_TYPE_START", NULL);
}

+ (NSString *)asLogTypeSuccess {
    return NSLocalizedString(@"AS_LOG_TYPE_SUCCESS", NULL);
}

+ (NSString *)asLogTypeWarning {
    return NSLocalizedString(@"AS_LOG_TYPE_WARNING", NULL);
}

+ (NSString *)authorizationErrorBadAddress {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_BAD_ADDRESS", NULL);
}

+ (NSString *)authorizationErrorCanceled {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_CANCELED", NULL);
}

+ (NSString *)authorizationErrorDenied {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_DENIED", NULL);
}

+ (NSString *)authorizationErrorExternalizeNotAllowed {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_EXTERNALIZE_NOT_ALLOWED", NULL);
}

+ (NSString *)authorizationErrorInteractionNotAllowed {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_INTERACTION_NOT_ALLOWED", NULL);
}

+ (NSString *)authorizationErrorInternal {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_INTERNAL", NULL);
}

+ (NSString *)authorizationErrorInternalizeNotAllowed {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_INTERNALIZE_NOT_ALLOWED", NULL);
}

+ (NSString *)authorizationErrorInvalidFlags {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_INVALID_FLAGS", NULL);
}

+ (NSString *)authorizationErrorInvalidPointer {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_INVALID_POINTER", NULL);
}

+ (NSString *)authorizationErrorInvalidRef {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_INVALID_REF", NULL);
}

+ (NSString *)authorizationErrorInvalidSet {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_INVALID_SET", NULL);
}

+ (NSString *)authorizationErrorInvalidTag {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_INVALID_TAG", NULL);
}

+ (NSString *)authorizationErrorToolEnvironmentError {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_TOOL_ENVIRONMENT_ERROR", NULL);
}

+ (NSString *)authorizationErrorToolExecuteFailure {
    return NSLocalizedString(@"AUTHORIZATION_ERROR_TOOL_EXECUTE_FAILURE", NULL);
}

+ (NSString *)buttonTitleCancel {
    return NSLocalizedString(@"BUTTON_TITLE_CANCEL", NULL);
}

+ (NSString *)buttonTitleCancellationSchedule {
    return NSLocalizedString(@"BUTTON_TITLE_CANCELLATION_SCHEDULE", NULL);
}

+ (NSString *)buttonTitleChoose {
    return NSLocalizedString(@"BUTTON_TITLE_CHOOSE", NULL);
}

+ (NSString *)buttonTitleDismiss {
    return NSLocalizedString(@"BUTTON_TITLE_DISMISS", NULL);
}

+ (NSString *)buttonTitleRelaunch {
    return NSLocalizedString(@"BUTTON_TITLE_RELAUNCH", NULL);
}

+ (NSString *)buttonTitleStart {
    return NSLocalizedString(@"BUTTON_TITLE_START", NULL);
}

+ (NSString *)buttonTitleStop {
    return NSLocalizedString(@"BUTTON_TITLE_STOP", NULL);
}

+ (NSString *)buttonTitleStopping {
    return NSLocalizedString(@"BUTTON_TITLE_STOPPING", NULL);
}

+ (NSString *)buttonTitleUpdate {
    return NSLocalizedString(@"BUTTON_TITLE_UPDATE", NULL);
}

+ (NSString *)checkboxviewTitleInstallLegacyBootSector {
    return NSLocalizedString(@"CHECKBOXVIEW_TITLE_INSTALL_LEGACY_BOOT_SECTOR", NULL);
}

+ (NSString *)checkboxviewTitlePatchInstallerRequirements {
    return NSLocalizedString(@"CHECKBOXVIEW_TITLE_PATCH_INSTALLER_REQUIREMENTS", NULL);
}

+ (NSString *)checkboxviewTooltipInstallLegacyBootSector {
    return NSLocalizedString(@"CHECKBOXVIEW_TOOLTIP_INSTALL_LEGACY_BOOT_SECTOR", NULL);
}

+ (NSString *)checkboxviewTooltipPatchInstallerRequirements {
    return NSLocalizedString(@"CHECKBOXVIEW_TOOLTIP_PATCH_INSTALLER_REQUIREMENTS", NULL);
}

+ (NSString *)dadiskErrorTextBadArgument {
    return NSLocalizedString(@"DADISK_ERROR_TEXT_BAD_ARGUMENT", NULL);
}

+ (NSString *)dadiskErrorTextBusy {
    return NSLocalizedString(@"DADISK_ERROR_TEXT_BUSY", NULL);
}

+ (NSString *)dadiskErrorTextExclusiveAccess {
    return NSLocalizedString(@"DADISK_ERROR_TEXT_EXCLUSIVE_ACCESS", NULL);
}

+ (NSString *)dadiskErrorTextNotFound {
    return NSLocalizedString(@"DADISK_ERROR_TEXT_NOT_FOUND", NULL);
}

+ (NSString *)dadiskErrorTextNotMounted {
    return NSLocalizedString(@"DADISK_ERROR_TEXT_NOT_MOUNTED", NULL);
}

+ (NSString *)dadiskErrorTextNotPermitted {
    return NSLocalizedString(@"DADISK_ERROR_TEXT_NOT_PERMITTED", NULL);
}

+ (NSString *)dadiskErrorTextNotPrivileged {
    return NSLocalizedString(@"DADISK_ERROR_TEXT_NOT_PRIVILEGED", NULL);
}

+ (NSString *)dadiskErrorTextNotReady {
    return NSLocalizedString(@"DADISK_ERROR_TEXT_NOT_READY", NULL);
}

+ (NSString *)dadiskErrorTextNotWritable {
    return NSLocalizedString(@"DADISK_ERROR_TEXT_NOT_WRITABLE", NULL);
}

+ (NSString *)dadiskErrorTextNoResources {
    return NSLocalizedString(@"DADISK_ERROR_TEXT_NO_RESOURCES", NULL);
}

+ (NSString *)dadiskErrorTextUnspecified {
    return NSLocalizedString(@"DADISK_ERROR_TEXT_UNSPECIFIED", NULL);
}

+ (NSString *)dadiskErrorTextUnsupported {
    return NSLocalizedString(@"DADISK_ERROR_TEXT_UNSUPPORTED", NULL);
}

+ (NSString *)errorCantCopyFileToDestinationDeviceWithArgument1:(id)argument1 {
    NSString *unformattedString = NSLocalizedString(@"ERROR_CANT_COPY_FILE_TO_DESTINATION_DEVICE", NULL);
    return [NSString stringWithFormat: unformattedString, argument1];
}

+ (NSString *)errorFileOrDirectoryDoesntExistWithArgument1:(id)argument1 {
    NSString *unformattedString = NSLocalizedString(@"ERROR_FILE_OR_DIRECTORY_DOESNT_EXIST", NULL);
    return [NSString stringWithFormat: unformattedString, argument1];
}

+ (NSString *)errorTextAllocateMemoryBufferFailure {
    return NSLocalizedString(@"ERROR_TEXT_ALLOCATE_MEMORY_BUFFER_FAILURE", NULL);
}

+ (NSString *)errorTextApplicationArgumentsBadStructure {
    return NSLocalizedString(@"ERROR_TEXT_APPLICATION_ARGUMENTS_BAD_STRUCTURE", NULL);
}

+ (NSString *)errorTextApplicationArgumentsListIsEmpty {
    return NSLocalizedString(@"ERROR_TEXT_APPLICATION_ARGUMENTS_LIST_IS_EMPTY", NULL);
}

+ (NSString *)errorTextBootloaderFilesCantBeDownloaded {
    return NSLocalizedString(@"ERROR_TEXT_BOOTLOADER_FILES_CANT_BE_DOWNLOADED", NULL);
}

+ (NSString *)errorTextBootloaderGrldrFileDoesntExist {
    return NSLocalizedString(@"ERROR_TEXT_BOOTLOADER_GRLDR_FILE_DOESNT_EXIST", NULL);
}

+ (NSString *)errorTextBootloaderMbrFileDoesntExist {
    return NSLocalizedString(@"ERROR_TEXT_BOOTLOADER_MBR_FILE_DOESNT_EXIST", NULL);
}

+ (NSString *)errorTextBootloaderMbrOpenFileInputHandleFailure {
    return NSLocalizedString(@"ERROR_TEXT_BOOTLOADER_MBR_OPEN_FILE_INPUT_HANDLE_FAILURE", NULL);
}

+ (NSString *)errorTextBootloaderMenuFileDoesntExist {
    return NSLocalizedString(@"ERROR_TEXT_BOOTLOADER_MENU_FILE_DOESNT_EXIST", NULL);
}

+ (NSString *)errorTextCantCleanupTemporaryDirectories {
    return NSLocalizedString(@"ERROR_TEXT_CANT_CLEANUP_TEMPORARY_DIRECTORIES", NULL);
}

+ (NSString *)errorTextCantCreateBaseDirectories {
    return NSLocalizedString(@"ERROR_TEXT_CANT_CREATE_BASE_DIRECTORIES", NULL);
}

+ (NSString *)errorTextCantCreateBaseDirectoryAtPathWithArgument1:(id)argument1 argument2:(id)argument2 {
    NSString *unformattedString = NSLocalizedString(@"ERROR_TEXT_CANT_CREATE_BASE_DIRECTORY_AT_PATH", NULL);
    return [NSString stringWithFormat: unformattedString, argument1, argument2];
}

+ (NSString *)errorTextCantCreateTemporaryBlankFileWithArgument1:(id)argument1 {
    NSString *unformattedString = NSLocalizedString(@"ERROR_TEXT_CANT_CREATE_TEMPORARY_BLANK_FILE", NULL);
    return [NSString stringWithFormat: unformattedString, argument1];
}

+ (NSString *)errorTextCantDetermineBsdPath {
    return NSLocalizedString(@"ERROR_TEXT_CANT_DETERMINE_BSD_PATH", NULL);
}

+ (NSString *)errorTextCantFixPermissionsForBaseDirectories {
    return NSLocalizedString(@"ERROR_TEXT_CANT_FIX_PERMISSIONS_FOR_BASE_DIRECTORIES", NULL);
}

+ (NSString *)errorTextCantGetErrorOutputPipe {
    return NSLocalizedString(@"ERROR_TEXT_CANT_GET_ERROR_OUTPUT_PIPE", NULL);
}

+ (NSString *)errorTextCantOpenFilehandleForTempFilePathWithArgument1:(id)argument1 {
    NSString *unformattedString = NSLocalizedString(@"ERROR_TEXT_CANT_OPEN_FILEHANDLE_FOR_TEMP_FILE_PATH", NULL);
    return [NSString stringWithFormat: unformattedString, argument1];
}

+ (NSString *)errorTextCantParseHdiutilOutput {
    return NSLocalizedString(@"ERROR_TEXT_CANT_PARSE_HDIUTIL_OUTPUT", NULL);
}

+ (NSString *)errorTextCantSetAllPermissionsForDirectoryWithArgument1:(id)argument1 argument2:(id)argument2 {
    NSString *unformattedString = NSLocalizedString(@"ERROR_TEXT_CANT_SET_ALL_PERMISSIONS_FOR_DIRECTORY", NULL);
    return [NSString stringWithFormat: unformattedString, argument1, argument2];
}

+ (NSString *)errorTextCommandLineExecuteFailure {
    return NSLocalizedString(@"ERROR_TEXT_COMMAND_LINE_EXECUTE_FAILURE", NULL);
}

+ (NSString *)errorTextDestinationPathDoesNotExist {
    return NSLocalizedString(@"ERROR_TEXT_DESTINATION_PATH_DOES_NOT_EXIST", NULL);
}

+ (NSString *)errorTextDiskSpaceNotEnough {
    return NSLocalizedString(@"ERROR_TEXT_DISK_SPACE_NOT_ENOUGH", NULL);
}

+ (NSString *)errorTextFileCopyFailureOverFat32SizeLimit {
    return NSLocalizedString(@"ERROR_TEXT_FILE_COPY_FAILURE_OVER_FAT32_SIZE_LIMIT", NULL);
}

+ (NSString *)errorTextFileTypeIsNotIso {
    return NSLocalizedString(@"ERROR_TEXT_FILE_TYPE_IS_NOT_ISO", NULL);
}

+ (NSString *)errorTextGetAvailableDestinationDiskSpaceFailure {
    return NSLocalizedString(@"ERROR_TEXT_GET_AVAILABLE_DESTINATION_DISK_SPACE_FAILURE", NULL);
}

+ (NSString *)errorTextGetAvailableSpaceFailure {
    return NSLocalizedString(@"ERROR_TEXT_GET_AVAILABLE_SPACE_FAILURE", NULL);
}

+ (NSString *)errorTextHdiutilStatusWasNotExitSuccess {
    return NSLocalizedString(@"ERROR_TEXT_HDIUTIL_STATUS_WAS_NOT_EXIT_SUCCESS", NULL);
}

+ (NSString *)errorTextHttpResponseIncorrectStatusWithArgument1:(long)argument1 {
    NSString *unformattedString = NSLocalizedString(@"ERROR_TEXT_HTTP_RESPONSE_INCORRECT_STATUS", NULL);
    return [NSString stringWithFormat: unformattedString, argument1];
}

+ (NSString *)errorTextInitWithVolumePathUnsupported {
    return NSLocalizedString(@"ERROR_TEXT_INIT_WITH_VOLUME_PATH_UNSUPPORTED", NULL);
}

+ (NSString *)errorTextOpenDestinationPathFailure {
    return NSLocalizedString(@"ERROR_TEXT_OPEN_DESTINATION_PATH_FAILURE", NULL);
}

+ (NSString *)errorTextOpenSourceFileFailure {
    return NSLocalizedString(@"ERROR_TEXT_OPEN_SOURCE_FILE_FAILURE", NULL);
}

+ (NSString *)errorTextOutputDeviceOpenFailure {
    return NSLocalizedString(@"ERROR_TEXT_OUTPUT_DEVICE_OPEN_FAILURE", NULL);
}

+ (NSString *)errorTextPlistCantLoadSystemEntities {
    return NSLocalizedString(@"ERROR_TEXT_PLIST_CANT_LOAD_SYSTEM_ENTITIES", NULL);
}

+ (NSString *)errorTextPlistSystemEntitiesCountMoreThanOne {
    return NSLocalizedString(@"ERROR_TEXT_PLIST_SYSTEM_ENTITIES_COUNT_MORE_THAN_ONE", NULL);
}

+ (NSString *)errorTextPlistSystemEntitiesIsEmpty {
    return NSLocalizedString(@"ERROR_TEXT_PLIST_SYSTEM_ENTITIES_IS_EMPTY", NULL);
}

+ (NSString *)errorTextSourceIsTooLargeForTheDestinationDisk {
    return NSLocalizedString(@"ERROR_TEXT_SOURCE_IS_TOO_LARGE_FOR_THE_DESTINATION_DISK", NULL);
}

+ (NSString *)errorTextSpecifiedBsdNameDoesntExistCantErase {
    return NSLocalizedString(@"ERROR_TEXT_SPECIFIED_BSD_NAME_DOESNT_EXIST_CANT_ERASE", NULL);
}

+ (NSString *)errorTextSplittingEsdSwmNotSupported {
    return NSLocalizedString(@"ERROR_TEXT_SPLITTING_ESD_SWM_NOT_SUPPORTED", NULL);
}

+ (NSString *)errorTextUnmountDestinationDeviceFailure {
    return NSLocalizedString(@"ERROR_TEXT_UNMOUNT_DESTINATION_DEVICE_FAILURE", NULL);
}

+ (NSString *)errorTextUrlConnectionUnknownResponseLength {
    return NSLocalizedString(@"ERROR_TEXT_URL_CONNECTION_UNKNOWN_RESPONSE_LENGTH", NULL);
}

+ (NSString *)errorTextWriteDestinationPathDataFailure {
    return NSLocalizedString(@"ERROR_TEXT_WRITE_DESTINATION_PATH_DATA_FAILURE", NULL);
}

+ (NSString *)genericCancel {
    return NSLocalizedString(@"GENERIC_CANCEL", NULL);
}

+ (NSString *)genericContinue {
    return NSLocalizedString(@"GENERIC_CONTINUE", NULL);
}

+ (NSString *)genericNo {
    return NSLocalizedString(@"GENERIC_NO", NULL);
}

+ (NSString *)genericYes {
    return NSLocalizedString(@"GENERIC_YES", NULL);
}

+ (NSString *)inputviewPlaceholderImageFileOrDirectory {
    return NSLocalizedString(@"INPUTVIEW_PLACEHOLDER_IMAGE_FILE_OR_DIRECTORY", NULL);
}

+ (NSString *)labelviewTitleAdditionalInformation {
    return NSLocalizedString(@"LABELVIEW_TITLE_ADDITIONAL_INFORMATION", NULL);
}

+ (NSString *)labelviewTitleFilesystem {
    return NSLocalizedString(@"LABELVIEW_TITLE_FILESYSTEM", NULL);
}

+ (NSString *)labelviewTitleTargetDevice {
    return NSLocalizedString(@"LABELVIEW_TITLE_TARGET_DEVICE", NULL);
}

+ (NSString *)labelviewTitleVersion {
    return NSLocalizedString(@"LABELVIEW_TITLE_VERSION", NULL);
}

+ (NSString *)labelviewTitleWindowsImage {
    return NSLocalizedString(@"LABELVIEW_TITLE_WINDOWS_IMAGE", NULL);
}

+ (NSString *)logviewRowCreateDirectoryAtAppFolderPathWithArgument1:(id)argument1 {
    NSString *unformattedString = NSLocalizedString(@"LOGVIEW_ROW_CREATE_DIRECTORY_AT_APP_FOLDER_PATH", NULL);
    return [NSString stringWithFormat: unformattedString, argument1];
}

+ (NSString *)logviewRowFoundLegacyBootloaderFiles {
    return NSLocalizedString(@"LOGVIEW_ROW_FOUND_LEGACY_BOOTLOADER_FILES", NULL);
}

+ (NSString *)logviewRowLegacyBootloaderFilesNotFound {
    return NSLocalizedString(@"LOGVIEW_ROW_LEGACY_BOOTLOADER_FILES_NOT_FOUND", NULL);
}

+ (NSString *)logviewRowPartialTitleErrorMessageWithArgument1:(id)argument1 {
    NSString *unformattedString = NSLocalizedString(@"LOGVIEW_ROW_PARTIAL_TITLE_ERROR_MESSAGE", NULL);
    return [NSString stringWithFormat: unformattedString, argument1];
}

+ (NSString *)logviewRowPartialTitleFoundDevices {
    return NSLocalizedString(@"LOGVIEW_ROW_PARTIAL_TITLE_FOUND_DEVICES", NULL);
}

+ (NSString *)logviewRowTitleClearingDevicePickerList {
    return NSLocalizedString(@"LOGVIEW_ROW_TITLE_CLEARING_DEVICE_PICKER_LIST", NULL);
}

+ (NSString *)logviewRowTitleDiskEraseOperationOptionsWithArgument1:(id)argument1 argument2:(id)argument2 argument3:(id)argument3 argument4:(id)argument4 argument5:(id)argument5 argument6:(id)argument6 argument7:(NSInteger)argument7 argument8:(NSInteger)argument8 {
    NSString *unformattedString = NSLocalizedString(@"LOGVIEW_ROW_TITLE_DISK_ERASE_OPERATION_OPTIONS", NULL);
    return [NSString stringWithFormat: unformattedString, argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8];
}

+ (NSString *)logviewRowTitleGeneratedPartitionName {
    return NSLocalizedString(@"LOGVIEW_ROW_TITLE_GENERATED_PARTITION_NAME", NULL);
}

+ (NSString *)logviewRowTitleImageMountSuccess {
    return NSLocalizedString(@"LOGVIEW_ROW_TITLE_IMAGE_MOUNT_SUCCESS", NULL);
}

+ (NSString *)logviewRowTitleTargetPartitionPath {
    return NSLocalizedString(@"LOGVIEW_ROW_TITLE_TARGET_PARTITION_PATH", NULL);
}

+ (NSString *)menuTitleDonateMe {
    return NSLocalizedString(@"MENU_TITLE_DONATE_ME", NULL);
}

+ (NSString *)menuTitleEdit {
    return NSLocalizedString(@"MENU_TITLE_EDIT", NULL);
}

+ (NSString *)menuTitleHide {
    return NSLocalizedString(@"MENU_TITLE_HIDE", NULL);
}

+ (NSString *)menuTitleItemAbout {
    return NSLocalizedString(@"MENU_TITLE_ITEM_ABOUT", NULL);
}

+ (NSString *)menuTitleItemClose {
    return NSLocalizedString(@"MENU_TITLE_ITEM_CLOSE", NULL);
}

+ (NSString *)menuTitleItemCopy {
    return NSLocalizedString(@"MENU_TITLE_ITEM_COPY", NULL);
}

+ (NSString *)menuTitleItemCut {
    return NSLocalizedString(@"MENU_TITLE_ITEM_CUT", NULL);
}

+ (NSString *)menuTitleItemDebug {
    return NSLocalizedString(@"MENU_TITLE_ITEM_DEBUG", NULL);
}

+ (NSString *)menuTitleItemOpenDonationWebPage {
    return NSLocalizedString(@"MENU_TITLE_ITEM_OPEN_DONATION_WEB_PAGE", NULL);
}

+ (NSString *)menuTitleItemPaste {
    return NSLocalizedString(@"MENU_TITLE_ITEM_PASTE", NULL);
}

+ (NSString *)menuTitleItemQuit {
    return NSLocalizedString(@"MENU_TITLE_ITEM_QUIT", NULL);
}

+ (NSString *)menuTitleItemSelectAll {
    return NSLocalizedString(@"MENU_TITLE_ITEM_SELECT_ALL", NULL);
}

+ (NSString *)menuTitleMinimize {
    return NSLocalizedString(@"MENU_TITLE_MINIMIZE", NULL);
}

+ (NSString *)menuTitleResetAllSettings {
    return NSLocalizedString(@"MENU_TITLE_RESET_ALL_SETTINGS", NULL);
}

+ (NSString *)menuTitleScanAllWholeDisks {
    return NSLocalizedString(@"MENU_TITLE_SCAN_ALL_WHOLE_DISKS", NULL);
}

+ (NSString *)menuTitleWindow {
    return NSLocalizedString(@"MENU_TITLE_WINDOW", NULL);
}

+ (NSString *)placeholderErrorWithArgument1:(id)argument1 {
    NSString *unformattedString = NSLocalizedString(@"PLACEHOLDER_ERROR", NULL);
    return [NSString stringWithFormat: unformattedString, argument1];
}

+ (NSString *)placeholderReasonWithArgument1:(id)argument1 {
    NSString *unformattedString = NSLocalizedString(@"PLACEHOLDER_REASON", NULL);
    return [NSString stringWithFormat: unformattedString, argument1];
}

+ (NSString *)progressTitleCreateDirectory {
    return NSLocalizedString(@"PROGRESS_TITLE_CREATE_DIRECTORY", NULL);
}

+ (NSString *)progressTitleDiskEraseSuccess {
    return NSLocalizedString(@"PROGRESS_TITLE_DISK_ERASE_SUCCESS", NULL);
}

+ (NSString *)progressTitleExtractBootloader {
    return NSLocalizedString(@"PROGRESS_TITLE_EXTRACT_BOOTLOADER", NULL);
}

+ (NSString *)progressTitleFormattingTheDrive {
    return NSLocalizedString(@"PROGRESS_TITLE_FORMATTING_THE_DRIVE", NULL);
}

+ (NSString *)progressTitleInstallLegacyBootloader {
    return NSLocalizedString(@"PROGRESS_TITLE_INSTALL_LEGACY_BOOTLOADER", NULL);
}

+ (NSString *)progressTitlePatchInstallerRequirements {
    return NSLocalizedString(@"PROGRESS_TITLE_PATCH_INSTALLER_REQUIREMENTS", NULL);
}

+ (NSString *)progressTitleReadyForAction {
    return NSLocalizedString(@"PROGRESS_TITLE_READY_FOR_ACTION", NULL);
}

+ (NSString *)progressTitleSetFilePermissions {
    return NSLocalizedString(@"PROGRESS_TITLE_SET_FILE_PERMISSIONS", NULL);
}

+ (NSString *)progressTitleSplitImage {
    return NSLocalizedString(@"PROGRESS_TITLE_SPLIT_IMAGE", NULL);
}

+ (NSString *)progressTitleWriteFile {
    return NSLocalizedString(@"PROGRESS_TITLE_WRITE_FILE", NULL);
}

+ (NSString *)sdmMessageDidFinishLoadingWithArgument1:(id)argument1 argument2:(id)argument2 argument3:(id)argument3 {
    NSString *unformattedString = NSLocalizedString(@"SDM_MESSAGE_DID_FINISH_LOADING", NULL);
    return [NSString stringWithFormat: unformattedString, argument1, argument2, argument3];
}

+ (NSString *)sdmMessageDownloadDidReceiveDataWithArgument1:(id)argument1 argument2:(id)argument2 argument3:(id)argument3 argument4:(SInt64)argument4 {
    NSString *unformattedString = NSLocalizedString(@"SDM_MESSAGE_DOWNLOAD_DID_RECEIVE_DATA", NULL);
    return [NSString stringWithFormat: unformattedString, argument1, argument2, argument3, argument4];
}

+ (NSString *)sdmMessageDownloadDidReceiveResponseWithArgument1:(id)argument1 argument2:(id)argument2 argument3:(id)argument3 {
    NSString *unformattedString = NSLocalizedString(@"SDM_MESSAGE_DOWNLOAD_DID_RECEIVE_RESPONSE", NULL);
    return [NSString stringWithFormat: unformattedString, argument1, argument2, argument3];
}

+ (NSString *)tooltipFramelayoutFormattingSection {
    return NSLocalizedString(@"TOOLTIP_FRAMELAYOUT_FORMATTING_SECTION", NULL);
}

@end
