#ifndef _WIMLIB_TEST_SUPPORT_H
#define _WIMLIB_TEST_SUPPORT_H

#ifdef ENABLE_TEST_SUPPORT

#include "types.h"

#define WIMLIB_ERR_IMAGES_ARE_DIFFERENT			200

#define WIMLIB_ADD_FLAG_GENERATE_TEST_DATA		0x08000000

#define WIMLIB_CMP_FLAG_UNIX_MODE	0x00000001
#define WIMLIB_CMP_FLAG_NTFS_3G_MODE	0x00000002
#define WIMLIB_CMP_FLAG_WINDOWS_MODE	0x00000004

extern int
wimlib_compare_images(WIMStruct *wim1, int image1,
		      WIMStruct *wim2, int image2, int cmp_flags);

#endif /* ENABLE_TEST_SUPPORT */

#endif /* _WIMLIB_TEST_SUPPORT_H */
