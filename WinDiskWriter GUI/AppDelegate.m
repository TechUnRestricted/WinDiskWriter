//
//  AppDelegate.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 13.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "AppDelegate.h"
#import "FrameLayout.h"
#import "LabelView.h"
#import "ButtonView.h"
#import "PickerView.h"
#import "TextInputView.h"
#import "CheckBoxView.h"
#import "AutoScrollTextView.h"
#import "ProgressBarView.h"

#import "NSColor+Common.h"
#import "NSString+Common.h"

#import "Constants.h"

#import "DiskManager.h"
#import "DiskWriter.h"
#import "HDIUtil.h"

#import "HelperFunctions.h"

typedef NS_OPTIONS(NSUInteger, NSViewAutoresizing) {
    NSViewAutoresizingNone                 = NSViewNotSizable,
    NSViewAutoresizingFlexibleLeftMargin   = NSViewMinXMargin,
    NSViewAutoresizingFlexibleWidth        = NSViewWidthSizable,
    NSViewAutoresizingFlexibleRightMargin  = NSViewMaxXMargin,
    NSViewAutoresizingFlexibleTopMargin    = NSViewMaxYMargin,
    NSViewAutoresizingFlexibleHeight       = NSViewHeightSizable,
    NSViewAutoresizingFlexibleBottomMargin = NSViewMinYMargin
};

@implementation AppDelegate {
    /* Initialized in -applicationDidFinishLaunching: */
    TextInputView *windowsImageInputView;
    PickerView *devicePickerView;
    CheckBoxView *formatDeviceCheckboxView;
    NSSegmentedControl *filesystemPickerSegmentedControl;
    NSSegmentedControl *partitionSchemePickerSegmentedControl;
    AutoScrollTextView *logsAutoScrollTextView;
    ProgressBarView *progressBarView;
    NSWindow *window;
}

- (void)setupWindow {
    NSSize minSize = CGSizeMake(330, 520);
    NSSize maxSize = CGSizeMake(500, 650);
    
    NSRect windowRect = NSMakeRect(
                                   0, // X
                                   0, // Y
                                   minSize.width, // Width
                                   minSize.height // Height
                                   );
    
    window = [[NSWindow alloc] initWithContentRect: windowRect
                                         styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
                                           backing: NSBackingStoreBuffered
                                             defer: NO
    ];
    
    [window center];
    [window setMovableByWindowBackground: YES];
    [window makeKeyAndOrderFront: NULL];
    
    [window setMinSize: minSize];
    [window setMaxSize: maxSize];
    
    [window setTitle: @"WinDiskWriter GUI"];
    
    if (@available(macOS 10.10, *)) {
        [window setTitlebarAppearsTransparent: YES];
    }
    
    NSButton *windowZoomButton = [window standardWindowButton:NSWindowZoomButton];
    [windowZoomButton setEnabled: NO];
    
    NSView *backgroundView;
    
    if (@available(macOS 10.10, *)) {
        NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] initWithFrame:window.frame];
        
        [visualEffectView setState:NSVisualEffectStateActive];
        [visualEffectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        
        backgroundView = visualEffectView;
        
        window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    } else {
        backgroundView = [[NSView alloc] init];
    }
    
    [window setContentView: backgroundView];
}

- (FrameLayoutVertical *)setupMainVerticalViewWithPaddingTop: (CGFloat)top
                                                      bottom: (CGFloat)bottom
                                                        left: (CGFloat)left
                                                       right: (CGFloat)right
                                                      nsView: (NSView *)nsView {
    CGFloat x = left;
    CGFloat y = bottom;
    CGFloat width = nsView.frame.size.width - left - right;
    CGFloat height = nsView.frame.size.height - top - bottom;
    
    CGRect windowRect = CGRectMake(x, y, width, height);
    
    FrameLayoutVertical *verticalLayout = [[FrameLayoutVertical alloc] initWithFrame: windowRect];
    [nsView addSubview:verticalLayout];
    
    [verticalLayout setAutoresizingMask: NSViewAutoresizingFlexibleWidth | NSViewAutoresizingFlexibleHeight];
    
    [verticalLayout setVerticalAlignment: FrameLayoutVerticalTop];
    
    return verticalLayout;
}

- (void)applyUIState {
    
}

- (void)displayWarningAlertWithTitle: (NSString *)title
subtitle: (NSString *)subtitle
icon: (NSImageName)icon {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText: title];
        [alert setInformativeText: subtitle];
        [alert setIcon: [NSImage imageNamed: icon]];
        
        [alert beginSheetModalForWindow: self->window
                          modalDelegate: NULL
                         didEndSelector: NULL
                            contextInfo: NULL];
    });
}

- (void)startStopAction {
    
    NSString * const FORGOT_SOMETHING_TEXT = @"You forgot something...";
    NSString * const PATH_FIELD_IS_EMPTY = @"The path to the Windows Image or Directory was not specified.";
    NSString * const PATH_DOES_NOT_EXIST = @"The Path to the Image or Folder you entered does not exist.";
    NSString * const CHECK_DATA_CORRECTNESS_TEXT = @"Check the correctness of the entered data.";
    NSString * const NO_AVAILABLE_DEVICES = @"No writable devices found.";
    NSString * const PRESS_UPDATE_BUTTON = @"Connect a compatible USB device and click on the Update button.";
    NSString * const BSD_DEVICE_IS_NO_LONGER_AVAILABLE_TITLE = @"Chosen Device is no longer available.";
    NSString * const IMAGE_VERIFICATION_ERROR = @"Can't verify this Image.";
    NSString * const DISK_ERASE_FAILURE_TITLE = @"Can't erase the destionation device.";
    NSString * const DISK_ERASE_SUCCESS_TITLE = @"The destination device was successfully erased.";
    
    NSString *imagePath = [windowsImageInputView.stringValue copy];
    if (imagePath.length == 0) {
        
        [self displayWarningAlertWithTitle: FORGOT_SOMETHING_TEXT
                                  subtitle: PATH_FIELD_IS_EMPTY
                                      icon: NSImageNameCaution];
        
        [logsAutoScrollTextView appendTimestampedLine: PATH_FIELD_IS_EMPTY
                                              logType: ASLogTypeAssertionError];
        return;
    }
    
    BOOL imagePathIsDirectory = NO;
    BOOL imageExists = [[NSFileManager defaultManager] fileExistsAtPath: imagePath
                                                            isDirectory: &imagePathIsDirectory];
    
    if (!imageExists) {
        [self displayWarningAlertWithTitle: CHECK_DATA_CORRECTNESS_TEXT
                                  subtitle: PATH_DOES_NOT_EXIST
                                      icon: NSImageNameCaution];
        
        [logsAutoScrollTextView appendTimestampedLine: PATH_DOES_NOT_EXIST
                                              logType: ASLogTypeAssertionError];
        
        return;
    }
    
    if ([devicePickerView numberOfItems] <= 0) {
        [self displayWarningAlertWithTitle: NO_AVAILABLE_DEVICES
                                  subtitle: PRESS_UPDATE_BUTTON
                                      icon: NSImageNameCaution];
        
        [logsAutoScrollTextView appendTimestampedLine: NO_AVAILABLE_DEVICES
                                              logType: ASLogTypeAssertionError];
        return;
    }
    
    NSString *bsdName = devicePickerView.associatedObjectForSelectedItem;
    DiskManager *destinationDiskDM = [[DiskManager alloc] initWithBSDName:bsdName];
    struct DiskInfo destinationDiskInfo = [destinationDiskDM getDiskInfo];
    if (destinationDiskDM == NULL || !destinationDiskInfo.isDeviceUnit) {
        [self displayWarningAlertWithTitle: BSD_DEVICE_IS_NO_LONGER_AVAILABLE_TITLE
                                  subtitle: PRESS_UPDATE_BUTTON
                                      icon: NSImageNameCaution];
        
        [logsAutoScrollTextView appendTimestampedLine: BSD_DEVICE_IS_NO_LONGER_AVAILABLE_TITLE
                                              logType: ASLogTypeFatal];
        return;
    }
    
    NSError *imageMountError = NULL;
    NSString *mountedImagePath = [HelperFunctions getWindowsSourceMountPath: imagePath
                                                                      error: &imageMountError];
    if (imageMountError != NULL) {
        NSString *errorSubtitle = [[imageMountError userInfo] objectForKey:DEFAULT_ERROR_KEY];
        NSString *logText = [NSString stringWithFormat:@"%@ (%@)", IMAGE_VERIFICATION_ERROR, errorSubtitle];
        
        [self displayWarningAlertWithTitle: IMAGE_VERIFICATION_ERROR
                                  subtitle: errorSubtitle
                                      icon: NSImageNameCaution];
        
        [logsAutoScrollTextView appendTimestampedLine: logText
                                              logType: ASLogTypeFatal];
        
        return;
    }
    
    [logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"Image was mounted successfully on \"%@\".", mountedImagePath]
                                          logType: ASLogTypeSuccess];
    
    NSString *newPartitionName = [NSString stringWithFormat:@"WDW_%@", [HelperFunctions randomStringWithLength:7]];
    [logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"Generated partition name: \"%@\".", newPartitionName]
                                          logType: ASLogTypeLog];
    
    NSString *targetPartitionPath = [NSString stringWithFormat:@"/Volumes/%@", newPartitionName];
    [logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"Target partition path: \"%@\".", targetPartitionPath]
                                          logType: ASLogTypeLog];
    
    NSString *diskEraseOperationText = [NSString stringWithFormat:@"Device %@ (%@ %@) is ready to be erased with the following properties: (partition_name: \"%@\", partition_scheme: \"%@\", filesystem: \"%@\").", bsdName, destinationDiskInfo.deviceVendor, destinationDiskInfo.deviceModel, newPartitionName, PartitionSchemeGPT, FilesystemFAT32];
    
    [logsAutoScrollTextView appendTimestampedLine: diskEraseOperationText
                                          logType: ASLogTypeLog];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *diskEraseError = NULL;
        [destinationDiskDM diskUtilEraseDiskWithPartitionScheme: PartitionSchemeGPT
                                                     filesystem: FilesystemFAT32
                                                        newName: newPartitionName
                                                          error: &diskEraseError];
        
        if (diskEraseError != NULL) {
            [self displayWarningAlertWithTitle: DISK_ERASE_FAILURE_TITLE
                                      subtitle: @""
                                          icon: NSImageNameCaution];
            
            [self->logsAutoScrollTextView appendTimestampedLine: DISK_ERASE_FAILURE_TITLE
                                                        logType: ASLogTypeFatal];
            
            return;
        }
        
        [self->logsAutoScrollTextView appendTimestampedLine: DISK_ERASE_SUCCESS_TITLE
                                                    logType: ASLogTypeSuccess];
        
        DWFilesContainer *filesContainer = [DWFilesContainer containerFromContainerPath: mountedImagePath
                                                                               callback: ^enum DWAction(DWFile * _Nonnull fileInfo, enum DWFilesContainerMessage message) {
            /*
            switch(message) {
                case DWFilesContainerMessageGetAttributesProcess:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Getting file Attributes]: [%@]", fileInfo.sourcePath]
                                                                logType: ASLogTypeLog];
                    break;
                case DWFilesContainerMessageGetAttributesSuccess:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Got file Attributes]: [%@] [File Size: %@]", fileInfo.sourcePath, fileInfo.unitFormattedSize]
                                                                logType: ASLogTypeSuccess];
                    break;
                case DWFilesContainerMessageGetAttributesFailure:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Can't get file Attributes]: [%@]", fileInfo.sourcePath]
                                                                logType: ASLogTypeError];
                    break;
            }
            */
            return DWActionContinue;
        }];
        
        NSUInteger filesCount = [filesContainer.files count];
        
        [self->progressBarView setMaxValueSynchronously: filesCount];
        
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->progressIndicator setMaxValue:[filesContainer.files count]];
        });
        */
         
        DiskWriter *diskWriter = [[DiskWriter alloc] initWithDWFilesContainer: filesContainer
                                                              destinationPath: targetPartitionPath
                                                                     bootMode: BootModeUEFI
                                                        destinationFilesystem: FilesystemFAT32];
        
        NSError *writeError = NULL;
        BOOL writeSuccessful = [diskWriter writeWindows_8_10_ISOWithError: &writeError
                                                                 callback: ^enum DWAction(DWFile * _Nonnull fileInfo, enum DWMessage message) {
            NSString *destinationCurrentFilePath = [targetPartitionPath stringByAppendingPathComponent:fileInfo.sourcePath];
                        
            switch (message) {
                case DWMessageCreateDirectoryProcess:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Creating Directory]: [%@]", destinationCurrentFilePath]
                                                                logType: ASLogTypeLog];
                    break;
                case DWMessageCreateDirectorySuccess:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Directory successfully created]: [%@]", destinationCurrentFilePath]
                                                                logType: ASLogTypeSuccess];
                    
                    [self->progressBarView incrementBySynchronously:1];

                    break;
                case DWMessageCreateDirectoryFailure:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Can't create Directory]: [%@]", destinationCurrentFilePath]
                                                                logType: ASLogTypeError];
                    break;
                case DWMessageSplitWindowsImageProcess:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Splitting Windows Image]: [%@ (.swm)] {File Size: >%@}", destinationCurrentFilePath, fileInfo.unitFormattedSize]
                                                                logType: ASLogTypeLog];
                    break;
                case DWMessageSplitWindowsImageSuccess:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Windows Image successfully splitted]: [%@ (.swm)] {File Size: >%@}", destinationCurrentFilePath, fileInfo.unitFormattedSize]
                                                                logType: ASLogTypeSuccess];
                    
                    [self->progressBarView incrementBySynchronously:1];

                    break;
                case DWMessageSplitWindowsImageFailure:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Can't split Windows Image]: [%@ (.swm)] {File Size: >%@}", destinationCurrentFilePath, fileInfo.unitFormattedSize]
                                                                logType: ASLogTypeError];
                    break;
                case DWMessageExtractWindowsBootloaderProcess:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Extracting Windows Bootloader from the Install file]: [%@]", destinationCurrentFilePath]
                                                                logType: ASLogTypeLog];
                    break;
                case DWMessageExtractWindowsBootloaderSuccess:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Windows Bootloader successfully extracted from the Install file]: [%@]", destinationCurrentFilePath]
                                                                logType: ASLogTypeSuccess];
                    
                    [self->progressBarView incrementBySynchronously:1];

                    break;
                case DWMessageExtractWindowsBootloaderFailure:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Can't extract Windows Bootloader from the Install file]: [%@]", destinationCurrentFilePath]
                                                                logType: ASLogTypeError];
                    break;
                case DWMessageWriteFileProcess:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Writing File]: [%@ → %@] {File Size: %@}", fileInfo.sourcePath, destinationCurrentFilePath, fileInfo.unitFormattedSize]
                                                                logType: ASLogTypeLog];
                    break;
                case DWMessageWriteFileSuccess:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[File was successfully written]: [%@ → %@] {File Size: %@}", fileInfo.sourcePath, destinationCurrentFilePath, fileInfo.unitFormattedSize]
                                                                logType: ASLogTypeSuccess];
                    
                    [self->progressBarView incrementBySynchronously:1];

                    break;
                case DWMessageWriteFileFailure:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Can't write File]: [%@ → %@] {File Size: %@}", fileInfo.sourcePath, destinationCurrentFilePath, fileInfo.unitFormattedSize]
                                                                logType: ASLogTypeError];
                    break;
                case DWMessageFileIsTooLarge:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[File is too large]: [%@] {File Size: %@}", fileInfo.sourcePath, fileInfo.unitFormattedSize]
                                                                logType: ASLogTypeError];
                    break;
                case DWMessageUnsupportedOperation:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[Unsupported operation with this type of File]: [%@ → %@] {File Size: %@}", fileInfo.sourcePath, destinationCurrentFilePath, fileInfo.unitFormattedSize]
                                                                logType: ASLogTypeError];
                    break;
                case DWMessageEntityAlreadyExists:
                    [self->logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"[File already exists]: [%@] {File Size: %@}",  destinationCurrentFilePath, fileInfo.unitFormattedSize]
                                                                logType: ASLogTypeError];
                    break;
            }
            
            return DWActionContinue;
        }];
        
        printf("Write result: %d. Error: %s\n", writeSuccessful, [[[writeError userInfo] objectForKey:DEFAULT_ERROR_KEY] UTF8String]);
    });
    
    
}

- (void)chooseImageAction {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseFiles: YES];
    [openPanel setCanChooseDirectories: YES];
    [openPanel setAllowsMultipleSelection: NO];
    [openPanel setAllowedFileTypes: @[@"iso"]];
    
    [openPanel runModal];
    
    NSString *path = openPanel.URL.path;
    if (path == NULL) {
        return;
    }
    
    [windowsImageInputView setStringValue:path];
    
}

- (void)updateDeviceList {
    [devicePickerView removeAllItemsWithAssociatedObjects];
    
    [logsAutoScrollTextView appendTimestampedLine:@"Clearing the device picker list." logType:ASLogTypeLog];
    
    NSArray<NSString *> *bsdNames = [DiskManager getBSDDrivesNames];
    
    NSString *textLog = [NSString stringWithFormat:@"Found devices: %@", [bsdNames componentsJoinedByString:@", "]];
    [logsAutoScrollTextView appendTimestampedLine:textLog logType:ASLogTypeLog];
    
    for (NSString *bsdName in bsdNames) {
        DiskManager *diskManager = [[DiskManager alloc] initWithBSDName: bsdName];
        struct DiskInfo diskInfo = [diskManager getDiskInfo];
        
        NSString *title = [NSString stringWithFormat:@"%@ %@ [%@] (%@)", diskInfo.deviceVendor, diskInfo.deviceModel, diskInfo.mediaSize, bsdName];
        
        if (diskInfo.isNetworkVolume || diskInfo.isInternal ||
            !diskInfo.isDeviceUnit || !diskInfo.isWholeDrive) {
            continue;
        }
        
        [devicePickerView addItemWithTitle: title
                          associatedObject: bsdName];
        
    }
    
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupWindow];
    
    NSView *spacerView = [[NSView alloc] init];
    
    CGFloat titlebarHeight = 0;
    if (@available(macOS 10.10, *)) {
        titlebarHeight = window.contentView.frame.size.height - window.contentLayoutRect.size.height;
    }
    
    const CGFloat mainContentGroupsSpacing = 6;
    const CGFloat childElementsSpacing = 6;
    
    FrameLayoutVertical *mainVerticalLayout = [self setupMainVerticalViewWithPaddingTop: titlebarHeight + childElementsSpacing / 2
                                                                                 bottom: childElementsSpacing
                                                                                   left: childElementsSpacing
                                                                                  right: childElementsSpacing
                                                                                 nsView: window.contentView];
    
    [mainVerticalLayout setSpacing: mainContentGroupsSpacing];
    
    FrameLayoutVertical *isoPickerVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:isoPickerVerticalLayout width:INFINITY height:0];
        
        [isoPickerVerticalLayout setHugHeightFrame: YES];
        
        [isoPickerVerticalLayout setSpacing: childElementsSpacing];
        
        LabelView *isoPickerLabelView = [[LabelView alloc] init]; {
            [isoPickerVerticalLayout addView:isoPickerLabelView width:INFINITY height:isoPickerLabelView.cell.cellSize.height];
            
            [isoPickerLabelView setStringValue: @"Windows Image"];
            
            [isoPickerLabelView setWantsLayer: YES];
        }
        
        FrameLayoutHorizontal *isoPickerHorizontalLayout = [[FrameLayoutHorizontal alloc] init]; {
            [isoPickerVerticalLayout addView:isoPickerHorizontalLayout width:INFINITY height:0];
            
            [isoPickerHorizontalLayout setHugHeightFrame: YES];
            
            [isoPickerHorizontalLayout setVerticalAlignment: FrameLayoutVerticalCenter];
            
            [isoPickerHorizontalLayout setSpacing: childElementsSpacing];
            
            windowsImageInputView = [[TextInputView alloc] init]; {
                [isoPickerHorizontalLayout addView:windowsImageInputView width:INFINITY height:windowsImageInputView.cell.cellSize.height];
                
                if (@available(macOS 10.10, *)) {
                    [windowsImageInputView setPlaceholderString: @"Image File or Directory"];
                }
            }
            
            ButtonView *chooseWindowsImageButtonView = [[ButtonView alloc] init]; {
                [isoPickerHorizontalLayout addView:chooseWindowsImageButtonView minWidth:80 maxWidth:100 minHeight:0 maxHeight:INFINITY];
                
                [chooseWindowsImageButtonView setTitle:@"Choose"];
                [chooseWindowsImageButtonView setTarget:self];
                [chooseWindowsImageButtonView setAction:@selector(chooseImageAction)];
                
            }
        }
    }
    
    FrameLayoutVertical *devicePickerVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:devicePickerVerticalLayout width:INFINITY height:0];
        
        [devicePickerVerticalLayout setHugHeightFrame:YES];
        
        [devicePickerVerticalLayout setSpacing: childElementsSpacing];
        
        
        LabelView *devicePickerLabelView = [[LabelView alloc] init]; {
            [devicePickerVerticalLayout addView:devicePickerLabelView width:INFINITY height:devicePickerLabelView.cell.cellSize.height];
            
            [devicePickerLabelView setStringValue: @"Target Device"];
        }
        
        FrameLayoutHorizontal *devicePickerHorizontalLayout = [[FrameLayoutHorizontal alloc] init]; {
            [devicePickerVerticalLayout addView:devicePickerHorizontalLayout width:INFINITY height:0];
            
            [devicePickerHorizontalLayout setHugHeightFrame:YES];
            
            devicePickerView = [[PickerView alloc] init]; {
                [devicePickerHorizontalLayout addView:devicePickerView minWidth:0 maxWidth:INFINITY minHeight:0 maxHeight:devicePickerView.cell.cellSize.height];
                
                //[devicePickerView addItemWithTitle: @"Первый"];
                //[devicePickerView addItemWithTitle: @"Второй"];
                //[devicePickerView addItemWithTitle: @"Третий"];
            }
            
            ButtonView *updateDeviceListButtonView = [[ButtonView alloc] init]; {
                [devicePickerHorizontalLayout addView:updateDeviceListButtonView minWidth:80 maxWidth:100 minHeight:0 maxHeight:INFINITY];
                
                [updateDeviceListButtonView setTitle: @"Update"];
                [updateDeviceListButtonView setTarget: self];
                [updateDeviceListButtonView setAction: @selector(updateDeviceList)];
            }
        }
    }
    
    [mainVerticalLayout addView:spacerView width:INFINITY height: 3];
    
    formatDeviceCheckboxView = [[CheckBoxView alloc] init]; {
        [mainVerticalLayout addView:formatDeviceCheckboxView width:INFINITY height:formatDeviceCheckboxView.cell.cellSize.height];
        
        [formatDeviceCheckboxView setTitle: @"Format Device (Required)"];
        [formatDeviceCheckboxView setIntegerValue: YES];
        [formatDeviceCheckboxView setEnabled: NO];
    }
    
    [mainVerticalLayout addView:spacerView width:INFINITY height: 3];
    
    
    FrameLayoutVertical *formattingSectionVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:formattingSectionVerticalLayout width:INFINITY height:0];
        
        [formattingSectionVerticalLayout setHugHeightFrame: YES];
        [formattingSectionVerticalLayout setSpacing:childElementsSpacing];
        
        FrameLayoutVertical *fileSystemPickerVerticalLayout = [[FrameLayoutVertical alloc] init]; {
            [formattingSectionVerticalLayout addView:fileSystemPickerVerticalLayout width:INFINITY height:0];
            [fileSystemPickerVerticalLayout setHugHeightFrame: YES];
            
            [fileSystemPickerVerticalLayout setSpacing:childElementsSpacing];
            
            LabelView *filesystemLabelView = [[LabelView alloc] init]; {
                [fileSystemPickerVerticalLayout addView:filesystemLabelView width:INFINITY height:filesystemLabelView.cell.cellSize.height];
                
                [filesystemLabelView setStringValue: @"File System"];
            }
            
            filesystemPickerSegmentedControl = [[NSSegmentedControl alloc] init]; {
                [filesystemPickerSegmentedControl setSegmentCount:2];
                
                [filesystemPickerSegmentedControl setLabel:@"FAT32" forSegment:0];
                [filesystemPickerSegmentedControl setLabel:@"ExFAT" forSegment:1];
                
                [filesystemPickerSegmentedControl setSelectedSegment:0];
                
                [fileSystemPickerVerticalLayout addView:filesystemPickerSegmentedControl width:INFINITY height:filesystemPickerSegmentedControl.cell.cellSize.height];
            }
        }
        
        FrameLayoutVertical *partitionSchemePickerVerticalLayout = [[FrameLayoutVertical alloc] init]; {
            [formattingSectionVerticalLayout addView:partitionSchemePickerVerticalLayout width:INFINITY height:0];
            
            [partitionSchemePickerVerticalLayout setHugHeightFrame: YES];
            [partitionSchemePickerVerticalLayout setSpacing: childElementsSpacing];
            
            LabelView *partitionSchemeLabelView = [[LabelView alloc] init]; {
                [partitionSchemePickerVerticalLayout addView: partitionSchemeLabelView
                                                    minWidth: 0
                                                    maxWidth: INFINITY
                                                   minHeight: partitionSchemeLabelView.cell.cellSize.height
                                                   maxHeight: partitionSchemeLabelView.cell.cellSize.height];
                
                [partitionSchemeLabelView setStringValue:@"Partition Scheme"];
                [partitionSchemeLabelView setEnabled: NO];
                
            }
            
            partitionSchemePickerSegmentedControl = [[NSSegmentedControl alloc] init]; {
                [partitionSchemePickerSegmentedControl setSegmentCount:2];
                
                [partitionSchemePickerSegmentedControl setEnabled: NO];
                
                [partitionSchemePickerSegmentedControl setLabel:@"MBR" forSegment:0];
                [partitionSchemePickerSegmentedControl setLabel:@"GPT" forSegment:1];
                
                [partitionSchemePickerSegmentedControl setSelectedSegment:0];
                
                [partitionSchemePickerVerticalLayout addView:partitionSchemePickerSegmentedControl minWidth:0 maxWidth:INFINITY minHeight:partitionSchemePickerSegmentedControl.cell.cellSize.height maxHeight:partitionSchemePickerSegmentedControl.cell.cellSize.height];
            }
        }
        
    }
    
    [mainVerticalLayout addView:spacerView width:4 height:4];
    
    logsAutoScrollTextView = [[AutoScrollTextView alloc] init]; {
        [mainVerticalLayout addView:logsAutoScrollTextView minWidth:0 maxWidth:INFINITY minHeight:120 maxHeight:INFINITY];
        
        
        
    }
    
    [mainVerticalLayout addView:spacerView width:0 height:4];
    
    FrameLayoutVertical *startStopVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:startStopVerticalLayout width:INFINITY height:INFINITY];
        
        [startStopVerticalLayout setHorizontalAlignment: FrameLayoutHorizontalCenter];
        [startStopVerticalLayout setVerticalAlignment: FrameLayoutVerticalCenter];
        
        [startStopVerticalLayout setSpacing:10];
        
        [startStopVerticalLayout setHugHeightFrame: YES];
        
        ButtonView *startStopButtonView = [[ButtonView alloc] init]; {
            [startStopVerticalLayout addView:startStopButtonView minWidth:40 maxWidth:180 minHeight:startStopButtonView.cell.cellSize.height maxHeight:startStopButtonView.cell.cellSize.height];
            
            [startStopButtonView setTitle: @"Start"];
            [startStopButtonView setTarget: self];
            [startStopButtonView setAction:@selector(startStopAction)];
        }
        
        progressBarView = [[ProgressBarView alloc] init]; {
            [startStopVerticalLayout addView:progressBarView width:INFINITY height:8];
            [progressBarView setIndeterminate: NO];
        }
    }
    
    
    
    LabelView *developerNameLabelView = [[LabelView alloc] init]; {
        [mainVerticalLayout addView:developerNameLabelView width:INFINITY height:developerNameLabelView.cell.cellSize.height];
        
        [developerNameLabelView setAlignment:NSTextAlignmentCenter];
        
        [developerNameLabelView setStringValue: @"TechUnRestricted 2023"];
    }
    
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return NO;
}

@end
