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
};

int main(int argc, const char *argv[]) {
	@autoreleasepool {
		/*
		NSError *writeError = NULL;
		BOOL result = [DiskWriter writeWindows11ISOWithSourcePath: @"/Volumes/CCCOMA_X64FRE_RU-RU_DV9"
												  destinationPath: @"/Volumes/D0R1K"
							   bypassTPMAndSecureBootRequirements: NO
														 bootMode: BootModeLegacy
														  isFAT32: YES
															error: &writeError
											   progressController: ^BOOL(struct FileWriteInfo fileWriteInfo, enum DWMessage message) {
			switch (message) {
				case DWMessageGetFileAttributesProcess:
					IOLog(@"Getting file Attributes: [%@]", fileWriteInfo.sourceFilePath);
					break;
				case DWMessageGetFileAttributesSuccess:
					IOLog(@"Got file Attributes: [%@]", fileWriteInfo.sourceFilePath);
					break;
				case DWMessageGetFileAttributesFailure:
					IOLog(@"Can't get file Attributes: [%@]", fileWriteInfo.sourceFilePath);
					break;
				case DWMessageCreateDirectoryProcess:
					IOLog(@"Creating Directory: [%@]", fileWriteInfo.destinationFilePath);
					break;
				case DWMessageCreateDirectorySuccess:
					IOLog(@"Directory successfully created: [%@]", fileWriteInfo.destinationFilePath);
					break;
				case DWMessageCreateDirectoryFailure:
					IOLog(@"Can't create Directory: [%@]", fileWriteInfo.destinationFilePath);
					break;
				case DWMessageSplitWindowsImageProcess:
					IOLog(@"Splitting Windows Image: [%@]", fileWriteInfo.sourceFilePath);
					break;
				case DWMessageSplitWindowsImageSuccess:
					IOLog(@"Windows Image successfully splitted: [%@]", fileWriteInfo.sourceFilePath);
					break;
				case DWMessageSplitWindowsImageFailure:
					IOLog(@"Can't split Windows Image: [%@]", fileWriteInfo.sourceFilePath);
					break;
				case DWMessageWriteFileProcess:
					IOLog(@"Writing File: [%@ → %@]", fileWriteInfo.sourceFilePath, fileWriteInfo.destinationFilePath);
					break;
				case DWMessageWriteFileSuccess:
					IOLog(@"File was successfully written: [%@ → %@]", fileWriteInfo.sourceFilePath, fileWriteInfo.destinationFilePath);
					break;
				case DWMessageWriteFileFailure:
					IOLog(@"Can't write File: [%@ → %@]", fileWriteInfo.sourceFilePath, fileWriteInfo.destinationFilePath);
					break;
				case DWMessageFileIsTooLarge:
					IOLog(@"File is too large: [%@]", fileWriteInfo.sourceFilePath);
					break;
				case DWMessageUnsupportedOperation:
					IOLog(@"Unsupported operation with this type of File: [%@ → %@]", fileWriteInfo.sourceFilePath, fileWriteInfo.destinationFilePath);
					break;
				case DWMessageEntityAlreadyExists:
					IOLog(@"File already exists: [%@]", fileWriteInfo.destinationFilePath);
					break;
			}
			
			return YES;
		}];
		
		if (writeError != NULL) {
			IOLog(@"An error has occurred while writing the image: [%@]", [writeError userInfo]);
		}
		*/
		
		NSArray *applicationArguments = NSProcessInfo.processInfo.arguments;
		
		ArgumentsHandler *argumentsHandler = [[ArgumentsHandler alloc]
											  initWithProcessArguments: applicationArguments
											  argumentObjects: @[[[ArgumentObject alloc] initWithName: @"-s"
																							 uniqueID: ArgumentSourceDirectory
																						   isRequired: YES
																							 isPaired: YES],
																 [[ArgumentObject alloc] initWithName: @"-d"
																							 uniqueID: ArgumentDestinationDevice
																						   isRequired: YES
																							 isPaired: YES
																 ],
																 [[ArgumentObject alloc] initWithName: @"-f"
																							 uniqueID: ArgumentFilesystem
																						   isRequired: NO
																							 isPaired: YES
																 ],
																 [[ArgumentObject alloc] initWithName: @"-p"
																							 uniqueID: ArgumentPartitionScheme
																						   isRequired: NO
																							 isPaired: YES
																 ],
																 [[ArgumentObject alloc] initWithName: @"--noerase"
																							 uniqueID: ArgumentDoNotErase
																						   isRequired: NO
																							 isPaired: NO
																 ]
															   ]
		];
		
		__block NSString *imageSource = NULL;
		__block NSString *destinationPath = NULL;
		__block DiskManager *destinationDM = NULL;
		__block Filesystem filesystem = FilesystemFAT32;
		__block PartitionScheme partitionScheme = PartitionSchemeMBR;
		__block BOOL doNotErase = NO;
		
		NSError *argumentsHandlerError = NULL;
		BOOL argumentsHandlerResult = [argumentsHandler loopThroughArgumentsWithErrorHandler: &argumentsHandlerError
																					callback: ^void(ArgumentObject * _Nonnull argumentObject, NSString * _Nullable pair) {
			switch (argumentObject.uniqueID) {
				case ArgumentSourceDirectory: {
					NSError *error = NULL;
					imageSource = [HelperFunctions getWindowsSourceMountPath:pair error:&error];
					
					if (error != NULL) {
						IOLog(@"[ERROR (Can't get Image Source)]: '%@'", [[error userInfo] objectForKey:DEFAULT_ERROR_KEY]);
						exit(EXIT_FAILURE);
					}
					break;
				}
				case ArgumentDestinationDevice: {
					NSError *error = NULL;
					DiskManager *diskManager = [HelperFunctions getDiskManagerWithDevicePath:pair error:&error];
					
					if (error != NULL) {
						IOLog(@"[ERROR (Can't get Destination Device)]: '%@'", [[error userInfo] objectForKey:DEFAULT_ERROR_KEY]);
						exit(EXIT_FAILURE);
					}

					destinationPath = pair;
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
				default:
					break;
			}
			
			IOLog(@"[Tag: %@] [Pair: %@]",
				  argumentObject.name,
				  (pair != NULL ? pair : @"")
				  );

		}];
		
		IOLog(@"Handler result: %@",
			  (argumentsHandlerResult ? @"Success" : @"Failure"));
		
		if (argumentsHandlerError != NULL) {
			IOLog(@"[ERROR:] %@", [[argumentsHandlerError userInfo] objectForKey:DEFAULT_ERROR_KEY]);
		}
	
		struct DiskInfo destinationDiskInfo = [destinationDM getDiskInfo];
		if (!doNotErase) {
			NSString *newPartitionName = [HelperFunctions randomStringWithLength:11];
			NSError *eraseError = NULL;
			
			BOOL eraseWasSuccessful = NO;
			if (destinationDiskInfo.isWholeDrive) {
				eraseWasSuccessful = [destinationDM diskUtilEraseDiskWithPartitionScheme:partitionScheme
														 filesystem:filesystem
															newName:newPartitionName
															  error:&eraseError];
			} else {
				eraseWasSuccessful = [destinationDM diskUtilEraseVolumeWithFilesystem:filesystem
														 newName:newPartitionName
																				error:&eraseError];
			}
			
			IOLog(@"Erasing was: %@", (eraseWasSuccessful ? @"+" : @"-"));
			
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
		   );
}
