//
//  ExecuteWithPrivileges.c
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

#include "ExecuteWithPrivileges.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

OSStatus ExecuteWithPrivileges(AuthorizationRef authorization, const char *pathToTool, char * const *arguments) {
    return AuthorizationExecuteWithPrivileges(
        authorization,
        pathToTool,
        kAuthorizationFlagDefaults,
        arguments,
        NULL
    );
}

#pragma clang diagnostic pop
