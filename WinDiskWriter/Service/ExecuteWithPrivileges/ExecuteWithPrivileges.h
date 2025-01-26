//
//  ExecuteWithPrivileges.h
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

#ifndef ExecuteWithPrivileges_h
#define ExecuteWithPrivileges_h

#include <Security/Security.h>

OSStatus ExecuteWithPrivileges(AuthorizationRef authorization, const char *pathToTool, char * const *arguments);

#endif /* ExecuteWithPrivileges_h */
