//
//  DWAction.h
//  windiskwriter
//
//  Created by Macintosh on 22.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#define DWCallbackLoopHandler(callback, currentFile, message)  \
    switch (callback(currentFile, message)) {                  \
        case DWActionSkip:                                     \
            continue;                                          \
        case DWActionContinue:                                 \
            break;                                             \
        default:                                               \
            return NULL;                                       \
    }                                                          \

#define DWCallbackHandler(callback, currentFile, message)      \
    switch (callback(currentFile, message)) {                  \
        case DWActionContinue:                                 \
            break;                                             \
        case DWActionSkip:                                     \
        case DWActionStop:                                     \
        default:                                               \
            return NULL;                                       \
    }

enum DWAction {
    DWActionContinue,
    DWActionSkip,
    DWActionStop
};
