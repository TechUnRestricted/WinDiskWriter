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
		__block BOOL isBSDDevice = NO;
		
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
					DiskManager *diskManager = [HelperFunctions getDiskManagerWithDevicePath: pair
																				 isBSDDevice: &isBSDDevice
																					   error: &error];
					
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
		
		/* Prepairing to write an Image to the Destination Device */
		
		/* Erasing the Disk if required */
		struct DiskInfo destinationDiskInfo = [destinationDM getDiskInfo];
		NSString *targetPartitionPath = destinationPath;
		
		if (!doNotErase) {
			NSString *newPartitionName = [HelperFunctions randomStringWithLength:11];
			targetPartitionPath = [@"/Volumes/" stringByAppendingPathComponent: newPartitionName];
			
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
			
			IOLog(@"Erase Status: %@", (eraseWasSuccessful ? @"Success" : @"Failure"));
			if (eraseError != NULL) {
				IOLog(@"[ERROR:] %@", [[argumentsHandlerError userInfo] objectForKey:DEFAULT_ERROR_KEY]);
				exit(EXIT_FAILURE);
			}
		} else {
			if (isBSDDevice) {
				IOLog(@"You cannot use '--noerase' argument with BSD Disk Path specified.");
				exit(EXIT_FAILURE);
			}
		}
		
		DWFilesContainer *filesContainer = [DWFilesContainer containerFromContainerPath: imageSource
																			   callback:^enum DWAction(DWFile * _Nonnull fileInfo, enum DWFilesContainerMessage message) {
			
			switch(message) {
				case DWFilesContainerMessageGetAttributesProcess:
					IOLog(@"[Getting file Attributes]: [%@]", [fileInfo sourcePath]);
					break;
				case DWFilesContainerMessageGetAttributesSuccess:
					IOLog(@"[Got file Attributes]: [%@]", [fileInfo sourcePath]);
					break;
				case DWFilesContainerMessageGetAttributesFailure:
					IOLog(@"[Can't get file Attributes]: [%@]", [fileInfo sourcePath]);
					break;
			}
			
			return DWActionContinue;
		}];
		
		DiskWriter *diskWriter = [[DiskWriter alloc] initWithDWFilesContainer: filesContainer
															  destinationPath: destinationPath
																	 bootMode: BootModeUEFI
														destinationFilesystem: FilesystemFAT32];
		
		NSError *writeError = NULL;
		[diskWriter writeWindows_8_10_ISOWithError: &writeError
										  callback:^enum DWAction(DWFile * _Nonnull fileInfo, enum DWMessage message) {
			switch (message) {
				
			}
			
			return DWActionContinue;
		}];
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
