//
//  main.m
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HelperFunctions.h"
#import "NSString+Common.h"
#import "NSError+Common.h"
#import "ArgumentsHandler.h"
#import "CommandLine.h"
#import "DiskManager.h"
#import "DiskWriter.h"
#import "Constants.h"
#import "HDIUtil.h"

void printUsage(void);

enum AvailableArguments {
	ArgumentSourceDirectory,
	ArgumentDestinationDevice,
	ArgumentFilesystem,
	ArgumentPartitionScheme,
	ArgumentDoNotErase,
	ArgumentSkipErrors
};

int main(int argc, const char *argv[]) {
	@autoreleasepool {
		NSArray *applicationArguments = NSProcessInfo.processInfo.arguments;
		
		if ([applicationArguments count] <= 1) {
			printUsage();
			exit(EXIT_FAILURE);
		}
		
		/*
		 * Initializing the list of arguments that are available for processing by the program
		 */
		
		ArgumentsHandler *argumentsHandler = [[ArgumentsHandler alloc]
											  initWithProcessArguments: applicationArguments
											  argumentObjects: @[[[ArgumentObject alloc] initWithName: @"-s"
																						   identifier: ArgumentSourceDirectory
																						   isRequired: YES
																							 isPaired: YES
																							 isUnique: YES
																 ],
																 [[ArgumentObject alloc] initWithName: @"-d"
																						   identifier: ArgumentDestinationDevice
																						   isRequired: YES
																							 isPaired: YES
																							 isUnique: YES
																 ],
																 [[ArgumentObject alloc] initWithName: @"-f"
																						   identifier: ArgumentFilesystem
																						   isRequired: NO
																							 isPaired: YES
																							 isUnique: YES
																 ],
																 [[ArgumentObject alloc] initWithName: @"-p"
																						   identifier: ArgumentPartitionScheme
																						   isRequired: NO
																							 isPaired: YES
																							 isUnique: YES
																 ],
																 [[ArgumentObject alloc] initWithName: @"--no-erase"
																						   identifier: ArgumentDoNotErase
																						   isRequired: NO
																							 isPaired: NO
																							 isUnique: YES
																 ],
																 [[ArgumentObject alloc] initWithName: @"--skip-errors"
																						   identifier: ArgumentSkipErrors
																						   isRequired: NO
																							 isPaired: NO
																							 isUnique: YES
																 ]
															   ]
		];
		
		__block NSString *mountedImageDirectory = NULL;
		__block NSString *_destination = NULL;
		__block DiskManager *destinationDM = NULL;
		__block Filesystem filesystem = FilesystemFAT32;
		__block PartitionScheme partitionScheme = PartitionSchemeMBR;
		__block BOOL doNotErase = NO;
		__block BOOL skipErrors = NO;
		__block BOOL isBSDDevice = NO;
		
		NSError *argumentsHandlerError = NULL;
		/* BOOL argumentsHandlerResult = */
		[argumentsHandler loopThroughArgumentsWithErrorHandler: &argumentsHandlerError
										   prohibitUnknownKeys: YES
													  callback: ^void(ArgumentObject * _Nonnull argumentObject, NSString * _Nullable pair) {
			switch (argumentObject.identifier) {
				case ArgumentSourceDirectory: {
					NSError *error = NULL;
					mountedImageDirectory = [HelperFunctions getWindowsSourceMountPath:pair error:&error];
					
					if (error) {
						IOLog(@"[ERROR (Can't get Image Source)]: '%@'", error.stringValue);
						exit(EXIT_FAILURE);
					}
					break;
				}
				case ArgumentDestinationDevice: {
					NSError *error = NULL;
					DiskManager *diskManager = [HelperFunctions getDiskManagerWithDevicePath: pair
																				 isBSDDevice: &isBSDDevice
																					   error: &error];
					
					if (error) {
						IOLog(@"[ERROR (Can't get Destination Device)]: '%@'", error.stringValue);
						exit(EXIT_FAILURE);
					}
					
					_destination = pair;
					destinationDM = diskManager;
					break;
				}
				case ArgumentFilesystem: {
					NSString *uppercasePair = [pair uppercaseString];
					
					if ([uppercasePair isEqualToString:FilesystemFAT32]) {
						filesystem = FilesystemFAT32;
					} else if ([uppercasePair isEqualToString:FilesystemExFAT]) {
						filesystem = FilesystemExFAT;
					} else {
						IOLog(@"[ERROR (Passed an unrecognized filesystem personality)]: '%@'", pair);
						exit(EXIT_FAILURE);
					}
					
					break;
				}
				case ArgumentPartitionScheme: {
					NSString *uppercasePair = [pair uppercaseString];
					
					if ([uppercasePair isEqualToString:@"MBR"]) {
						partitionScheme = PartitionSchemeMBR;
					} else if ([uppercasePair isEqualToString:@"GPT"]) {
						partitionScheme = PartitionSchemeGPT;
					} else {
						IOLog(@"[ERROR (Passed an unrecognized partition scheme)]: '%@'", pair);
						exit(EXIT_FAILURE);
					}
					
					break;
				}
				case ArgumentDoNotErase:
					doNotErase = YES;
					break;
				case ArgumentSkipErrors:
					skipErrors = YES;
					break;
				default:
					break;
			}
			
			IOLog(@"[Key: %@] [Pair: %@]",
				  argumentObject.name,
				  (pair != NULL ? pair : @"")
				  );
			
		}];
		
		/*
		 IOLog(@"Handler result: %@",
		 (argumentsHandlerResult ? @"Success" : @"Failure"));
		 */
		
		if (argumentsHandlerError) {
			IOLog(@"[ERROR:] %@", argumentsHandlerError.stringValue);
			exit(EXIT_FAILURE);
		}
		
		/* Prepairing to write an Image to the Destination Device */
		
		/* Erasing the Disk if required */
		struct DiskInfo destinationDiskInfo = [destinationDM diskInfo];
		NSString *targetPartitionPath = _destination;
		
		if (!doNotErase) {
			NSString *newPartitionName = [HelperFunctions randomStringWithLength:11];
			targetPartitionPath = [@"/Volumes/" stringByAppendingPathComponent: newPartitionName];
			
			NSError *eraseError = NULL;
			
			BOOL eraseWasSuccessful = NO;
			if (destinationDiskInfo.isWholeDrive) {
				eraseWasSuccessful = [destinationDM diskUtilEraseDiskWithPartitionScheme: partitionScheme
																			  filesystem: filesystem
																				 newName: newPartitionName
																				   error: &eraseError];
				
			} else {
				eraseWasSuccessful = [destinationDM diskUtilEraseVolumeWithFilesystem: filesystem
																			  newName: newPartitionName
																				error: &eraseError];
			}
			
			IOLog(@"Erase Status: %@", (eraseWasSuccessful ? @"Success" : @"Failure"));
			if (eraseError != NULL) {
				IOLog(@"[ERROR:] %@", argumentsHandlerError.stringValue);
				exit(EXIT_FAILURE);
			}
		} else {
			if (isBSDDevice) {
				IOLog(@"You cannot use '--no-erase' argument with BSD Disk Path specified.");
				exit(EXIT_FAILURE);
			}
		}
		
		DWFilesContainer *filesContainer = [DWFilesContainer containerFromContainerPath: mountedImageDirectory
																			   callback: ^enum DWAction(DWFile * _Nonnull fileInfo, enum DWFilesContainerMessage message) {
			
			switch(message) {
				case DWFilesContainerMessageGetAttributesProcess:
					IOLog(@"[Getting file Attributes]: [%@]", fileInfo.sourcePath);
					break;
				case DWFilesContainerMessageGetAttributesSuccess:
					IOLog(@"[Got file Attributes]: [%@] {File Size: %@}", fileInfo.sourcePath, fileInfo.unitFormattedSize);
					break;
				case DWFilesContainerMessageGetAttributesFailure:
					IOLog(@"[Can't get file Attributes]: [%@]", fileInfo.sourcePath);
					break;
			}
			
			return DWActionContinue;
		}];
		
		DiskWriter *diskWriter = [[DiskWriter alloc] initWithDWFilesContainer: filesContainer
															  destinationPath: targetPartitionPath
																	 bootMode: BootModeUEFI
														destinationFilesystem: filesystem
														   skipSecurityChecks: YES];
		
		NSError *writeError = NULL;
		
		BOOL writeSuccessfuk = [diskWriter startWritingWithError: &writeError
														callback: ^DWAction(uint64 originalFileSizeBytes, uint64 copiedBytes, DWMessage dwMessage) {
			switch (dwMessage) {
				case DWMessageCreateDirectoryProcess:
					IOLog(@"[Creating Directory]: [%@]", destinationCurrentFilePath);
					break;
				case DWMessageCreateDirectorySuccess:
					IOLog(@"[Directory successfully created]: [%@]", destinationCurrentFilePath);
					break;
				case DWMessageCreateDirectoryFailure:
					IOLog(@"[Can't create Directory]: [%@]", destinationCurrentFilePath);
					if (!skipErrors) { return DWActionStop; }
					break;
				case DWMessageSplitWindowsImageProcess:
					IOLog(@"[Splitting Windows Image]: [%@ (.swm)] {File Size: >%@}", destinationCurrentFilePath, fileInfo.unitFormattedSize);
					break;
				case DWMessageSplitWindowsImageSuccess:
					IOLog(@"[Windows Image successfully splitted]: [%@ (.swm)] {File Size: >%@}", destinationCurrentFilePath, fileInfo.unitFormattedSize);
					break;
				case DWMessageSplitWindowsImageFailure:
					IOLog(@"[Can't split Windows Image]: [%@ (.swm)] {File Size: >%@}", destinationCurrentFilePath, fileInfo.unitFormattedSize);
					if (!skipErrors) { return DWActionStop; }
					break;
				case DWMessageExtractWindowsBootloaderProcess:
					IOLog(@"[Extracting Windows Bootloader from the Install file]: [%@]", destinationCurrentFilePath);
					break;
				case DWMessageExtractWindowsBootloaderSuccess:
					IOLog(@"[Windows Bootloader successfully extracted from the Install file]: [%@]", destinationCurrentFilePath);
					break;
				case DWMessageExtractWindowsBootloaderFailure:
					IOLog(@"[Can't extract Windows Bootloader from the Install file]: [%@]", destinationCurrentFilePath);
					if (!skipErrors) { return DWActionStop; }
					break;
				case DWMessageBypassWindowsSecurityChecksProcess:
					
					break;
				case DWMessageBypassWindowsSecurityChecksSuccess:
					
					break;
				case DWMessageBypassWindowsSecurityChecksFailure:
					
					break;
				case DWMessageWriteFileProcess:
					IOLog(@"[Writing File]: [%@ → %@] {File Size: %@}", fileInfo.sourcePath, destinationCurrentFilePath, fileInfo.unitFormattedSize);
					break;
				case DWMessageWriteFileSuccess:
					IOLog(@"[File was successfully written]: [%@ → %@] {File Size: %@}", fileInfo.sourcePath, destinationCurrentFilePath, fileInfo.unitFormattedSize);
					break;
				case DWMessageWriteFileFailure:
					IOLog(@"[Can't write File]: [%@ → %@] {File Size: %@}", fileInfo.sourcePath, destinationCurrentFilePath, fileInfo.unitFormattedSize);
					if (!skipErrors) { return DWActionStop; }
					break;
				case DWMessageFileIsTooLarge:
					IOLog(@"[File is too large]: [%@] {File Size: %@}", fileInfo.sourcePath, fileInfo.unitFormattedSize);
					if (!skipErrors) { return DWActionStop; }
					break;
				case DWMessageUnsupportedOperation:
					IOLog(@"[Unsupported operation with this type of File]: [%@ → %@] {File Size: %@}", fileInfo.sourcePath, destinationCurrentFilePath, fileInfo.unitFormattedSize);
					if (!skipErrors) { return DWActionStop; }
					break;
				case DWMessageEntityAlreadyExists:
					IOLog(@"[File already exists]: [%@] {File Size: %@}", destinationCurrentFilePath, fileInfo.unitFormattedSize);
					break;
			}
			
			return DWActionContinue;
		}];
		
	
		IOLog(@"");
		IOLog(@"[Result]: %@", (writeSuccessful ? @"Success" : @"Failure"));
		
		if (writeError) {
			IOLog(@"[ERROR]: %@", writeError.stringValue);
		}
	}
	return EXIT_SUCCESS;
}

void printUsage(void) {
	NSArray *applicationArguments = NSProcessInfo.processInfo.arguments;
	
	/* Checking the possibility of obtaining the path to Executable */
	printf("[Usage Example:] sudo ");
	if (applicationArguments.count == 0) {
		printf("\"path to the executable\"");
	} else {
		printf("\"%s\"", [[applicationArguments firstObject] UTF8String]);
	}
	
	printf(" -s \"Windows-Image.iso\" -d \"/dev/disk*\"\n\n");
	
	printf("[Available Arguments:]\n");
	printf("-s [Source]\n"
		   "      ISO Image File Path:\n"
		   "            Windows-Image-Path.iso\n"
		   "      Mounted ISO Path:\n"
		   "            /Volumes/Mounted-Windows-ISO/\n"
		   "-d [Destination]\n"
		   "      BSD Whole Disk:\n"
		   "            /dev/diskX       { 'X' — disk number }\n"
		   "      BSD Partition:\n"
		   "            /dev/diskXsY     { 'X' — disk number; Y — partition number }\n"
		   "      Volume Path:\n"
		   "            /Volumes/XXXXXX  { 'XXXXXX' — partition name }\n"
		   "-f [Filesystem]\n"
		   "      FAT32                  { Default }\n"
		   "      ExFAT                  { May require an external ExFatDxe.efi EFI driver }\n"
		   "--no-erase                   { Do not erase the target Device }\n"
		   "--skip-errors                { Do not stop the writing process on errors }\n"
		   );
}
