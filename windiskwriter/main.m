//
//  main.m
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <unistd.h>

#import "DebugSystem.h"
#import "newfs_msdos.h"
#import "DiskWriter.h"
#import "CommandLine.h"
#import "HDIUtil.h"

/// Checking if the application is running as Root
bool hasElevatedRights(void);
void printUsage(void);

int main(int argc, const char *argv[]) {
	@autoreleasepool {
		if (!hasElevatedRights()) {
			printf("This program is not running as Root.\n");
			printUsage();
			exit(EXIT_FAILURE);
		}
		printUsage();
		DiskWriter *diskWriter = [[DiskWriter alloc] initWithWindowsISO:@"/Users/macintosh/Windows x64.iso" destinationDevice:@"/dev/disk9s9"];
		DebugLog(@"Mounted Windows ISO: %@", [diskWriter getMountedWindowsISO]);
		DebugLog(@"Destination Device: %@", [diskWriter getDestinationDevice]);
	}
	return 0;
}

bool hasElevatedRights(void) {
	return getuid() == 0;
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
		   "--filesystem\n"
		   "      FAT32                  { Default }\n"
		   "      ExFAT                  { May require an external ExFatDxe.efi EFI driver }\n"
		   "--no-erase                   { Do not erase the target Device }\n"
		   );
}
