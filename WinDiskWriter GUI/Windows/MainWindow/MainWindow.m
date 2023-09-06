//
//  MainWindow.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 30.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "MainWindow.h"
#import "FrameLayout.h"
#import "LabelView.h"
#import "ButtonView.h"
#import "PickerView.h"
#import "TextInputView.h"
#import "CheckBoxView.h"
#import "AdvancedTextView.h"
#import "ProgressBarView.h"

#import "SynchronizedAlertData.h"

#import "NSColor+Common.h"
#import "NSString+Common.h"
#import "NSError+Common.h"

#import "Constants.h"

#import "DiskManager.h"
#import "DiskWriter.h"
#import "HDIUtil.h"

#import "HelperFunctions.h"

#import "ModernWindow.h"
#import "AboutWindow.h"

#define WriteExitForce()                \
[self setEnabledUIState: YES];          \
return;

#define WriteExitConditionally()      \
if (self.isScheduledForStop) {        \
WriteExitForce();                     \
}

@implementation MainWindow {
    /* Initialized in -setupViews: */
    TextInputView *windowsImageInputView;
    ButtonView *chooseWindowsImageButtonView;
    
    PickerView *devicePickerView;
    ButtonView *updateDeviceListButtonView;
    
    CheckBoxView *skipSecurityChecksCheckboxView;
    NSSegmentedControl *filesystemPickerSegmentedControl;
    NSSegmentedControl *partitionSchemePickerSegmentedControl;
    
    AdvancedTextView *logsAutoScrollTextView;
    
    ButtonView *startStopButtonView;
    
    FrameLayoutHorizontal *bytesProgressHorizontalLayout;
    LabelView *currentOperationLabelView;
    LabelView *bytesWrittenLabelView;
    LabelView *slashSeparatorLabelView;
    LabelView *bytesFileSizeLabelView;
    
    ProgressBarView *currentOperationProgressBarView;
    ProgressBarView *totalOperationProgressBarView;
    
    NSMenuItem* quitMenuItem;
    
    ModernWindow *aboutWindow;
}

- (instancetype)initWithNSRect: (NSRect)nsRect
                         title: (NSString *)title
                       padding: (CGFloat)padding
                   aboutWindow: (AboutWindow *)aboutWindow
                  quitMenuItem: quitMenuItem {
    
    self = [super initWithNSRect: nsRect
                           title: title
                         padding: padding];
    
    self->aboutWindow = aboutWindow;
    self->quitMenuItem = quitMenuItem;
    
    NSButton *windowZoomButton = [self standardWindowButton:NSWindowZoomButton];
    [windowZoomButton setEnabled: NO];
    
    [self setOnCloseSelector: @selector(exitApplication)
                      target: self];
    
    [self setupViews];
    
    return self;
}

- (void)resetProgress {
    [self setCurrentProgressWithWrittenBytes: 0
                             fileSizeBytes: 0];
    
    [currentOperationProgressBarView resetProgressSynchronously];
    [totalOperationProgressBarView resetProgressSynchronously];
}

- (void)setupViews {
    NSView *spacerView = [[NSView alloc] init];
    
    [self showWindow];
    
    FrameLayoutVertical *mainVerticalLayout = (FrameLayoutVertical *)self.containerView;
    
    [mainVerticalLayout setSpacing: MAIN_CONTENT_SPACING];
    
    FrameLayoutVertical *isoPickerVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:isoPickerVerticalLayout width:INFINITY height:0];
        
        [isoPickerVerticalLayout setHugHeightFrame: YES];
        
        [isoPickerVerticalLayout setSpacing: CHILD_CONTENT_SPACING];
        
        LabelView *isoPickerLabelView = [[LabelView alloc] init]; {
            [isoPickerVerticalLayout addView:isoPickerLabelView width:INFINITY height:isoPickerLabelView.cell.cellSize.height];
            
            [isoPickerLabelView setStringValue: @"Windows Image"];
            
            [isoPickerLabelView setWantsLayer: YES];
        }
        
        FrameLayoutHorizontal *isoPickerHorizontalLayout = [[FrameLayoutHorizontal alloc] init]; {
            [isoPickerVerticalLayout addView:isoPickerHorizontalLayout width:INFINITY height:0];
            
            [isoPickerHorizontalLayout setHugHeightFrame: YES];
            
            [isoPickerHorizontalLayout setVerticalAlignment: FrameLayoutVerticalCenter];
            
            [isoPickerHorizontalLayout setSpacing: CHILD_CONTENT_SPACING];
            
            windowsImageInputView = [[TextInputView alloc] init]; {
                [isoPickerHorizontalLayout addView:windowsImageInputView width:INFINITY height:windowsImageInputView.cell.cellSize.height];
                
                if (@available(macOS 10.10, *)) {
                    [windowsImageInputView setPlaceholderString: @"Image File or Directory"];
                }
            }
            
            chooseWindowsImageButtonView = [[ButtonView alloc] init]; {
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
        
        [devicePickerVerticalLayout setSpacing: CHILD_CONTENT_SPACING];
        
        
        LabelView *devicePickerLabelView = [[LabelView alloc] init]; {
            [devicePickerVerticalLayout addView:devicePickerLabelView width:INFINITY height:devicePickerLabelView.cell.cellSize.height];
            
            [devicePickerLabelView setStringValue: @"Target Device"];
        }
        
        FrameLayoutHorizontal *devicePickerHorizontalLayout = [[FrameLayoutHorizontal alloc] init]; {
            [devicePickerVerticalLayout addView:devicePickerHorizontalLayout width:INFINITY height:0];
            
            [devicePickerHorizontalLayout setHugHeightFrame:YES];
            
            devicePickerView = [[PickerView alloc] init]; {
                [devicePickerHorizontalLayout addView:devicePickerView minWidth:0 maxWidth:INFINITY minHeight:0 maxHeight:devicePickerView.cell.cellSize.height];
                
                [self updateDeviceList];
            }
            
            updateDeviceListButtonView = [[ButtonView alloc] init]; {
                [devicePickerHorizontalLayout addView:updateDeviceListButtonView minWidth:80 maxWidth:100 minHeight:0 maxHeight:INFINITY];
                
                [updateDeviceListButtonView setTitle: @"Update"];
                [updateDeviceListButtonView setTarget: self];
                [updateDeviceListButtonView setAction: @selector(updateDeviceList)];
            }
        }
    }
    
    [mainVerticalLayout addView:spacerView width:INFINITY height: 3];
    
    skipSecurityChecksCheckboxView = [[CheckBoxView alloc] init]; {
        [mainVerticalLayout addView:skipSecurityChecksCheckboxView width:INFINITY height:skipSecurityChecksCheckboxView.cell.cellSize.height];
        
        [skipSecurityChecksCheckboxView setTitle: @"Patch Installer Requirements"];
        [skipSecurityChecksCheckboxView setState: NSOffState];
    }
    
    [mainVerticalLayout addView:spacerView width:INFINITY height: 3];
    
    
    FrameLayoutVertical *formattingSectionVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:formattingSectionVerticalLayout width:INFINITY height:0];
        
        [formattingSectionVerticalLayout setHugHeightFrame: YES];
        [formattingSectionVerticalLayout setSpacing:CHILD_CONTENT_SPACING];
        
        FrameLayoutVertical *fileSystemPickerVerticalLayout = [[FrameLayoutVertical alloc] init]; {
            [formattingSectionVerticalLayout addView:fileSystemPickerVerticalLayout width:INFINITY height:0];
            [fileSystemPickerVerticalLayout setHugHeightFrame: YES];
            
            [fileSystemPickerVerticalLayout setSpacing:CHILD_CONTENT_SPACING];
            
            LabelView *filesystemLabelView = [[LabelView alloc] init]; {
                [fileSystemPickerVerticalLayout addView:filesystemLabelView width:INFINITY height:filesystemLabelView.cell.cellSize.height];
                
                [filesystemLabelView setStringValue: @"File System"];
            }
            
            filesystemPickerSegmentedControl = [[NSSegmentedControl alloc] init]; {
                [filesystemPickerSegmentedControl setSegmentCount:2];
                
                [filesystemPickerSegmentedControl setLabel:FILESYSTEM_TYPE_FAT32_TITLE forSegment:0];
                [filesystemPickerSegmentedControl setLabel:FILESYSTEM_TYPE_EXFAT_TITLE forSegment:1];
                
                [filesystemPickerSegmentedControl setSelectedSegment:0];
                
                [fileSystemPickerVerticalLayout addView:filesystemPickerSegmentedControl width:INFINITY height:filesystemPickerSegmentedControl.cell.cellSize.height];
            }
        }
        
        FrameLayoutVertical *partitionSchemePickerVerticalLayout = [[FrameLayoutVertical alloc] init]; {
            [formattingSectionVerticalLayout addView:partitionSchemePickerVerticalLayout width:INFINITY height:0];
            
            [partitionSchemePickerVerticalLayout setHugHeightFrame: YES];
            [partitionSchemePickerVerticalLayout setSpacing: CHILD_CONTENT_SPACING];
            
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
                
                [partitionSchemePickerSegmentedControl setLabel: PARTITION_SCHEME_TYPE_MBR_TITLE
                                                     forSegment: 0];
                [partitionSchemePickerSegmentedControl setLabel: PARTITION_SCHEME_TYPE_GPT_TITLE
                                                     forSegment: 1];
                
                [partitionSchemePickerSegmentedControl setSelectedSegment:0];
                
                [partitionSchemePickerVerticalLayout addView:partitionSchemePickerSegmentedControl minWidth:0 maxWidth:INFINITY minHeight:partitionSchemePickerSegmentedControl.cell.cellSize.height maxHeight:partitionSchemePickerSegmentedControl.cell.cellSize.height];
            }
        }
        
    }
    
    [mainVerticalLayout addView:spacerView width:4 height:4];
    
    logsAutoScrollTextView = [[AdvancedTextView alloc] init]; {
        [logsAutoScrollTextView setAutomaticallyScroll: YES];
        
        [mainVerticalLayout addView:logsAutoScrollTextView minWidth:0 maxWidth:INFINITY minHeight:120 maxHeight:INFINITY];
    }
    
    [mainVerticalLayout addView:spacerView width:0 height:4];
    
    FrameLayoutVertical *operationMonitoringVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:operationMonitoringVerticalLayout width:INFINITY height:0];
        
        [operationMonitoringVerticalLayout setHugHeightFrame: YES];
        
        [operationMonitoringVerticalLayout setSpacing: 2];
        
        FrameLayoutHorizontal *textInfoHorizontalLayout = [[FrameLayoutHorizontal alloc] init]; {
            [operationMonitoringVerticalLayout addView:textInfoHorizontalLayout width:INFINITY height:0];
            
            [textInfoHorizontalLayout setAlphaValue: 0.75];
            
            [textInfoHorizontalLayout setHugHeightFrame: YES];
            
            currentOperationLabelView = [[LabelView alloc] init]; {
                [textInfoHorizontalLayout addView:currentOperationLabelView width:INFINITY height:currentOperationLabelView.cell.cellSize.height];
            }
            
            bytesProgressHorizontalLayout = [[FrameLayoutHorizontal alloc] init]; {
                [textInfoHorizontalLayout addView:bytesProgressHorizontalLayout width:0 height:0];
                
                [bytesProgressHorizontalLayout setHugHeightFrame: YES];
                [bytesProgressHorizontalLayout setHugWidthFrame: YES];
                
                bytesWrittenLabelView = [[LabelView alloc] init]; {
                    // Reserving a space for symbols in order to get a proper cellSize values
                    [bytesWrittenLabelView setStringValue: @"000.00 KB"];
                    
                    [bytesWrittenLabelView setAlignment: NSTextAlignmentCenter];
                    
                    [bytesProgressHorizontalLayout addView: bytesWrittenLabelView
                                                     width: bytesWrittenLabelView.cell.cellSize.width
                                                    height: bytesWrittenLabelView.cell.cellSize.height];
                }
                
                slashSeparatorLabelView = [[LabelView alloc] init]; {
                    [slashSeparatorLabelView setStringValue: @"/"];
                    
                    [bytesProgressHorizontalLayout addView: slashSeparatorLabelView
                                                     width: slashSeparatorLabelView.cell.cellSize.width
                                                    height: slashSeparatorLabelView.cell.cellSize.height];
                }
                
                bytesFileSizeLabelView = [[LabelView alloc] init]; {
                    // Reserving a space for symbols in order to get a proper cellSize values
                    [bytesFileSizeLabelView setStringValue: @"000.00 KB"];
                    
                    [bytesFileSizeLabelView setAlignment: NSTextAlignmentCenter];
                    
                    [bytesProgressHorizontalLayout addView: bytesFileSizeLabelView
                                                     width: bytesFileSizeLabelView.cell.cellSize.width
                                                    height: bytesFileSizeLabelView.cell.cellSize.height];
                }
            }
        }
        
        FrameLayoutVertical *progressBarVerticalLayout = [[FrameLayoutVertical alloc] init]; {
            [operationMonitoringVerticalLayout addView:progressBarVerticalLayout width:INFINITY height:0];
            
            [progressBarVerticalLayout setHugHeightFrame: YES];
            
            currentOperationProgressBarView = [[ProgressBarView alloc] init]; {
                [progressBarVerticalLayout addView:currentOperationProgressBarView width:INFINITY height:14];
            }
            
            totalOperationProgressBarView = [[ProgressBarView alloc] init]; {
                [progressBarVerticalLayout addView:totalOperationProgressBarView width:INFINITY height:14];
            }
        }
        
    }
    
    FrameLayoutVertical *startStopVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:startStopVerticalLayout width:INFINITY height:50];
        
        [startStopVerticalLayout setHorizontalAlignment: FrameLayoutHorizontalCenter];
        [startStopVerticalLayout setVerticalAlignment: FrameLayoutVerticalCenter];
        
        [startStopVerticalLayout setSpacing:10];
        
        // [startStopVerticalLayout setHugHeightFrame: YES];
        
        startStopButtonView = [[ButtonView alloc] init]; {
            [startStopVerticalLayout addView:startStopButtonView minWidth:40 maxWidth:180 minHeight:startStopButtonView.cell.cellSize.height maxHeight:startStopButtonView.cell.cellSize.height];
            
            [startStopButtonView setTarget: self];
        }
        
    }
    
    LabelView *developerNameLabelView = [[LabelView alloc] init]; {
        [mainVerticalLayout addView:developerNameLabelView width:INFINITY height:developerNameLabelView.cell.cellSize.height];
        
        [developerNameLabelView setAlignment:NSTextAlignmentCenter];
        
        [developerNameLabelView setStringValue: [NSString stringWithFormat:@"%@ 2023", DEVELOPER_NAME]];
    }
    
    [self setEnabledUIState: YES];
    
}

- (void)exitApplication {
    [[NSApplication sharedApplication] terminate:nil];
}

- (void)displayWarningAlertWithTitle: (NSString *)title
                            subtitle: (NSString *_Nullable)subtitle
                                icon: (NSImageName)icon {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText: title];
        
        if (subtitle) {
            [alert setInformativeText: subtitle];
        }
        
        [alert setIcon: [NSImage imageNamed: icon]];
        
        [alert beginSheetModalForWindow: self
                          modalDelegate: NULL
                         didEndSelector: NULL
                            contextInfo: NULL];
    });
}

- (void)alertActionStopPromptDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertSecondButtonReturn) {
        [startStopButtonView setTitle: BUTTON_STOPPING_TITLE];
        
        [startStopButtonView setEnabled: NO];
        
        [self setIsScheduledForStop: YES];
    }
}

- (void)alertWarnAboutErrorDuringWriting: (NSAlert *)alert
                              returnCode: (NSInteger)returnCode
                             contextInfo: (void *)contextInfo {
    SynchronizedAlertData *synchronizedAlertData = (__bridge SynchronizedAlertData *)(contextInfo);
    [synchronizedAlertData setResultCode:returnCode];
    
    dispatch_semaphore_signal(synchronizedAlertData.semaphore);
}

- (void)stopAction {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText: STOP_PROCESS_PROMPT_TITLE];
    [alert setInformativeText: STOP_PROCESS_PROMPT_SUBTITLE];
    [alert addButtonWithTitle: BUTTON_DISMISS_TITLE];
    [alert addButtonWithTitle: BUTTON_SCHEDULE_CANCELLATION_TITLE];
    
    [alert beginSheetModalForWindow: self
                      modalDelegate: self
                     didEndSelector: @selector(alertActionStopPromptDidEnd:returnCode:contextInfo:)
                        contextInfo: NULL];
}

- (void)alertActionStartPromptDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertSecondButtonReturn) {
        [self writeAction];
    }
}

- (void)startAction {
    NSString *imagePath = [windowsImageInputView.stringValue copy];
    if (imagePath.length == 0) {
        
        [self displayWarningAlertWithTitle: FORGOT_SOMETHING_TITLE
                                  subtitle: PATH_FIELD_IS_EMPTY_SUBTITLE
                                      icon: NSImageNameCaution];
        
        [logsAutoScrollTextView appendTimestampedLine: PATH_FIELD_IS_EMPTY_SUBTITLE
                                              logType: ASLogTypeAssertionError];
        WriteExitForce();
    }
    
    BOOL imagePathIsDirectory = NO;
    BOOL imageExists = [[NSFileManager defaultManager] fileExistsAtPath: imagePath
                                                            isDirectory: &imagePathIsDirectory];
    
    if (!imageExists) {
        [self displayWarningAlertWithTitle: CHECK_DATA_CORRECTNESS_TITLE
                                  subtitle: PATH_DOES_NOT_EXIST_SUBTITLE
                                      icon: NSImageNameCaution];
        
        [logsAutoScrollTextView appendTimestampedLine: PATH_DOES_NOT_EXIST_SUBTITLE
                                              logType: ASLogTypeAssertionError];
        
        WriteExitForce();
    }
    
    if ([devicePickerView numberOfItems] <= 0) {
        [self displayWarningAlertWithTitle: NO_AVAILABLE_DEVICES_TITLE
                                  subtitle: PRESS_UPDATE_BUTTON_SUBTITLE
                                      icon: NSImageNameCaution];
        
        [logsAutoScrollTextView appendTimestampedLine: NO_AVAILABLE_DEVICES_TITLE
                                              logType: ASLogTypeAssertionError];
        WriteExitForce();
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText: START_PROCESS_PROMPT_TITLE];
    [alert setInformativeText: START_PROCESS_PROMPT_SUBTITLE];
    [alert addButtonWithTitle: BUTTON_CANCEL_TITLE];
    [alert addButtonWithTitle: BUTTON_START_TITLE];
    
    [alert beginSheetModalForWindow: self
                      modalDelegate: self
                     didEndSelector: @selector(alertActionStartPromptDidEnd:returnCode:contextInfo:)
                        contextInfo: NULL];
}

- (void)setCurrentProgressWithWrittenBytes: (UInt64)writtenBytes
                             fileSizeBytes: (UInt64)fileSizeBytes {
    dispatch_async(dispatch_get_main_queue(), ^{
        // We don't need to display progress in bytes if the file size is 0 bytes.
        if (fileSizeBytes == 0) {
            [self->bytesProgressHorizontalLayout setHidden: YES];
            return;
        }
        
        // Otherwise, show the bytes progress layout (if hidden)
        if (self->bytesProgressHorizontalLayout.isHidden) {
            [self->bytesProgressHorizontalLayout setHidden: NO];
        }
        
        // Setting the progress bytes formatted string
        [self->bytesWrittenLabelView setStringValue: [HelperFunctions unitFormattedSizeFor: writtenBytes]];
        [self->bytesFileSizeLabelView setStringValue: [HelperFunctions unitFormattedSizeFor: fileSizeBytes]];
        
        // Setting the progress bar current operation progress
        [self->currentOperationProgressBarView setMaxValue: fileSizeBytes];
        [self->currentOperationProgressBarView setDoubleValue: writtenBytes];
    });
}

- (void)setCurrentProgressTitle: (NSString *)progressTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->currentOperationLabelView setStringValue: progressTitle];
    });
}

- (void)writeAction {
    [self setIsScheduledForStop: NO];
    [self setEnabledUIState: NO];
    
    NSString *bsdName = [(IdentifiableMenuItem *)devicePickerView.selectedItem userIdentifiableData];
    DiskManager *destinationDiskDM = [[DiskManager alloc] initWithBSDName:bsdName];
    
    struct DiskInfo destinationDiskInfo = [destinationDiskDM getDiskInfo];
    if (destinationDiskDM == NULL || !destinationDiskInfo.isDeviceUnit) {
        [self displayWarningAlertWithTitle: BSD_DEVICE_IS_NO_LONGER_AVAILABLE_TITLE
                                  subtitle: PRESS_UPDATE_BUTTON_SUBTITLE
                                      icon: NSImageNameCaution];
        
        [logsAutoScrollTextView appendTimestampedLine: BSD_DEVICE_IS_NO_LONGER_AVAILABLE_TITLE
                                              logType: ASLogTypeFatal];
        WriteExitForce();
    }
    
    NSError *imageMountError = NULL;
    NSString *mountedImagePath = [HelperFunctions getWindowsSourceMountPath: windowsImageInputView.stringValue
                                                                      error: &imageMountError];
    if (imageMountError != NULL) {
        NSString *errorSubtitle = imageMountError.stringValue;
        NSString *logText = [NSString stringWithFormat:@"%@ (%@)", IMAGE_VERIFICATION_ERROR_TITLE, errorSubtitle];
        
        [self displayWarningAlertWithTitle: IMAGE_VERIFICATION_ERROR_TITLE
                                  subtitle: errorSubtitle
                                      icon: NSImageNameCaution];
        
        [logsAutoScrollTextView appendTimestampedLine: logText
                                              logType: ASLogTypeFatal];
        
        WriteExitForce();
    }
    
    Filesystem selectedFileSystem;
    if (filesystemPickerSegmentedControl.selectedSegment == 0) {
        selectedFileSystem = FilesystemFAT32;
    } else {
        selectedFileSystem = FilesystemExFAT;
    }
    
    PartitionScheme selectedPartitionScheme;
    if (partitionSchemePickerSegmentedControl.selectedSegment == 0) {
        selectedPartitionScheme = PartitionSchemeMBR;
    } else {
        selectedPartitionScheme = PartitionSchemeGPT;
    }
    
    [logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"Image was mounted successfully on \"%@\".", mountedImagePath]
                                          logType: ASLogTypeSuccess];
    
    NSString *newPartitionName = [NSString stringWithFormat:@"WDW_%@", [HelperFunctions randomStringWithLength:7]];
    [logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"Generated partition name: \"%@\".", newPartitionName]
                                          logType: ASLogTypeLog];
    
    NSString *targetPartitionPath = [NSString stringWithFormat:@"/Volumes/%@", newPartitionName];
    [logsAutoScrollTextView appendTimestampedLine: [NSString stringWithFormat:@"Target partition path: \"%@\".", targetPartitionPath]
                                          logType: ASLogTypeLog];
    
    NSString *diskEraseOperationText = [NSString stringWithFormat:@"Device %@ (%@ %@) is ready to be erased with the following properties: (partition_name: \"%@\", partition_scheme: \"%@\", filesystem: \"%@\", patch_security_checks: \"%d\").",
                                        bsdName,
                                        destinationDiskInfo.deviceVendor,
                                        destinationDiskInfo.deviceModel,
                                        newPartitionName,
                                        selectedPartitionScheme,
                                        selectedFileSystem,
                                        skipSecurityChecksCheckboxView.state == NSOnState];
    
    [logsAutoScrollTextView appendTimestampedLine: diskEraseOperationText
                                          logType: ASLogTypeLog];
    
    BOOL skipSecurityChecks = skipSecurityChecksCheckboxView.state == NSOnState;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self setCurrentProgressTitle: @"Formatting the drive"];
        
        NSError *diskEraseError = NULL;
        [destinationDiskDM diskUtilEraseDiskWithPartitionScheme: selectedPartitionScheme
                                                     filesystem: selectedFileSystem
                                                        newName: newPartitionName
                                                          error: &diskEraseError];
                
        if (diskEraseError != NULL) {
            [self displayWarningAlertWithTitle: DISK_ERASE_FAILURE_TITLE
                                      subtitle: diskEraseError.stringValue
                                          icon: NSImageNameCaution];
            
            [self->logsAutoScrollTextView appendTimestampedLine: DISK_ERASE_FAILURE_TITLE
                                                        logType: ASLogTypeFatal];
            
            WriteExitForce();
        }
        
        [self setCurrentProgressTitle: DISK_ERASE_SUCCESS_TITLE];
        
        [self->logsAutoScrollTextView appendTimestampedLine: DISK_ERASE_SUCCESS_TITLE
                                                    logType: ASLogTypeSuccess];
        
        WriteExitConditionally();
        
        DWFilesContainer *filesContainer = [DWFilesContainer containerFromContainerPath: mountedImagePath
                                                                               callback: ^enum DWAction(DWFile * _Nonnull fileInfo, enum DWFilesContainerMessage message) {
            if (self.isScheduledForStop) {
                return DWActionStop;
            }
            
            return DWActionContinue;
        }];
        
        WriteExitConditionally();
        
        [self->totalOperationProgressBarView setMaxValueSynchronously: filesContainer.files.count + 4 /* Magic number "Just-in-case" */];
        
        DiskWriter *diskWriter = [[DiskWriter alloc] initWithDWFilesContainer: filesContainer
                                                              destinationPath: targetPartitionPath
                                                                     bootMode: BootModeUEFI
                                                        destinationFilesystem: selectedFileSystem
                                                           skipSecurityChecks: skipSecurityChecks];
        
        NSError *writeError = NULL;
                
        [diskWriter startWritingWithError: &writeError
                         progressCallback: ^DWAction(DWFile * _Nonnull dwFile, uint64 copiedBytes, DWOperationType operationType, DWOperationResult operationResult, NSError * _Nonnull error) {
            if (self.isScheduledForStop) {
                return DWActionStop;
            }
            
            // This way we can determine that we are starting a new operation. (We can also use a DWOperationResultStart for it.)
            if (copiedBytes == 0) {
                [self->currentOperationProgressBarView resetProgressSynchronously];
                
                [self setCurrentProgressTitle: [dwFile.sourcePath lastPathComponent]];
            }
            
            [self setCurrentProgressWithWrittenBytes: copiedBytes
                                       fileSizeBytes: dwFile.size];
                        
            NSString *destinationCurrentFilePath = [targetPartitionPath stringByAppendingPathComponent: dwFile.sourcePath];
            NSMutableString *onscreenLogText = [NSMutableString string];
            
            switch (operationType) {
                case DWOperationTypeCreateDirectory:
                    [onscreenLogText appendString: @"Create directory: "];
                    break;
                case DWOperationTypeWriteFile:
                    [onscreenLogText appendString: @"Write File: "];
                    break;
                case DWOperationTypeSplitWindowsImage:
                    [onscreenLogText appendString: @"Split Image: "];
                    break;
                case DWOperationTypeExtractWindowsBootloader:
                    [onscreenLogText appendString: @"Extract Bootloader: "];
                    break;
                case DWOperationTypePatchWindowsInstallerRequirements:
                    [onscreenLogText appendString: @"Patch Installer Requirements: "];
                    break;
            }
            
            [onscreenLogText appendString:destinationCurrentFilePath];
            
            switch (operationResult) {
                case DWOperationResultStart:
                    [self->logsAutoScrollTextView appendTimestampedLine:onscreenLogText logType:ASLogTypeStart];
                    break;
                case DWOperationResultProcess: {
                    
                    break;
                }
                case DWOperationResultSuccess:
                    [self->logsAutoScrollTextView appendTimestampedLine:onscreenLogText logType:ASLogTypeSuccess];
                    
                    [self->totalOperationProgressBarView incrementBySynchronously: 1];
                    break;
                case DWOperationResultFailure:
                    if (error != NULL) {
                        [onscreenLogText appendString: [NSString stringWithFormat: @" (Error message: %@)", error.stringValue]];
                    }
                    
                    [self->logsAutoScrollTextView appendTimestampedLine:onscreenLogText logType:ASLogTypeFailure];
                    break;
                case DWOperationResultSkipped:
                    [self->logsAutoScrollTextView appendTimestampedLine:onscreenLogText logType:ASLogTypeSkipped];
                    break;
            }
            
            // Handling a situation when an error occurred during writing
            if (operationResult == DWOperationResultFailure) {
                /*
                 Old Cocoa is crap.
                 Can't do anything better ¯\_(ツ)_/¯.
                 I need to support old OS X releases and maintain the modern look.
                 */
                
                SynchronizedAlertData *synchronizedAlertData = [[SynchronizedAlertData alloc] initWithSemaphore: dispatch_semaphore_create(0)];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Closing the currently displayed alert (if required).
                    [self removeAttachedSheetWithReturnCode: NSAlertFirstButtonReturn];
                    
                    NSAlert *alert = [[NSAlert alloc] init];
                    
                    [alert setMessageText: @"A problem occurred when writing a file to disk"];
                    [alert setInformativeText: [NSString stringWithFormat:@"You can skip the following file or abort the writing process.\n[%@]", destinationCurrentFilePath]];
                    
                    [alert addButtonWithTitle: @"Abort Writing"];
                    [alert addButtonWithTitle: @"Skip file"];
                    
                    [alert setIcon: [NSImage imageNamed: NSImageNameCaution]];
                    
                    [alert beginSheetModalForWindow: self
                                      modalDelegate: self
                                     didEndSelector: @selector(alertWarnAboutErrorDuringWriting:returnCode:contextInfo:)
                                        contextInfo: (__bridge void * _Nullable)(synchronizedAlertData)];
                });
                
                // Using semaphores in order to get this in sync with this thread.
                dispatch_semaphore_wait(synchronizedAlertData.semaphore, DISPATCH_TIME_FOREVER);
                
                if (synchronizedAlertData.resultCode == NSAlertFirstButtonReturn) {
                    [self setIsScheduledForStop: YES];
                    
                    return DWActionStop;
                } else {
                    return DWActionSkip;
                }
            }
            
            return DWActionContinue;
        }];
        
        WriteExitConditionally();
        
        if (writeError) {
            [self displayWarningAlertWithTitle:IMAGE_WRITING_FAILURE_TITLE subtitle:writeError.stringValue icon:NSImageNameCaution];
            [self->logsAutoScrollTextView appendTimestampedLine:writeError.stringValue logType:ASLogTypeFatal];
            
            WriteExitForce();
        }
        
        [self displayWarningAlertWithTitle:IMAGE_WRITING_SUCCESS_TITLE subtitle:IMAGE_WRITING_SUCCESS_SUBTITLE icon: NSImageNameStatusAvailable];
        [self->logsAutoScrollTextView appendTimestampedLine:IMAGE_WRITING_SUCCESS_TITLE logType:ASLogTypeSuccess];
        
        WriteExitForce();
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
    [devicePickerView removeAllItems];
    
    [logsAutoScrollTextView appendTimestampedLine:@"Clearing the device picker list." logType:ASLogTypeLog];
    
    NSArray<NSString *> *bsdNames = [DiskManager getBSDDrivesNames];
    
    NSString *textLog = [NSString stringWithFormat:@"Found devices: %@", [bsdNames componentsJoinedByString:@", "]];
    [logsAutoScrollTextView appendTimestampedLine:textLog logType:ASLogTypeLog];
    
    for (NSString *bsdName in bsdNames) {
        DiskManager *diskManager = [[DiskManager alloc] initWithBSDName: bsdName];
        struct DiskInfo diskInfo = [diskManager getDiskInfo];
        
        if (diskInfo.isNetworkVolume || diskInfo.isInternal ||
            !diskInfo.isDeviceUnit || !diskInfo.isWholeDrive || !diskInfo.isWritable) {
            continue;
        }
        
        IdentifiableMenuItem *identifiableMenuItem = [[IdentifiableMenuItem alloc] initWithDeviceVendor: [diskInfo.deviceVendor strip]
                                                                                            deviceModel: [diskInfo.deviceModel strip]
                                                                                 storageCapacityInBytes: [diskInfo.mediaSize floatValue]
                                                                                                bsdName: bsdName];
        
        [devicePickerView.menu addItem:identifiableMenuItem];
    }
    
    
}

- (void)setEnabledUIState:(BOOL)enabledUIState {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_enabledUIState = enabledUIState;
        
        [self->startStopButtonView setEnabled: YES];
        
        if (enabledUIState) {
            [self resetProgress];
            [self->currentOperationLabelView setStringValue: @"Ready for action"];

            [self->quitMenuItem setAction:@selector(terminate:)];
            
            [self->bytesWrittenLabelView setStringValue: @""];
            [self->bytesFileSizeLabelView setStringValue: @""];
                        
            [self->startStopButtonView setTitle: BUTTON_START_TITLE];
            [self->startStopButtonView setAction: @selector(startAction)];
        } else {
            [self->quitMenuItem setAction: NULL];
            
            [self->startStopButtonView setTitle: BUTTON_STOP_TITLE];
            [self->startStopButtonView setAction: @selector(stopAction)];
        }
        
        [self->updateDeviceListButtonView setEnabled: enabledUIState];
        [self->skipSecurityChecksCheckboxView setEnabled: enabledUIState];
        [self->windowsImageInputView setEnabled: enabledUIState];
        [self->devicePickerView setEnabled: enabledUIState];
        
        // [self->slashSeparatorLabelView setHidden: enabledUIState];
        
        [self->chooseWindowsImageButtonView setEnabled: enabledUIState];
        [self->filesystemPickerSegmentedControl setEnabled: enabledUIState];
        
        NSButton *windowZoomButton = [self standardWindowButton:NSWindowCloseButton];
        [windowZoomButton setEnabled: enabledUIState];
    });
}

@end
