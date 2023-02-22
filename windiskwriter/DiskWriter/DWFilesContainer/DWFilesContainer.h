//
//  DWFilesContainer.h
//  windiskwriter
//
//  Created by Macintosh on 21.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWAction.h"
#import "DWFile.h"

enum DWFilesContainerMessage {
    DWFilesContainerMessageGetAttributesProcess,
    DWFilesContainerMessageGetAttributesSuccess,
    DWFilesContainerMessageGetAttributesFailure
};

typedef enum DWAction (^DWFilesContainerCallback)(DWFile *_Nonnull fileInfo, enum DWFilesContainerMessage message);

@interface DWFilesContainer : NSObject

@property (readonly, strong, atomic) NSArray<DWFile *>*_Nonnull files;
@property (readonly, strong, nonatomic) NSString *_Nonnull containerPath;

- (instancetype _Nonnull)init NS_UNAVAILABLE;

+ (DWFilesContainer *_Nullable)containerFromContainerPath: (NSString *_Nonnull)containerPath
                                                 callback: (DWFilesContainerCallback _Nonnull)callback;

- (UInt64)sizeOfFiles;

@end
