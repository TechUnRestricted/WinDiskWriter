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
#import "CommandLine.h"
#import "DiskManager.h"
#import "DiskWriter.h"
#import "HDIUtil.h"

void printUsage(void);

int main(int argc, const char *argv[]) {
	@autoreleasepool {
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
		
		NSArray *availableArguments = @[
			@"-s", // Source
			@"-d", // Destination
			@"-f"  // Filesystem
		];

		NSArray *applicationArguments = NSProcessInfo.processInfo.arguments;
		for (int currentIndex = 0; currentIndex < [applicationArguments count]; currentIndex++) {
			NSString *currentArgument = [applicationArguments objectAtIndex:currentIndex];

			if ([currentArgument isEqualToString:@"-s"]) {
				
			} else if ([currentArgument isEqualToString:@"-d"]) {
				
			} else if ([currentArgument isEqualToString:@"-f"]) {
				
			}
		}
		
		printUsage();
	}
	return 0;
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
