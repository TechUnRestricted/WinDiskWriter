#ifndef _WIMLIB_GLOB_H
#define _WIMLIB_GLOB_H

#ifndef __WIN32__
#  include <glob.h>
#else
#include <stddef.h>
#include <wchar.h>

typedef struct {
	size_t    gl_pathc;
	wchar_t **gl_pathv;
	size_t    gl_offs;
} glob_t;

/* WARNING: this is a reduced functionality replacement */
extern int
win32_wglob(const wchar_t *pattern, int flags,
	    int (*errfunc)(const wchar_t *epath, int eerrno),
	    glob_t *pglob);

extern void globfree(glob_t *pglob);

#define	GLOB_ERR	0x1 /* Return on read errors.  */
#define	GLOB_NOSORT	0x2 /* Don't sort the names.  */

/* Error returns from `glob'.  */
#define	GLOB_NOSPACE	1	/* Ran out of memory.  */
#define	GLOB_ABORTED	2	/* Read error.  */
#define	GLOB_NOMATCH	3	/* No matches found.  */

#endif /* __WIN32__ */

#endif /* _WIMLIB_GLOB_H */
