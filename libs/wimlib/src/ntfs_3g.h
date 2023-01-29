#ifndef _WIMLIB_NTFS_3G_H
#define _WIMLIB_NTFS_3G_H

#ifdef WITH_NTFS_3G

#include "types.h"

struct blob_descriptor;
struct consume_chunk_callback;
struct ntfs_location;

extern int
read_ntfs_attribute_prefix(const struct blob_descriptor *blob, u64 size,
			   const struct consume_chunk_callback *cb,
			   bool recover_data);

extern struct ntfs_location *
clone_ntfs_location(const struct ntfs_location *loc);

extern void
free_ntfs_location(struct ntfs_location *loc);

extern int
cmp_ntfs_locations(const struct ntfs_location *loc1,
		   const struct ntfs_location *loc2);

#endif /* WITH_NTFS_3G */

#endif /* _WIMLIB_NTFS_3G_H */
