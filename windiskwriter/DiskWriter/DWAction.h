//
//  DWAction.h
//  windiskwriter
//
//  Created by Macintosh on 22.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

/*
 switch (callback(currentFile, DWMessageCreateDirectoryProcess)) {
     case DWActionSkip:
         continue;
     case DWActionStop:
         return NO;
     default:
         goto quitLoop;
 }
 */

#define DWCallbackHandler(callback, currentFile, message)  \
    switch (callback(currentFile, message)) {              \
        case DWActionSkip:                                 \
            continue;                                      \
        case DWActionStop:                                 \
            return NO;                                     \
        default:                                           \
            goto quitLoop;                                 \
    }                                                      \

enum DWAction {
    DWActionContinue,
    DWActionSkip,
    DWActionStop
};
