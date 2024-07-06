/*
 * mount_image.c
 *
 * This file implements mounting of WIM images using FUSE
 * (Filesystem in Userspace).  See https://github.com/libfuse/libfuse
 *
 * Currently it is only expected to work on Linux.
 */

/*
 * Copyright 2012-2023 Eric Biggers
 *
 * This file is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 3 of the License, or (at your option) any
 * later version.
 *
 * This file is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this file; if not, see https://www.gnu.org/licenses/.
 */

#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif

#include "wimlib.h"
#include "wimlib/error.h"

#ifdef WITH_FUSE

#ifdef _WIN32
#  error "FUSE mount not supported on Windows!  Please configure --without-fuse"
#endif

#define FUSE_USE_VERSION 30

#include <sys/types.h> /* sometimes required before <sys/xattr.h> */
#include <sys/xattr.h>
#include <dirent.h>
#include <errno.h>
#include <fuse.h>
#include <limits.h>
#include <mqueue.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <unistd.h>
#include <utime.h>

#include "wimlib/blob_table.h"
#include "wimlib/dentry.h"
#include "wimlib/encoding.h"
#include "wimlib/metadata.h"
#include "wimlib/paths.h"
#include "wimlib/progress.h"
#include "wimlib/reparse.h"
#include "wimlib/threads.h"
#include "wimlib/timestamp.h"
#include "wimlib/unix_data.h"
#include "wimlib/write.h"
#include "wimlib/xml.h"

#ifndef O_NOFOLLOW
#  define O_NOFOLLOW 0  /* Security only...  */
#endif

#ifndef ENOATTR
#  define ENOATTR ENODATA
#endif

#define WIMFS_MQUEUE_NAME_LEN 32

#define WIMLIB_UNMOUNT_FLAG_SEND_PROGRESS 0x80000000

struct wimfs_unmount_info {
	unsigned unmount_flags;
	char mq_name[WIMFS_MQUEUE_NAME_LEN + 1];
};

struct commit_progress_report {
	enum wimlib_progress_msg msg;
	union wimlib_progress_info info;
};

/* Description of an open file on a mounted WIM image.  Actually, this
 * represents the open state of a particular data stream of an inode, rather
 * than the inode itself.  (An inode might have multiple named data streams in
 * addition to the default, unnamed data stream.)  At a given time, an inode in
 * the WIM image might have multiple file descriptors open to it, each to any
 * one of its data streams.  */
struct wimfs_fd {

	/* Pointer to the inode of this open file.
	 * 'i_num_opened_fds' of the inode tracks the number of file descriptors
	 * that reference it.  */
	struct wim_inode *f_inode;

	/* Pointer to the blob descriptor for the data stream that has been
	 * opened.  'num_opened_fds' of the blob descriptor tracks the number of
	 * file descriptors that reference it.  Or, this value may be NULL,
	 * which indicates that the opened stream is empty and consequently does
	 * not have a blob descriptor.  */
	struct blob_descriptor *f_blob;

	/* If valid (filedes_valid(&f_staging_fd)), this contains the
	 * corresponding native file descriptor for the staging file that has
	 * been created for reading from and/or writing to this open stream.  A
	 * single staging file might have multiple file descriptors open to it
	 * simultaneously, each used by a different 'struct wimfs_fd'.
	 *
	 * Or, if invalid (!filedes_valid(&f_staging_fd)), this 'struct
	 * wimfs_fd' is not associated with a staging file.  This is permissible
	 * only if this 'struct wimfs_fd' was opened read-only and the stream
	 * has not yet been extracted to a staging file.  */
	struct filedes f_staging_fd;

	/* 0-based index of this file descriptor in the file descriptor table of
	 * its inode.  */
	u16 f_idx;

	/* Unique ID of the opened stream in the inode.  This will stay the same
	 * even if the indices of the inode's streams are changed by a deletion.
	 */
	u32 f_stream_id;
};

#define WIMFS_FD(fi) ((struct wimfs_fd *)(uintptr_t)((fi)->fh))

/* Context structure for a mounted WIM image.  */
struct wimfs_context {
	/* The WIMStruct containing the mounted image.  The mounted image is the
	 * currently selected image (wim->current_image).  */
	WIMStruct *wim;

	/* Flags passed to wimlib_mount_image() (WIMLIB_MOUNT_FLAG_*).  */
	int mount_flags;

	/* Default flags for path lookup in the WIM image.  */
	int default_lookup_flags;

	/* Information about the user who has mounted the WIM image  */
	uid_t owner_uid;
	gid_t owner_gid;

	/* Absolute path to the mountpoint directory (may be needed for absolute
	 * symbolic link fixups)  */
	char *mountpoint_abspath;
	size_t mountpoint_abspath_nchars;

	/* Information about the staging directory for a read-write mount.  */
	int parent_dir_fd;
	int staging_dir_fd;
	char *staging_dir_name;

	/* For read-write mounts, the inode number to be assigned to the next
	 * created file.  Note: since this isn't a persistent filesystem and we
	 * can re-assign the inode numbers just before mounting the image, it's
	 * good enough to just generate inode numbers sequentially.  */
	u64 next_ino;

	/* Number of file descriptors open to the mounted WIM image.  */
	unsigned long num_open_fds;

	/* For read-write mounts, the original metadata resource of the mounted
	 * image.  */
	struct blob_descriptor *metadata_resource;

	/* Parameters for unmounting the image (can be set via extended
	 * attribute "wimfs.unmount_info").  */
	struct wimfs_unmount_info unmount_info;
};

#define WIMFS_CTX(fuse_ctx) ((struct wimfs_context*)(fuse_ctx)->private_data)

/* Retrieve the context structure for the currently mounted WIM image.
 *
 * Note: this is a per-thread variable.  It is possible for different threads to
 * mount different images at the same time in the same process, although they
 * must use different WIMStructs!  */
static inline struct wimfs_context *
wimfs_get_context(void)
{
	return WIMFS_CTX(fuse_get_context());
}

static void
wimfs_inc_num_open_fds(void)
{
	wimfs_get_context()->num_open_fds++;
}

static void
wimfs_dec_num_open_fds(void)
{
	wimfs_get_context()->num_open_fds--;
}

/* Retrieve the WIMStruct for the currently mounted WIM image.  */
static inline WIMStruct *
wimfs_get_WIMStruct(void)
{
	return wimfs_get_context()->wim;
}

/* Is write permission requested on the file?  */
static inline bool
flags_writable(int open_flags)
{
	int accmode = (open_flags & O_ACCMODE);
	return (accmode == O_RDWR || accmode == O_WRONLY);
}

static mode_t
fuse_mask_mode(mode_t mode, const struct fuse_context *fuse_ctx)
{
	return mode & ~fuse_ctx->umask;
}

/*
 * Allocate a file descriptor to a data stream in the mounted WIM image.
 *
 * @inode
 *	The inode containing the stream being opened
 * @strm
 *	The stream of the inode being opened
 * @fd_ret
 *	On success, a pointer to the new file descriptor will be stored here.
 *
 * Returns 0 or a -errno code.
 */
static int
alloc_wimfs_fd(struct wim_inode *inode,
	       struct wim_inode_stream *strm,
	       struct wimfs_fd **fd_ret)
{
	static const u16 min_fds_per_alloc = 8;
	static const u16 max_fds = 0xffff;
	u16 i;
	struct wimfs_fd *fd;

	if (inode->i_num_opened_fds == inode->i_num_allocated_fds) {
		u16 num_new_fds;
		struct wimfs_fd **fds;

		/* Expand this inode's file descriptor table.  */

		num_new_fds = max(min_fds_per_alloc,
				  inode->i_num_allocated_fds / 4);

		num_new_fds = min(num_new_fds,
				  max_fds - inode->i_num_allocated_fds);

		if (num_new_fds == 0)
			return -EMFILE;

		fds = REALLOC(inode->i_fds,
			      (inode->i_num_allocated_fds + num_new_fds) *
			        sizeof(fds[0]));
		if (!fds)
			return -ENOMEM;

		memset(&fds[inode->i_num_allocated_fds], 0,
		       num_new_fds * sizeof(fds[0]));
		inode->i_fds = fds;
		inode->i_num_allocated_fds += num_new_fds;
		inode->i_next_fd = inode->i_num_opened_fds;
	}

	/* Allocate the file descriptor in the first available space in the
	 * inode's file descriptor table.
	 *
	 * i_next_fd is the lower bound on the next open slot.  */
	for (i = inode->i_next_fd; inode->i_fds[i]; i++)
		;

	fd = MALLOC(sizeof(*fd));
	if (!fd)
		return -ENOMEM;

	fd->f_inode     = inode;
	fd->f_blob      = stream_blob_resolved(strm);
	filedes_invalidate(&fd->f_staging_fd);
	fd->f_idx       = i;
	fd->f_stream_id	= strm->stream_id;
	*fd_ret         = fd;
	inode->i_fds[i] = fd;
	inode->i_num_opened_fds++;
	if (fd->f_blob)
		fd->f_blob->num_opened_fds++;
	wimfs_inc_num_open_fds();
	inode->i_next_fd = i + 1;
	return 0;
}

/*
 * Close a file descriptor to a data stream in the mounted WIM image.
 *
 * Returns 0 or a -errno code.  The file descriptor is always closed.
 */
static int
close_wimfs_fd(struct wimfs_fd *fd)
{
	int ret = 0;
	struct wim_inode *inode;

	/* Close the staging file if open.  */
	if (filedes_valid(&fd->f_staging_fd))
		 if (filedes_close(&fd->f_staging_fd))
			 ret = -errno;

	/* Release this file descriptor from its blob descriptor.  */
	if (fd->f_blob)
		blob_decrement_num_opened_fds(fd->f_blob);

	wimfs_dec_num_open_fds();

	/* Release this file descriptor from its inode.  */
	inode = fd->f_inode;
	inode->i_fds[fd->f_idx] = NULL;
	if (fd->f_idx < inode->i_next_fd)
		inode->i_next_fd = fd->f_idx;
	FREE(fd);
	inode_dec_num_opened_fds(inode);
	return ret;
}

/*
 * Translate a path into the corresponding inode in the mounted WIM image.
 *
 * See get_dentry() for more information.
 *
 * Returns a pointer to the resulting inode, or NULL with errno set.
 */
static struct wim_inode *
wim_pathname_to_inode(WIMStruct *wim, const char *path)
{
	struct wim_dentry *dentry;

	dentry = get_dentry(wim, path, WIMLIB_CASE_SENSITIVE);
	if (!dentry)
		return NULL;
	return dentry->d_inode;
}

/* Can look up named data stream with colon syntax  */
#define LOOKUP_FLAG_ADS_OK		0x01

/* Can look up directory (otherwise get -ENOTDIR)  */
#define LOOKUP_FLAG_DIRECTORY_OK	0x02

/* Get the data stream of the specified name from the specified inode.  Returns
 * NULL with errno set if not found.  */
static struct wim_inode_stream *
inode_get_data_stream_tstr(const struct wim_inode *inode,
			   const char *stream_name)
{
	struct wim_inode_stream *strm;

	if (!stream_name || !*stream_name) {
		strm = inode_get_unnamed_data_stream(inode);
	} else {
		const utf16lechar *uname;

		if (tstr_get_utf16le(stream_name, &uname))
			return NULL;
		strm = inode_get_stream(inode, STREAM_TYPE_DATA, uname);
		tstr_put_utf16le(uname);
	}
	if (!strm)
		errno = ENOENT;
	return strm;
}

/*
 * Translate a path into the corresponding dentry and stream in the mounted WIM
 * image.
 *
 * Returns 0 or a -errno code.  @dentry_ret and @strm_ret are both optional.
 */
static int
wim_pathname_to_stream(const struct wimfs_context *ctx,
		       const char *path,
		       int lookup_flags,
		       struct wim_dentry **dentry_ret,
		       struct wim_inode_stream **strm_ret)
{
	WIMStruct *wim = ctx->wim;
	struct wim_dentry *dentry;
	struct wim_inode *inode;
	struct wim_inode_stream *strm;
	const char *stream_name = NULL;
	char *p = NULL;

	lookup_flags |= ctx->default_lookup_flags;

	if (lookup_flags & LOOKUP_FLAG_ADS_OK) {
		stream_name = path_stream_name(path);
		if (stream_name) {
			p = (char *)stream_name - 1;
			*p = '\0';
		}
	}

	dentry = get_dentry(wim, path, WIMLIB_CASE_SENSITIVE);
	if (p)
		*p = ':';
	if (!dentry)
		return -errno;

	inode = dentry->d_inode;

	if (inode_resolve_streams(inode, wim->blob_table, false))
		return -EIO;

	if (!(lookup_flags & LOOKUP_FLAG_DIRECTORY_OK)
	      && inode_is_directory(inode))
		return -EISDIR;

	strm = inode_get_data_stream_tstr(inode, stream_name);
	if (!strm) {
		/* Force creation of an unnamed data stream  */
		if (!stream_name)
			strm = inode_add_stream(inode, STREAM_TYPE_DATA,
						NO_STREAM_NAME, NULL);
		if (!strm)
			return -errno;
	}

	if (dentry_ret)
		*dentry_ret = dentry;
	if (strm_ret)
		*strm_ret = strm;
	return 0;
}

/*
 * Create a new file in the mounted WIM image.
 *
 * @fuse_ctx
 *	The FUSE context for the mounted image.
 * @path
 *	The path at which to create the first link to the new file.  If a file
 *	already exists at this path, -EEXIST is returned.
 * @mode
 *	The UNIX mode for the new file.  This is only fully honored if
 *	WIMLIB_MOUNT_FLAG_UNIX_DATA was passed to wimlib_mount_image().
 * @rdev
 *	The device ID for the new file, encoding the major and minor device
 *	numbers.  This is only honored if WIMLIB_MOUNT_FLAG_UNIX_DATA was passed
 *	to wimlib_mount_image().
 * @dentry_ret
 *	On success, a pointer to the new dentry is returned here.  Its d_inode
 *	member will point to the new inode that was created for it and added to
 *	the mounted WIM image.
 *
 * Returns 0 or a -errno code.
 */
static int
create_file(struct fuse_context *fuse_ctx, const char *path,
	    mode_t mode, dev_t rdev, struct wim_dentry **dentry_ret)
{
	struct wimfs_context *wimfs_ctx = WIMFS_CTX(fuse_ctx);
	struct wim_dentry *parent;
	const char *basename;
	struct wim_dentry *dentry;
	struct wim_inode *inode;

	parent = get_parent_dentry(wimfs_ctx->wim, path, WIMLIB_CASE_SENSITIVE);
	if (!parent)
		return -errno;

	if (!dentry_is_directory(parent))
		return -ENOTDIR;

	basename = path_basename(path);

	if (get_dentry_child_with_name(parent, basename, WIMLIB_CASE_SENSITIVE))
		return -EEXIST;

	if (new_dentry_with_new_inode(basename, true, &dentry))
		return -ENOMEM;

	inode = dentry->d_inode;

	inode->i_ino = wimfs_ctx->next_ino++;

	/* Note: we still use FILE_ATTRIBUTE_NORMAL for device nodes, named
	 * pipes, and sockets.  The real mode is in the UNIX metadata.  */
	if (S_ISDIR(mode))
		inode->i_attributes = FILE_ATTRIBUTE_DIRECTORY;
	else
		inode->i_attributes = FILE_ATTRIBUTE_NORMAL;

	if (wimfs_ctx->mount_flags & WIMLIB_MOUNT_FLAG_UNIX_DATA) {
		struct wimlib_unix_data unix_data;

		unix_data.uid = fuse_ctx->uid;
		unix_data.gid = fuse_ctx->gid;
		unix_data.mode = fuse_mask_mode(mode, fuse_ctx);
		unix_data.rdev = rdev;
		if (!inode_set_unix_data(inode, &unix_data, UNIX_DATA_ALL))
		{
			free_dentry(dentry);
			return -ENOMEM;
		}
	}

	hlist_add_head(&inode->i_hlist_node,
		       &wim_get_current_image_metadata(wimfs_ctx->wim)->inode_list);

	dentry_add_child(parent, dentry);

	*dentry_ret = dentry;
	return 0;
}

/*
 * Remove a dentry from the mounted WIM image; i.e. remove an alias for an
 * inode.
 */
static void
remove_dentry(struct wim_dentry *dentry, struct blob_table *blob_table)
{
	/* Drop blob references.  */
	inode_unref_blobs(dentry->d_inode, blob_table);

	/* Unlink the dentry from the image's dentry tree.  */
	unlink_dentry(dentry);

	/* Delete the dentry.  This will also decrement the link count of the
	 * corresponding inode, and possibly cause it to be deleted as well.  */
	free_dentry(dentry);
}

/* Generate UNIX filetype mode bits for the specified WIM inode, based on its
 * Windows file attributes.  */
static mode_t
inode_unix_file_type(const struct wim_inode *inode)
{
	if (inode_is_symlink(inode))
		return S_IFLNK;
	else if (inode_is_directory(inode))
		return S_IFDIR;
	else
		return S_IFREG;
}

/* Generate a default UNIX mode for the specified WIM inode.  */
static mode_t
inode_default_unix_mode(const struct wim_inode *inode)
{
	return inode_unix_file_type(inode) | 0777;
}

static u64
blob_size(const struct blob_descriptor *blob)
{
	if (!blob)
		return 0;
	return blob->size;
}

static u64
blob_stored_size(const struct blob_descriptor *blob)
{
	if (!blob)
		return 0;
	if (blob->blob_location == BLOB_IN_WIM &&
	    blob->size == blob->rdesc->uncompressed_size)
		return blob->rdesc->size_in_wim;
	return blob->size;
}

/*
 * Retrieve standard UNIX metadata ('struct stat') for a WIM inode.
 *
 * @blob is the blob descriptor for the stream of the inode that is being
 * queried, or NULL.  We mostly return the same information for all streams, but
 * st_size and st_blocks may be different for different streams.
 *
 * This always returns 0.
 */
static int
inode_to_stbuf(const struct wim_inode *inode,
	       const struct blob_descriptor *blob, struct stat *stbuf)
{
	const struct wimfs_context *ctx = wimfs_get_context();
	struct wimlib_unix_data unix_data;

	memset(stbuf, 0, sizeof(struct stat));
	if ((ctx->mount_flags & WIMLIB_MOUNT_FLAG_UNIX_DATA) &&
	    inode_get_unix_data(inode, &unix_data))
	{
		/* Use the user ID, group ID, mode, and device ID from the
		 * inode's extra UNIX metadata information.  */
		stbuf->st_uid = unix_data.uid;
		stbuf->st_gid = unix_data.gid;
		stbuf->st_mode = unix_data.mode;
		stbuf->st_rdev = unix_data.rdev;
	} else {
		/* Generate default values for the user ID, group ID, and mode.
		 *
		 * Note: in the case of an allow_other mount, fuse_context.uid
		 * may not be the same as wimfs_context.owner_uid!  */
		stbuf->st_uid = ctx->owner_uid;
		stbuf->st_gid = ctx->owner_gid;
		stbuf->st_mode = inode_default_unix_mode(inode);
	}
	stbuf->st_ino = inode->i_ino;
	stbuf->st_nlink = inode->i_nlink;
	stbuf->st_size = blob_size(blob);
#ifdef HAVE_STAT_NANOSECOND_PRECISION
	stbuf->st_atim = wim_timestamp_to_timespec(inode->i_last_access_time);
	stbuf->st_mtim = wim_timestamp_to_timespec(inode->i_last_write_time);
	stbuf->st_ctim = stbuf->st_mtim;
#else
	stbuf->st_atime = wim_timestamp_to_time_t(inode->i_last_access_time);
	stbuf->st_mtime = wim_timestamp_to_time_t(inode->i_last_write_time);
	stbuf->st_ctime = stbuf->st_mtime;
#endif
	stbuf->st_blocks = DIV_ROUND_UP(blob_stored_size(blob), 512);
	return 0;
}

/* Update the last access and last write timestamps of a WIM inode.  */
static void
touch_inode(struct wim_inode *inode)
{
	u64 now = now_as_wim_timestamp();
	inode->i_last_access_time = now;
	inode->i_last_write_time = now;
}

static void
touch_parent(struct wim_dentry *dentry)
{
	touch_inode(dentry->d_parent->d_inode);
}

/*
 * Update inode metadata after a regular file's contents have changed:
 *
 * - Update the timestamps
 * - Clear the setuid and setgid bits
 */
static void
file_contents_changed(struct wim_inode *inode)
{
	struct wimlib_unix_data unix_data;
	bool ok;

	touch_inode(inode);

	if (inode_get_unix_data(inode, &unix_data)) {
		unix_data.mode &= ~(S_ISUID | S_ISGID);
		ok = inode_set_unix_data(inode, &unix_data, UNIX_DATA_MODE);
		/*
		 * This cannot fail because no memory allocation should have
		 * been required, as the UNIX data already exists.
		 */
		wimlib_assert(ok);
	} /* Else, set[ug]id can't be set, so there's nothing to do. */
}

/*
 * Create a new file in the staging directory for a read-write mounted image.
 *
 * On success, returns the file descriptor for the new staging file, opened for
 * writing.  In addition, stores the allocated name of the staging file in
 * @name_ret.
 *
 * On failure, returns -1 and sets errno.
 */
static int
create_staging_file(const struct wimfs_context *ctx, char **name_ret)
{

	static const size_t STAGING_FILE_NAME_LEN = 20;
	char *name;
	int fd;

	name = MALLOC(STAGING_FILE_NAME_LEN + 1);
	if (!name)
		return -1;
	name[STAGING_FILE_NAME_LEN] = '\0';

retry:
	get_random_alnum_chars(name, STAGING_FILE_NAME_LEN);
	fd = openat(ctx->staging_dir_fd, name,
		    O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW, 0600);
	if (unlikely(fd < 0)) {
		if (unlikely(errno == EEXIST))
			/* Try again with another name.  */
			goto retry;
		FREE(name);
	} else {
		*name_ret = name;
	}
	return fd;
}

/*
 * Extract a blob to the staging directory.  This is necessary when a stream
 * using the blob is being opened for writing and the blob has not already been
 * extracted to the staging directory.
 *
 * @inode
 *	The inode containing the stream being opened for writing.
 * @strm
 *	The stream being opened for writing.  The blob descriptor to which the
 *	stream refers will be changed by this function.
 * @size
 *	Number of bytes of the blob to extract and include in the staging file.
 *	It may be less than the actual blob length, in which case only a prefix
 *	of the blob will be extracted.  It may also be more than the actual blob
 *	length, in which case the extra space will be zero-filled.
 *
 * Returns 0 or a -errno code.
 */
static int
extract_blob_to_staging_dir(struct wim_inode *inode,
			    struct wim_inode_stream *strm,
			    off_t size, const struct wimfs_context *ctx)
{
	struct blob_descriptor *old_blob;
	struct blob_descriptor *new_blob;
	char *staging_file_name;
	int staging_fd;
	off_t extract_size;
	int result;
	int ret;

	old_blob = stream_blob_resolved(strm);

	/* Create the staging file.  */
	staging_fd = create_staging_file(ctx, &staging_file_name);
	if (unlikely(staging_fd < 0))
		return -errno;

	/* Extract the stream to the staging file (possibly truncated).  */
	if (old_blob) {
		struct filedes fd;

		filedes_init(&fd, staging_fd);
		errno = 0;
		extract_size = min(old_blob->size, size);
		result = extract_blob_prefix_to_fd(old_blob, extract_size, &fd);
	} else {
		extract_size = 0;
		result = 0;
	}

	/* In the case of truncate() to more than the file length, extend the
	 * staging file with zeroes by calling ftruncate().  */
	if (!result && size > extract_size)
		result = ftruncate(staging_fd, size);

	/* Close the staging file.  */
	if (close(staging_fd))
		result = -1;

	/* If an error occurred, unlink the staging file.  */
	if (unlikely(result)) {
		/* extract_blob_to_fd() should set errno, but if it didn't,
		 * set a default value.  */
		ret = errno ? -errno : -EIO;
		goto out_delete_staging_file;
	}

	/* Create a blob descriptor for the staging file.  */
	new_blob = new_blob_descriptor();
	if (unlikely(!new_blob)) {
		ret = -ENOMEM;
		goto out_delete_staging_file;
	}

	/* There may already be open file descriptors to this stream if it's
	 * previously been opened read-only, but just now we're opening it
	 * read-write.  Identify those file descriptors, update them to use the
	 * new blob descriptor, and open staging file descriptors for them.  */
	for (u16 i = 0, j = 0; j < inode->i_num_opened_fds; i++) {
		struct wimfs_fd *fd;
		int raw_fd;

		fd = inode->i_fds[i];
		if (!fd)
			continue;

		j++;

		if (fd->f_stream_id != strm->stream_id)
			continue;

		/* This is a readonly fd for the same stream.  */
		fd->f_blob = new_blob;
		new_blob->num_opened_fds++;
		raw_fd = openat(ctx->staging_dir_fd, staging_file_name,
				O_RDONLY | O_NOFOLLOW);
		if (unlikely(raw_fd < 0)) {
			ret = -errno;
			goto out_revert_fd_changes;
		}
		filedes_init(&fd->f_staging_fd, raw_fd);
	}

	if (old_blob)
		old_blob->num_opened_fds -= new_blob->num_opened_fds;

	new_blob->blob_location     = BLOB_IN_STAGING_FILE;
	new_blob->staging_file_name = staging_file_name;
	new_blob->staging_dir_fd    = ctx->staging_dir_fd;
	new_blob->size              = size;

	prepare_unhashed_blob(new_blob, inode, strm->stream_id,
			      &wim_get_current_image_metadata(ctx->wim)->unhashed_blobs);
	inode_replace_stream_blob(inode, strm, new_blob, ctx->wim->blob_table);
	if (size != blob_size(old_blob))
		file_contents_changed(inode);
	return 0;

out_revert_fd_changes:
	for (u16 i = 0; new_blob->num_opened_fds; i++) {
		struct wimfs_fd *fd = inode->i_fds[i];
		if (fd && fd->f_stream_id == strm->stream_id) {
			fd->f_blob = old_blob;
			if (filedes_valid(&fd->f_staging_fd)) {
				filedes_close(&fd->f_staging_fd);
				filedes_invalidate(&fd->f_staging_fd);
			}
			new_blob->num_opened_fds--;
		}
	}
	free_blob_descriptor(new_blob);
out_delete_staging_file:
	unlinkat(ctx->staging_dir_fd, staging_file_name, 0);
	FREE(staging_file_name);
	return ret;
}

/*
 * Create the staging directory for the WIM file.
 *
 * The staging directory will be created in the directory specified by the open
 * file descriptor @parent_dir_fd.  It will be given a randomly generated name
 * based on @wim_basename, the name of the WIM file.
 *
 * On success, returns a file descriptor to the open staging directory with
 * O_RDONLY access.  In addition, stores the allocated name of the staging
 * directory (relative to @parent_dir_fd) in @staging_dir_name_ret.
 * On failure, returns -1 and sets errno.
 */
static int
make_staging_dir_at(int parent_dir_fd, const char *wim_basename,
		    char **staging_dir_name_ret)
{
	static const char common_suffix[8] = ".staging";
	static const size_t random_suffix_len = 10;
	size_t wim_basename_len;
	size_t staging_dir_name_len;
	char *staging_dir_name;
	char *p;
	int fd;

	wim_basename_len = strlen(wim_basename);
	staging_dir_name_len = wim_basename_len + sizeof(common_suffix) +
			       random_suffix_len;
	staging_dir_name = MALLOC(staging_dir_name_len + 1);
	if (!staging_dir_name)
		return -1;

	p = staging_dir_name;
	p = mempcpy(p, wim_basename, wim_basename_len);
	p = mempcpy(p, common_suffix, sizeof(common_suffix));
	get_random_alnum_chars(p, random_suffix_len);
	p += random_suffix_len;
	*p = '\0';

	if (mkdirat(parent_dir_fd, staging_dir_name, 0700))
		goto err1;

	fd = openat(parent_dir_fd, staging_dir_name,
		    O_RDONLY | O_DIRECTORY | O_NOFOLLOW);
	if (fd < 0)
		goto err2;

	*staging_dir_name_ret = staging_dir_name;
	return fd;

err2:
	unlinkat(parent_dir_fd, staging_dir_name, AT_REMOVEDIR);
err1:
	FREE(staging_dir_name);
	return -1;
}

/*
 * Create the staging directory and set ctx->staging_dir_fd,
 * ctx->staging_dir_name, and ctx->parent_dir_fd.
 */
static int
make_staging_dir(struct wimfs_context *ctx, const char *parent_dir_path)
{
	const char *wim_basename;
	char *end = NULL;
	int ret;

	wim_basename = path_basename(ctx->wim->filename);

	if (!parent_dir_path) {
		/* The user did not specify a directory.  Default to creating
		 * the staging directory alongside the WIM file.  */
		if (wim_basename > ctx->wim->filename) {
			parent_dir_path = ctx->wim->filename;
			end = (char *)(wim_basename - 1);
			/* *end must be a slash.  Temporarily overwrite it so we
			 * can open the parent directory.  */
			*end = '\0';
		} else {
			parent_dir_path = ".";
		}
	}

	/* Open the parent directory (in which we'll create our staging
	 * directory).  */
	ctx->parent_dir_fd = open(parent_dir_path, O_RDONLY | O_DIRECTORY);
	if (ctx->parent_dir_fd < 0) {
		ERROR_WITH_ERRNO("Can't open directory \"%s\"",
				 parent_dir_path);
		ret = WIMLIB_ERR_OPENDIR;
		goto out_restore_wim_filename;
	}

	ctx->staging_dir_fd = make_staging_dir_at(ctx->parent_dir_fd,
						  wim_basename,
						  &ctx->staging_dir_name);
	if (ctx->staging_dir_fd < 0) {
		ERROR_WITH_ERRNO("Can't create staging directory in \"%s\"",
				 parent_dir_path);
		close(ctx->parent_dir_fd);
		ret = WIMLIB_ERR_MKDIR;
		goto out_restore_wim_filename;
	}
	ret = 0;
out_restore_wim_filename:
	if (end)
		*end = '/';
	return ret;
}

/* Deletes the staging directory, undoing the effects of a successful call to
 * make_staging_dir().  */
static void
delete_staging_dir(struct wimfs_context *ctx)
{
	DIR *dir;
	struct dirent *ent;

	dir = fdopendir(ctx->staging_dir_fd);
	if (dir) {
		while ((ent = readdir(dir)))
			unlinkat(ctx->staging_dir_fd, ent->d_name, 0);
		closedir(dir);
	} else {
		close(ctx->staging_dir_fd);
	}
	if (unlinkat(ctx->parent_dir_fd, ctx->staging_dir_name, AT_REMOVEDIR))
		WARNING_WITH_ERRNO("Could not delete staging directory");
	FREE(ctx->staging_dir_name);
	close(ctx->parent_dir_fd);
}

static void
prepare_inodes(struct wimfs_context *ctx)
{
	struct wim_image_metadata *imd;
	struct wim_inode *inode;

	ctx->next_ino = 1;
	imd = wim_get_current_image_metadata(ctx->wim);
	image_for_each_inode(inode, imd) {
		inode->i_ino = ctx->next_ino++;
		inode->i_num_opened_fds = 0;
		inode->i_num_allocated_fds = 0;
		inode->i_fds = NULL;
	}
}

/* Delete the 'struct blob_descriptor' for any stream that was modified
 * or created in the read-write mounted image and had a final size of 0.  */
static void
delete_empty_blobs(struct wimfs_context *ctx)
{
	struct blob_descriptor *blob, *tmp;
	struct wim_image_metadata *imd;

	imd = wim_get_current_image_metadata(ctx->wim);

	image_for_each_unhashed_blob_safe(blob, tmp, imd) {
		if (!blob->size) {
			*retrieve_pointer_to_unhashed_blob(blob) = NULL;
			list_del(&blob->unhashed_list);
			free_blob_descriptor(blob);
		}
	}
}

/* Close all file descriptors open to the specified inode.
 *
 * Note: closing the last file descriptor might free the inode.  */
static void
inode_close_fds(struct wim_inode *inode)
{
	u16 num_open_fds = inode->i_num_opened_fds;
	for (u16 i = 0; num_open_fds; i++) {
		if (inode->i_fds[i]) {
			close_wimfs_fd(inode->i_fds[i]);
			num_open_fds--;
		}
	}
}

/* Close all file descriptors open to the mounted image.  */
static void
close_all_fds(struct wimfs_context *ctx)
{
	struct wim_inode *inode;
	struct hlist_node *tmp;
	struct wim_image_metadata *imd;

	imd = wim_get_current_image_metadata(ctx->wim);

	image_for_each_inode_safe(inode, tmp, imd)
		inode_close_fds(inode);
}

/* Moves the currently selected image, which may have been modified, to a new
 * index, and sets the original index to refer to a reset (unmodified) copy of
 * the image.  */
static int
renew_current_image(struct wimfs_context *ctx)
{
	WIMStruct *wim = ctx->wim;
	int image = wim->current_image;
	struct wim_image_metadata *imd;
	struct wim_inode *inode;
	int ret;

	ret = WIMLIB_ERR_NOMEM;
	imd = new_unloaded_image_metadata(ctx->metadata_resource);
	if (!imd)
		goto err;

	ret = append_image_metadata(wim, wim->image_metadata[image - 1]);
	if (ret)
		goto err_put_imd;

	ret = xml_export_image(wim->xml_info, image,
			       wim->xml_info, NULL, NULL, false);
	if (ret)
		goto err_undo_append;

	wim->image_metadata[image - 1] = imd;
	wim->current_image = wim->hdr.image_count;

	ret = select_wim_image(wim, image);
	if (ret)
		goto err_undo_export;

	image_for_each_inode(inode, imd) {
		for (unsigned i = 0; i < inode->i_num_streams; i++) {
			struct blob_descriptor *blob;

			blob = stream_blob(&inode->i_streams[i],
					   wim->blob_table);
			if (blob)
				blob->refcnt += inode->i_nlink;
		}
	}

	select_wim_image(wim, wim->hdr.image_count);
	ctx->metadata_resource = NULL;
	return 0;

err_undo_export:
	xml_delete_image(wim->xml_info, wim->hdr.image_count);
	wim->image_metadata[image - 1] = wim->image_metadata[wim->hdr.image_count - 1];
	wim->current_image = image;
err_undo_append:
	wim->hdr.image_count--;
err_put_imd:
	imd->metadata_blob = NULL;
	put_image_metadata(imd);
err:
	return ret;
}

static enum wimlib_progress_status
commit_progress_func(enum wimlib_progress_msg msg,
		     union wimlib_progress_info *info, void *progctx)
{
	mqd_t mq = *(mqd_t *)progctx;
	struct commit_progress_report report;

	memset(&report, 0, sizeof(report));
	report.msg = msg;
	if (info)
		report.info = *info;
	mq_send(mq, (const char *)&report, sizeof(report), 1);
	return WIMLIB_PROGRESS_STATUS_CONTINUE;
}

/* Commit the mounted image to the underlying WIM file.  */
static int
commit_image(struct wimfs_context *ctx, int unmount_flags, mqd_t mq)
{
	int write_flags;

	if (unmount_flags & WIMLIB_UNMOUNT_FLAG_SEND_PROGRESS)
		wimlib_register_progress_function(ctx->wim,
						  commit_progress_func, &mq);
	else
		wimlib_register_progress_function(ctx->wim, NULL, NULL);

	if (unmount_flags & WIMLIB_UNMOUNT_FLAG_NEW_IMAGE) {
		int ret = renew_current_image(ctx);
		if (ret)
			return ret;
	}
	delete_empty_blobs(ctx);

	write_flags = 0;

	if (unmount_flags & WIMLIB_UNMOUNT_FLAG_CHECK_INTEGRITY)
		write_flags |= WIMLIB_WRITE_FLAG_CHECK_INTEGRITY;

	if (unmount_flags & WIMLIB_UNMOUNT_FLAG_REBUILD)
		write_flags |= WIMLIB_WRITE_FLAG_REBUILD;

	if (unmount_flags & WIMLIB_UNMOUNT_FLAG_RECOMPRESS)
		write_flags |= WIMLIB_WRITE_FLAG_RECOMPRESS;

	return wimlib_overwrite(ctx->wim, write_flags, 0);
}

/* In the case of an allow_other mount, only the mount owner and root are
 * allowed to unmount the filesystem.  */
static bool
may_unmount_wimfs(void)
{
	const struct fuse_context *fuse_ctx = fuse_get_context();
	const struct wimfs_context *wimfs_ctx = WIMFS_CTX(fuse_ctx);

	return (fuse_ctx->uid == wimfs_ctx->owner_uid ||
		fuse_ctx->uid == 0);
}

/* Unmount the mounted image, called from the daemon process.  */
static int
unmount_wimfs(void)
{
	struct fuse_context *fuse_ctx = fuse_get_context();
	struct wimfs_context *wimfs_ctx = WIMFS_CTX(fuse_ctx);
	const struct wimfs_unmount_info *info = &wimfs_ctx->unmount_info;
	int unmount_flags = info->unmount_flags;
	mqd_t mq = (mqd_t)-1;
	int ret;

	/* Ignore COMMIT if the image is mounted read-only.  */
	if (!(wimfs_ctx->mount_flags & WIMLIB_MOUNT_FLAG_READWRITE))
		unmount_flags &= ~WIMLIB_UNMOUNT_FLAG_COMMIT;

	if (unmount_flags & WIMLIB_UNMOUNT_FLAG_SEND_PROGRESS) {
		mq = mq_open(info->mq_name, O_WRONLY | O_NONBLOCK);
		if (mq == (mqd_t)-1) {
			ret = WIMLIB_ERR_MQUEUE;
			goto out;
		}
	}

	if (wimfs_ctx->num_open_fds) {

		/* There are still open file descriptors to the image.  */

		/* With COMMIT, refuse to unmount unless FORCE is also
		 * specified.  */
		if ((unmount_flags & (WIMLIB_UNMOUNT_FLAG_COMMIT |
				      WIMLIB_UNMOUNT_FLAG_FORCE))
				 == WIMLIB_UNMOUNT_FLAG_COMMIT)
		{
			ret = WIMLIB_ERR_MOUNTED_IMAGE_IS_BUSY;
			goto out;
		}

		/* Force-close all file descriptors.  */
		close_all_fds(wimfs_ctx);
	}

	if (unmount_flags & WIMLIB_UNMOUNT_FLAG_COMMIT)
		ret = commit_image(wimfs_ctx, unmount_flags, mq);
	else
		ret = 0;  /* Read-only mount, or discarding changes to
			     a read-write mount  */

out:
	/* Leave the image mounted if commit failed, unless this is a
	 * forced unmount.  The user can retry without COMMIT if they
	 * want.  */
	if (!ret || (unmount_flags & WIMLIB_UNMOUNT_FLAG_FORCE)) {
		unlock_wim_for_append(wimfs_ctx->wim);
		fuse_exit(fuse_ctx->fuse);
	}
	if (mq != (mqd_t)-1)
		mq_close(mq);
	return ret;
}

static void *
wimfs_init(struct fuse_conn_info *conn, struct fuse_config *cfg)
{
	/*
	 * Cache positive name lookups indefinitely, since names can only be
	 * added, removed, or modified through the mounted filesystem itself.
	 */
	cfg->entry_timeout = 1000000000;

	/*
	 * Cache negative name lookups indefinitely, since names can only be
	 * added, removed, or modified through the mounted filesystem itself.
	 */
	cfg->negative_timeout = 1000000000;

	/*
	 * Don't cache file/directory attributes.  This is needed as a
	 * workaround for the fact that when caching attributes, the high level
	 * interface to libfuse considers a file which has several hard-linked
	 * names as several different files.  (Otherwise, we could cache our
	 * file/directory attributes indefinitely, since they can only be
	 * changed through the mounted filesystem itself.)
	 */
	cfg->attr_timeout = 0;

	/*
	 * If an open file is unlinked, unlink it for real rather than renaming
	 * it to a hidden file.  Our code supports this; an unlinked inode is
	 * retained until all its file descriptors have been closed.
	 */
	cfg->hard_remove = 1;

	/*
	 * Make FUSE use the inode numbers we provide.  We want this, because we
	 * have inodes and will number them ourselves.
	 */
	cfg->use_ino = 1;

	/*
	 * Cache the contents of files.  This will speed up repeated access to
	 * files on a mounted WIM image, since they won't need to be
	 * decompressed repeatedly.  This option is valid because data in the
	 * WIM image should never be changed externally.  (Although, if someone
	 * really wanted to they could modify the WIM file or mess with the
	 * staging directory; but then they're asking for trouble.)
	 */
	cfg->kernel_cache = 1;

	/*
	 * We keep track of file descriptor structures (struct wimfs_fd), so
	 * there is no need to have the file path provided on operations such as
	 * read().
	 */
	cfg->nullpath_ok = 1;

	return wimfs_get_context();
}

static int
wimfs_chmod(const char *path, mode_t mask, struct fuse_file_info *fi)
{
	const struct wimfs_context *ctx = wimfs_get_context();
	struct wim_inode *inode;
	struct wimlib_unix_data unix_data;

	if (!(ctx->mount_flags & WIMLIB_MOUNT_FLAG_UNIX_DATA))
		return -EOPNOTSUPP;

	if (fi) {
		inode = WIMFS_FD(fi)->f_inode;
	} else {
		inode = wim_pathname_to_inode(ctx->wim, path);
		if (!inode)
			return -errno;
	}
	unix_data.uid = ctx->owner_uid;
	unix_data.gid = ctx->owner_gid;
	unix_data.mode = mask;
	unix_data.rdev = 0;

	if (!inode_set_unix_data(inode, &unix_data, UNIX_DATA_MODE))
		return -ENOMEM;

	return 0;
}

static int
wimfs_chown(const char *path, uid_t uid, gid_t gid, struct fuse_file_info *fi)
{
	const struct wimfs_context *ctx = wimfs_get_context();
	struct wim_inode *inode;
	struct wimlib_unix_data unix_data;
	int which;

	if (!(ctx->mount_flags & WIMLIB_MOUNT_FLAG_UNIX_DATA))
		return -EOPNOTSUPP;

	if (fi) {
		inode = WIMFS_FD(fi)->f_inode;
	} else {
		inode = wim_pathname_to_inode(ctx->wim, path);
		if (!inode)
			return -errno;
	}

	which = 0;

	if (uid != (uid_t)-1)
		which |= UNIX_DATA_UID;
	else
		uid = ctx->owner_uid;

	if (gid != (gid_t)-1)
		which |= UNIX_DATA_GID;
	else
		gid = ctx->owner_gid;

	unix_data.uid = uid;
	unix_data.gid = gid;
	unix_data.mode = inode_default_unix_mode(inode);
	unix_data.rdev = 0;

	if (!inode_set_unix_data(inode, &unix_data, which))
		return -ENOMEM;

	return 0;
}

static int
wimfs_getattr(const char *path, struct stat *stbuf, struct fuse_file_info *fi)
{
	const struct wimfs_context *ctx = wimfs_get_context();
	const struct wim_inode *inode;
	const struct blob_descriptor *blob;
	int ret;

	if (fi) {
		const struct wimfs_fd *fd = WIMFS_FD(fi);

		inode = fd->f_inode;
		blob = fd->f_blob;
	} else {
		struct wim_dentry *dentry;
		struct wim_inode_stream *strm;

		ret = wim_pathname_to_stream(ctx, path,
					     LOOKUP_FLAG_DIRECTORY_OK,
					     &dentry, &strm);
		if (ret)
			return ret;
		inode = dentry->d_inode;
		blob = stream_blob_resolved(strm);
	}

	return inode_to_stbuf(inode, blob, stbuf);
}

static int
copy_xattr(char *dest, size_t destsize, const void *src, size_t srcsize)
{
	if (destsize) {
		if (destsize < srcsize)
			return -ERANGE;
		memcpy(dest, src, srcsize);
	}
	return srcsize;
}

static int
wimfs_getxattr(const char *path, const char *name, char *value,
	       size_t size)
{
	const struct wimfs_context *ctx = wimfs_get_context();
	const struct wim_inode *inode;
	const struct wim_inode_stream *strm;
	const struct blob_descriptor *blob;

	if (!strncmp(name, "wimfs.", 6)) {
		/* Handle some magical extended attributes.  These really should
		 * be ioctls, but directory ioctls aren't supported until
		 * libfuse 2.9, and even then they are broken.  */
		name += 6;
		if (!strcmp(name, "wim_filename")) {
			return copy_xattr(value, size, ctx->wim->filename,
					  strlen(ctx->wim->filename));
		}
		if (!strcmp(name, "wim_info")) {
			struct wimlib_wim_info info;

			wimlib_get_wim_info(ctx->wim, &info);

			return copy_xattr(value, size, &info, sizeof(info));
		}
		if (!strcmp(name, "mounted_image")) {
			return copy_xattr(value, size,
					  &ctx->wim->current_image, sizeof(int));
		}
		if (!strcmp(name, "mount_flags")) {
			return copy_xattr(value, size,
					  &ctx->mount_flags, sizeof(int));
		}
		if (!strcmp(name, "unmount")) {
			if (!may_unmount_wimfs())
				return -EPERM;
			if (size) {
				int status;

				if (size < sizeof(int))
					return -ERANGE;
				status = unmount_wimfs();
				memcpy(value, &status, sizeof(int));
			}
			return sizeof(int);
		}
		return -ENOATTR;
	}

	if (!(ctx->mount_flags & WIMLIB_MOUNT_FLAG_STREAM_INTERFACE_XATTR))
		return -ENOTSUP;

	if (strncmp(name, "user.", 5))
		return -ENOATTR;
	name += 5;

	if (!*name)
		return -ENOATTR;

	/* Querying a named data stream  */

	inode = wim_pathname_to_inode(ctx->wim, path);
	if (!inode)
		return -errno;

	strm = inode_get_data_stream_tstr(inode, name);
	if (!strm)
		return (errno == ENOENT) ? -ENOATTR : -errno;

	blob = stream_blob_resolved(strm);
	if (!blob)
		return 0;

	if (unlikely(blob->size > INT_MAX))
		return -EFBIG;

	if (size) {
		if (size < blob->size)
			return -ERANGE;

		if (read_blob_into_buf(blob, value))
			return errno ? -errno : -EIO;
	}
	return blob->size;
}

static int
wimfs_link(const char *existing_path, const char *new_path)
{
	WIMStruct *wim = wimfs_get_WIMStruct();
	const char *new_name;
	struct wim_inode *inode;
	struct wim_dentry *dir;
	struct wim_dentry *new_alias;

	inode = wim_pathname_to_inode(wim, existing_path);
	if (!inode)
		return -errno;

	if (inode->i_attributes & (FILE_ATTRIBUTE_DIRECTORY |
				   FILE_ATTRIBUTE_REPARSE_POINT))
		return -EPERM;

	new_name = path_basename(new_path);

	dir = get_parent_dentry(wim, new_path, WIMLIB_CASE_SENSITIVE);
	if (!dir)
		return -errno;

	if (!dentry_is_directory(dir))
		return -ENOTDIR;

	if (get_dentry_child_with_name(dir, new_name, WIMLIB_CASE_SENSITIVE))
		return -EEXIST;

	if (new_dentry_with_existing_inode(new_name, inode, &new_alias))
		return -ENOMEM;

	dentry_add_child(dir, new_alias);
	touch_inode(dir->d_inode);
	return 0;
}

static int
wimfs_listxattr(const char *path, char *list, size_t size)
{
	const struct wimfs_context *ctx = wimfs_get_context();
	const struct wim_inode *inode;
	char *p = list;
	int total_size = 0;

	if (!(ctx->mount_flags & WIMLIB_MOUNT_FLAG_STREAM_INTERFACE_XATTR))
		return -ENOTSUP;

	/* List named data streams, or get the list size.  We report each named
	 * data stream "X" as an extended attribute "user.X".  */

	inode = wim_pathname_to_inode(ctx->wim, path);
	if (!inode)
		return -errno;

	for (unsigned i = 0; i < inode->i_num_streams; i++) {
		const struct wim_inode_stream *strm;
		char *stream_name_mbs;
		size_t stream_name_mbs_nbytes;

		strm = &inode->i_streams[i];

		if (!stream_is_named_data_stream(strm))
			continue;

		if (utf16le_to_tstr(strm->stream_name,
				    utf16le_len_bytes(strm->stream_name),
				    &stream_name_mbs,
				    &stream_name_mbs_nbytes))
			return -errno;

		if (unlikely(INT_MAX - total_size < stream_name_mbs_nbytes + 6)) {
			FREE(stream_name_mbs);
			return -EFBIG;
		}

		total_size += stream_name_mbs_nbytes + 6;
		if (size) {
			if (list + size - p < stream_name_mbs_nbytes + 6) {
				FREE(stream_name_mbs);
				return -ERANGE;
			}
			p = mempcpy(p, "user.", 5);
			p = mempcpy(p, stream_name_mbs, stream_name_mbs_nbytes);
			*p++ = '\0';
		}
		FREE(stream_name_mbs);
	}
	return total_size;
}

static int
wimfs_mkdir(const char *path, mode_t mode)
{
	struct wim_dentry *dentry;
	int ret;

	/* Note: according to fuse.h, mode may not include S_IFDIR  */
	ret = create_file(fuse_get_context(), path, mode | S_IFDIR, 0, &dentry);
	if (ret)
		return ret;
	touch_parent(dentry);
	return 0;
}

static int
wimfs_mknod(const char *path, mode_t mode, dev_t rdev)
{
	struct fuse_context *fuse_ctx = fuse_get_context();
	struct wimfs_context *wimfs_ctx = WIMFS_CTX(fuse_ctx);
	const char *stream_name;

	if ((wimfs_ctx->mount_flags & WIMLIB_MOUNT_FLAG_STREAM_INTERFACE_WINDOWS)
	     && (stream_name = path_stream_name(path)))
	{
		struct wim_inode *inode;
		struct wim_inode_stream *existing_strm;
		struct wim_inode_stream *new_strm;
		char *p;
		const utf16lechar *uname;

		/* Create a named data stream.  */

		if (!S_ISREG(mode))
			return -EOPNOTSUPP;

		p = (char *)stream_name - 1;

		*p = '\0';
		inode = wim_pathname_to_inode(wimfs_ctx->wim, path);
		*p = ':';
		if (!inode)
			return -errno;

		if (tstr_get_utf16le(stream_name, &uname))
			return -errno;

		existing_strm = inode_get_stream(inode, STREAM_TYPE_DATA, uname);
		if (existing_strm) {
			tstr_put_utf16le(uname);
			return -EEXIST;
		}

		new_strm = inode_add_stream(inode, STREAM_TYPE_DATA, uname, NULL);

		tstr_put_utf16le(uname);

		if (!new_strm)
			return -errno;
		return 0;
	} else {
		/* Create a regular file, device node, named pipe, or socket.
		 */
		struct wim_dentry *dentry;
		int ret;

		if (!S_ISREG(mode) &&
		    !(wimfs_ctx->mount_flags & WIMLIB_MOUNT_FLAG_UNIX_DATA))
			return -EPERM;

		ret = create_file(fuse_ctx, path, mode, rdev, &dentry);
		if (ret)
			return ret;
		touch_parent(dentry);
		return 0;
	}
}

static int
wimfs_open(const char *path, struct fuse_file_info *fi)
{
	struct wimfs_context *ctx = wimfs_get_context();
	struct wim_dentry *dentry;
	struct wim_inode *inode;
	struct wim_inode_stream *strm;
	struct blob_descriptor *blob;
	struct wimfs_fd *fd;
	int ret;

	ret = wim_pathname_to_stream(ctx, path, 0, &dentry, &strm);
	if (ret)
		return ret;

	inode = dentry->d_inode;
	blob = stream_blob_resolved(strm);

	/* The data of the file being opened may be in the staging directory
	 * (read-write mounts only) or in the WIM.  If it's in the staging
	 * directory, we need to open a native file descriptor for the
	 * corresponding file.  Otherwise, we can read the file data directly
	 * from the WIM file if we are opening it read-only, but we need to
	 * extract the data to the staging directory if we are opening it
	 * writable.  */

	if (flags_writable(fi->flags) &&
            (!blob || blob->blob_location != BLOB_IN_STAGING_FILE)) {
		ret = extract_blob_to_staging_dir(inode,
						  strm,
						  blob_size(blob),
						  ctx);
		if (ret)
			return ret;
		blob = stream_blob_resolved(strm);
	}

	ret = alloc_wimfs_fd(inode, strm, &fd);
	if (ret)
		return ret;

	if (blob && blob->blob_location == BLOB_IN_STAGING_FILE) {
		int raw_fd;

		raw_fd = openat(blob->staging_dir_fd, blob->staging_file_name,
				(fi->flags & (O_ACCMODE | O_TRUNC)) |
				O_NOFOLLOW);
		if (raw_fd < 0) {
			close_wimfs_fd(fd);
			return -errno;
		}
		filedes_init(&fd->f_staging_fd, raw_fd);
		if (fi->flags & O_TRUNC) {
			blob->size = 0;
			file_contents_changed(inode);
		}
	}
	fi->fh = (uintptr_t)fd;
	return 0;
}

static int
wimfs_opendir(const char *path, struct fuse_file_info *fi)
{
	WIMStruct *wim = wimfs_get_WIMStruct();
	struct wim_inode *inode;
	struct wim_inode_stream *strm;
	struct wimfs_fd *fd;
	int ret;

	inode = wim_pathname_to_inode(wim, path);
	if (!inode)
		return -errno;
	if (!inode_is_directory(inode))
		return -ENOTDIR;
	strm = inode_get_unnamed_data_stream(inode);
	if (!strm)
		return -ENOTDIR;
	ret = alloc_wimfs_fd(inode, strm, &fd);
	if (ret)
		return ret;
	fi->fh = (uintptr_t)fd;
	return 0;
}

static int
wimfs_read(const char *path, char *buf, size_t size,
	   off_t offset, struct fuse_file_info *fi)
{
	struct wimfs_fd *fd = WIMFS_FD(fi);
	const struct blob_descriptor *blob;
	ssize_t ret;

	blob = fd->f_blob;
	if (!blob)
		return 0;

	if (offset >= blob->size)
		return 0;

	if (size > blob->size - offset)
		size = blob->size - offset;

	if (!size)
		return 0;

	switch (blob->blob_location) {
	case BLOB_IN_WIM:
		if (read_partial_wim_blob_into_buf(blob, offset, size, buf))
			ret = errno ? -errno : -EIO;
		else
			ret = size;
		break;
	case BLOB_IN_STAGING_FILE:
		ret = pread(fd->f_staging_fd.fd, buf, size, offset);
		if (ret < 0)
			ret = -errno;
		break;
	case BLOB_IN_ATTACHED_BUFFER:
		memcpy(buf, blob->attached_buffer + offset, size);
		ret = size;
		break;
	default:
		ret = -EINVAL;
		break;
	}
	return ret;
}

static int
wimfs_readdir(const char *path, void *buf, fuse_fill_dir_t filler,
	      off_t offset, struct fuse_file_info *fi,
	      enum fuse_readdir_flags flags)
{
	struct wimfs_fd *fd = WIMFS_FD(fi);
	const struct wim_inode *inode;
	const struct wim_dentry *child;
	int ret;

	inode = fd->f_inode;

	ret = filler(buf, ".", NULL, 0, 0);
	if (ret)
		return ret;
	ret = filler(buf, "..", NULL, 0, 0);
	if (ret)
		return ret;

	for_inode_child(child, inode) {
		char *name;
		size_t name_nbytes;

		if (utf16le_to_tstr(child->d_name, child->d_name_nbytes,
				    &name, &name_nbytes))
			return -errno;

		ret = filler(buf, name, NULL, 0, 0);
		FREE(name);
		if (ret)
			return ret;
	}
	return 0;
}

static int
wimfs_readlink(const char *path, char *buf, size_t bufsize)
{
	struct wimfs_context *ctx = wimfs_get_context();
	const struct wim_inode *inode;
	int ret;

	inode = wim_pathname_to_inode(ctx->wim, path);
	if (!inode)
		return -errno;
	if (bufsize <= 0)
		return -EINVAL;
	ret = wim_inode_readlink(inode, buf, bufsize - 1, NULL,
				 ctx->mountpoint_abspath,
				 ctx->mountpoint_abspath_nchars);
	if (ret < 0)
		return ret;
	buf[ret] = '\0';
	return 0;
}

/* We use this for both release() and releasedir(), since in both cases we
 * simply need to close the file descriptor.  */
static int
wimfs_release(const char *path, struct fuse_file_info *fi)
{
	return close_wimfs_fd(WIMFS_FD(fi));
}

static int
wimfs_removexattr(const char *path, const char *name)
{
	struct wimfs_context *ctx = wimfs_get_context();
	struct wim_inode *inode;
	struct wim_inode_stream *strm;

	if (!(ctx->mount_flags & WIMLIB_MOUNT_FLAG_STREAM_INTERFACE_XATTR))
		return -ENOTSUP;

	if (strncmp(name, "user.", 5))
		return -ENOATTR;
	name += 5;

	if (!*name)
		return -ENOATTR;

	/* Removing a named data stream.  */

	inode = wim_pathname_to_inode(ctx->wim, path);
	if (!inode)
		return -errno;

	strm = inode_get_data_stream_tstr(inode, name);
	if (!strm)
		return (errno == ENOENT) ? -ENOATTR : -errno;

	inode_remove_stream(inode, strm, ctx->wim->blob_table);
	return 0;
}

static int
wimfs_rename(const char *from, const char *to, unsigned int flags)
{
	if (flags & RENAME_EXCHANGE)
		return -EINVAL;
	return rename_wim_path(wimfs_get_WIMStruct(), from, to,
			       WIMLIB_CASE_SENSITIVE,
			       (flags & RENAME_NOREPLACE), NULL);
}

static int
wimfs_rmdir(const char *path)
{
	WIMStruct *wim = wimfs_get_WIMStruct();
	struct wim_dentry *dentry;

	dentry = get_dentry(wim, path, WIMLIB_CASE_SENSITIVE);
	if (!dentry)
		return -errno;

	if (!dentry_is_directory(dentry))
		return -ENOTDIR;

	if (dentry_has_children(dentry))
		return -ENOTEMPTY;

	touch_parent(dentry);
	remove_dentry(dentry, wim->blob_table);
	return 0;
}

static int
wimfs_setxattr(const char *path, const char *name,
	       const char *value, size_t size, int flags)
{
	struct wimfs_context *ctx = wimfs_get_context();
	struct wim_inode *inode;
	struct wim_inode_stream *strm;
	const utf16lechar *uname;
	int ret;

	if (!strncmp(name, "wimfs.", 6)) {
		/* Handle some magical extended attributes.  These really should
		 * be ioctls, but directory ioctls aren't supported until
		 * libfuse 2.9, and even then they are broken.  [Fixed by
		 * libfuse commit e3b7d4c278a26520be63d99d6ea84b26906fe73d]  */
		name += 6;
		if (!strcmp(name, "unmount_info")) {
			if (!may_unmount_wimfs())
				return -EPERM;
			if (size < sizeof(struct wimfs_unmount_info))
				return -EINVAL;
			memcpy(&ctx->unmount_info, value,
			       sizeof(struct wimfs_unmount_info));
			return 0;
		}
		return -ENOATTR;
	}

	if (!(ctx->mount_flags & WIMLIB_MOUNT_FLAG_STREAM_INTERFACE_XATTR))
		return -ENOTSUP;

	if (strncmp(name, "user.", 5))
		return -ENOATTR;
	name += 5;

	if (!*name)
		return -ENOATTR;

	/* Setting the contents of a named data stream.  */

	inode = wim_pathname_to_inode(ctx->wim, path);
	if (!inode)
		return -errno;

	ret = tstr_get_utf16le(name, &uname);
	if (ret)
		return -errno;

	strm = inode_get_stream(inode, STREAM_TYPE_DATA, uname);
	if (strm) {
		ret = -EEXIST;
		if (flags & XATTR_CREATE)
			goto out_put_uname;
	} else {
		ret = -ENOATTR;
		if (flags & XATTR_REPLACE)
			goto out_put_uname;
	}

	if (strm) {
		if (!inode_replace_stream_data(inode, strm, value, size,
					       ctx->wim->blob_table))
		{
			ret = -errno;
			goto out_put_uname;
		}
	} else {
		if (!inode_add_stream_with_data(inode, STREAM_TYPE_DATA, uname,
						value, size, ctx->wim->blob_table))
		{
			ret = -errno;
			goto out_put_uname;
		}
	}

	ret = 0;
out_put_uname:
	tstr_put_utf16le(uname);
	return ret;
}

static int
wimfs_symlink(const char *to, const char *from)
{
	struct fuse_context *fuse_ctx = fuse_get_context();
	struct wimfs_context *wimfs_ctx = WIMFS_CTX(fuse_ctx);
	struct wim_dentry *dentry;
	int ret;

	ret = create_file(fuse_ctx, from, S_IFLNK | 0777, 0, &dentry);
	if (ret)
		return ret;
	ret = wim_inode_set_symlink(dentry->d_inode, to,
				    wimfs_ctx->wim->blob_table);
	if (ret) {
		remove_dentry(dentry, wimfs_ctx->wim->blob_table);
		if (ret == WIMLIB_ERR_NOMEM)
			ret = -ENOMEM;
		else
			ret = -EINVAL;
	} else {
		touch_parent(dentry);
	}
	return ret;
}

static int
do_truncate(int staging_fd, off_t size,
	    struct wim_inode *inode, struct blob_descriptor *blob)
{
	if (ftruncate(staging_fd, size))
		return -errno;
	file_contents_changed(inode);
	blob->size = size;
	return 0;
}

static int
wimfs_truncate(const char *path, off_t size, struct fuse_file_info *fi)
{
	const struct wimfs_context *ctx = wimfs_get_context();
	struct wim_dentry *dentry;
	struct wim_inode_stream *strm;
	struct blob_descriptor *blob;
	int ret;
	int staging_fd;

	if (fi) {
		struct wimfs_fd *fd = WIMFS_FD(fi);

		return do_truncate(fd->f_staging_fd.fd, size, fd->f_inode,
				   fd->f_blob);
	}

	ret = wim_pathname_to_stream(ctx, path, 0, &dentry, &strm);
	if (ret)
		return ret;

	blob = stream_blob_resolved(strm);

	if (!blob && !size)
		return 0;

	if (!blob || blob->blob_location != BLOB_IN_STAGING_FILE) {
		return extract_blob_to_staging_dir(dentry->d_inode,
						   strm, size, ctx);
	}

	/* Truncate the staging file.  */
	staging_fd = openat(blob->staging_dir_fd, blob->staging_file_name,
			    O_WRONLY | O_NOFOLLOW);
	if (staging_fd < 0)
		return -errno;
	ret = do_truncate(staging_fd, size, dentry->d_inode, blob);
	if (close(staging_fd) && !ret)
		ret = -errno;
	return ret;
}

static int
wimfs_unlink(const char *path)
{
	const struct wimfs_context *ctx = wimfs_get_context();
	struct wim_dentry *dentry;
	struct wim_inode_stream *strm;
	int ret;

	ret = wim_pathname_to_stream(ctx, path, 0, &dentry, &strm);
	if (ret)
		return ret;

	if (stream_is_named(strm)) {
		inode_remove_stream(dentry->d_inode, strm,
				    ctx->wim->blob_table);
	} else {
		touch_parent(dentry);
		remove_dentry(dentry, ctx->wim->blob_table);
	}
	return 0;
}

/*
 * Change the timestamp on a file dentry.
 *
 * Note that alternate data streams do not have their own timestamps.
 */
static int
wimfs_utimens(const char *path, const struct timespec tv[2],
	      struct fuse_file_info *fi)
{
	struct wim_inode *inode;

	if (fi) {
		inode = WIMFS_FD(fi)->f_inode;
	} else {
		inode = wim_pathname_to_inode(wimfs_get_WIMStruct(), path);
		if (!inode)
			return -errno;
	}

	if (tv[0].tv_nsec != UTIME_OMIT) {
		if (tv[0].tv_nsec == UTIME_NOW)
			inode->i_last_access_time = now_as_wim_timestamp();
		else
			inode->i_last_access_time = timespec_to_wim_timestamp(&tv[0]);
	}
	if (tv[1].tv_nsec != UTIME_OMIT) {
		if (tv[1].tv_nsec == UTIME_NOW)
			inode->i_last_write_time = now_as_wim_timestamp();
		else
			inode->i_last_write_time = timespec_to_wim_timestamp(&tv[1]);
	}
	return 0;
}

static int
wimfs_write(const char *path, const char *buf, size_t size,
	    off_t offset, struct fuse_file_info *fi)
{
	struct wimfs_fd *fd = WIMFS_FD(fi);
	ssize_t ret;

	ret = pwrite(fd->f_staging_fd.fd, buf, size, offset);
	if (ret < 0)
		return -errno;

	if (offset + size > fd->f_blob->size)
		fd->f_blob->size = offset + size;

	file_contents_changed(fd->f_inode);
	return ret;
}

static const struct fuse_operations wimfs_operations = {
	.init	     = wimfs_init,
	.chmod       = wimfs_chmod,
	.chown       = wimfs_chown,
	.getattr     = wimfs_getattr,
	.getxattr    = wimfs_getxattr,
	.link        = wimfs_link,
	.listxattr   = wimfs_listxattr,
	.mkdir       = wimfs_mkdir,
	.mknod       = wimfs_mknod,
	.open        = wimfs_open,
	.opendir     = wimfs_opendir,
	.read        = wimfs_read,
	.readdir     = wimfs_readdir,
	.readlink    = wimfs_readlink,
	.release     = wimfs_release,
	.releasedir  = wimfs_release,
	.removexattr = wimfs_removexattr,
	.rename      = wimfs_rename,
	.rmdir       = wimfs_rmdir,
	.setxattr    = wimfs_setxattr,
	.symlink     = wimfs_symlink,
	.truncate    = wimfs_truncate,
	.unlink      = wimfs_unlink,
	.utimens     = wimfs_utimens,
	.write       = wimfs_write,

};

/* API function documented in wimlib.h  */
WIMLIBAPI int
wimlib_mount_image(WIMStruct *wim, int image, const char *dir,
		   int mount_flags, const char *staging_dir)
{
	int ret;
	struct wim_image_metadata *imd;
	struct wimfs_context ctx;
	char *fuse_argv[16];
	int fuse_argc;

	if (!wim || !dir || !*dir)
		return WIMLIB_ERR_INVALID_PARAM;

	if (mount_flags & ~(WIMLIB_MOUNT_FLAG_READWRITE |
			    WIMLIB_MOUNT_FLAG_DEBUG |
			    WIMLIB_MOUNT_FLAG_STREAM_INTERFACE_NONE |
			    WIMLIB_MOUNT_FLAG_STREAM_INTERFACE_XATTR |
			    WIMLIB_MOUNT_FLAG_STREAM_INTERFACE_WINDOWS |
			    WIMLIB_MOUNT_FLAG_UNIX_DATA |
			    WIMLIB_MOUNT_FLAG_ALLOW_OTHER))
		return WIMLIB_ERR_INVALID_PARAM;

	/* For read-write mount, check for write access to the WIM.  */
	if (mount_flags & WIMLIB_MOUNT_FLAG_READWRITE) {
		if (!wim->filename)
			return WIMLIB_ERR_NO_FILENAME;
		ret = can_modify_wim(wim);
		if (ret)
			return ret;
	}

	/* Select the image to mount.  */
	ret = select_wim_image(wim, image);
	if (ret)
		return ret;

	/* Get the metadata for the image to mount.  */
	imd = wim_get_current_image_metadata(wim);

	/* To avoid complicating things, we don't support mounting images to
	 * which in-memory modifications have already been made.  */
	if (is_image_dirty(imd)) {
		ERROR("Cannot mount a modified WIM image!");
		return WIMLIB_ERR_INVALID_PARAM;
	}

	if (mount_flags & WIMLIB_MOUNT_FLAG_READWRITE) {
		if (imd->refcnt > 1)
			return WIMLIB_ERR_IMAGE_HAS_MULTIPLE_REFERENCES;
		ret = lock_wim_for_append(wim);
		if (ret)
			return ret;
	}

	if (wim_has_solid_resources(wim)) {
		WARNING("Mounting a WIM file containing solid-compressed data; "
			"file access may be slow.");
	}

	/* If the user did not specify an interface for accessing named
	 * data streams, use the default (extended attributes).  */
	if (!(mount_flags & (WIMLIB_MOUNT_FLAG_STREAM_INTERFACE_NONE |
			     WIMLIB_MOUNT_FLAG_STREAM_INTERFACE_XATTR |
			     WIMLIB_MOUNT_FLAG_STREAM_INTERFACE_WINDOWS)))
		mount_flags |= WIMLIB_MOUNT_FLAG_STREAM_INTERFACE_XATTR;

	/* Start initializing the wimfs_context.  */
	memset(&ctx, 0, sizeof(struct wimfs_context));
	ctx.wim = wim;
	ctx.mount_flags = mount_flags;
	if (mount_flags & WIMLIB_MOUNT_FLAG_STREAM_INTERFACE_WINDOWS)
		ctx.default_lookup_flags = LOOKUP_FLAG_ADS_OK;

	/* For read-write mounts, create the staging directory, save a reference
	 * to the image's metadata resource, and mark the image dirty.  */
	if (mount_flags & WIMLIB_MOUNT_FLAG_READWRITE) {
		ret = make_staging_dir(&ctx, staging_dir);
		if (ret)
			goto out;
		ret = WIMLIB_ERR_NOMEM;
		ctx.metadata_resource = clone_blob_descriptor(
							imd->metadata_blob);
		if (!ctx.metadata_resource)
			goto out;
		mark_image_dirty(imd);
	}
	ctx.owner_uid = getuid();
	ctx.owner_gid = getgid();

	/* Number the inodes in the mounted image sequentially and initialize
	 * the file descriptor arrays  */
	prepare_inodes(&ctx);

	/* Save the absolute path to the mountpoint directory.  */
	ctx.mountpoint_abspath = realpath(dir, NULL);
	if (ctx.mountpoint_abspath)
		ctx.mountpoint_abspath_nchars = strlen(ctx.mountpoint_abspath);

	/* Build the FUSE command line.  */

	fuse_argc = 0;
	fuse_argv[fuse_argc++] = "wimlib";
	fuse_argv[fuse_argc++] = (char *)dir;

	/* Disable multi-threaded operation.  */
	fuse_argv[fuse_argc++] = "-s";

	/* Enable FUSE debug mode (don't fork) if requested by the user.  */
	if (mount_flags & WIMLIB_MOUNT_FLAG_DEBUG)
		fuse_argv[fuse_argc++] = "-d";

	/*
	 * Build the FUSE mount options:
	 *
	 * subtype=wimfs
	 *	Name for our filesystem (main type is "fuse").
	 *
	 * default_permissions
	 *	FUSE will perform permission checking.  Useful when
	 *	WIMLIB_MOUNT_FLAG_UNIX_DATA is provided and the WIM image
	 *	contains the UNIX permissions for each file.
	 */
	char optstring[128] = "subtype=wimfs,default_permissions";
	fuse_argv[fuse_argc++] = "-o";
	fuse_argv[fuse_argc++] = optstring;
	if (!(mount_flags & WIMLIB_MOUNT_FLAG_READWRITE))
		strcat(optstring, ",ro");
	if (mount_flags & WIMLIB_MOUNT_FLAG_ALLOW_OTHER)
		strcat(optstring, ",allow_other");
	fuse_argv[fuse_argc] = NULL;

	/* Mount our filesystem.  */
	ret = fuse_main(fuse_argc, fuse_argv, &wimfs_operations, &ctx);

	/* Cleanup and return.  */
	if (ret)
		ret = WIMLIB_ERR_FUSE;
out:
	FREE(ctx.mountpoint_abspath);
	free_blob_descriptor(ctx.metadata_resource);
	if (ctx.staging_dir_name)
		delete_staging_dir(&ctx);
	unlock_wim_for_append(wim);
	return ret;
}

struct commit_progress_thread_args {
	mqd_t mq;
	wimlib_progress_func_t progfunc;
	void *progctx;
};

static void *
commit_progress_thread_proc(void *_args)
{
	struct commit_progress_thread_args *args = _args;
	struct commit_progress_report report;
	ssize_t ret;

	for (;;) {
		ret = mq_receive(args->mq,
				 (char *)&report, sizeof(report), NULL);
		if (ret == sizeof(report)) {
			call_progress(args->progfunc, report.msg,
				      &report.info, args->progctx);
		} else {
			if (ret == 0 || (ret < 0 && errno != EINTR))
				break;
		}
	}
	return NULL;
}

static void
generate_message_queue_name(char name[WIMFS_MQUEUE_NAME_LEN + 1])
{
	name[0] = '/';
	memcpy(name + 1, "wimfs-", 6);
	get_random_alnum_chars(name + 7, WIMFS_MQUEUE_NAME_LEN - 7);
	name[WIMFS_MQUEUE_NAME_LEN] = '\0';
}

static mqd_t
create_message_queue(const char *name)
{
	bool am_root;
	mode_t umask_save;
	mode_t mode;
	struct mq_attr attr;
	mqd_t mq;

	memset(&attr, 0, sizeof(attr));
	attr.mq_maxmsg = 8;
	attr.mq_msgsize = sizeof(struct commit_progress_report);

	am_root = (geteuid() == 0);
	if (am_root) {
		/* Filesystem mounted as normal user with --allow-other should
		 * be able to send messages to root user, if they're doing the
		 * unmount.  */
		umask_save = umask(0);
		mode = 0666;
	} else {
		mode = 0600;
	}
	mq = mq_open(name, O_RDWR | O_CREAT | O_EXCL, mode, &attr);
	if (am_root)
		umask(umask_save);
	return mq;
}

/* Unmount a read-only or read-write mounted WIM image.  */
static int
do_unmount(const char *dir)
{
	int status;
	ssize_t len;

	len = getxattr(dir, "wimfs.unmount", &status, sizeof(int));
	if (len == sizeof(int))
		return status;
	else if (len < 0 && (errno == EACCES || errno == EPERM))
		return WIMLIB_ERR_NOT_PERMITTED_TO_UNMOUNT;
	else
		return WIMLIB_ERR_NOT_A_MOUNTPOINT;
}

static int
set_unmount_info(const char *dir, const struct wimfs_unmount_info *unmount_info)
{
	if (!setxattr(dir, "wimfs.unmount_info",
		      unmount_info, sizeof(struct wimfs_unmount_info), 0))
		return 0;
	else if (errno == EROFS)
		return 0;
	else if (errno == EACCES || errno == EPERM)
		return WIMLIB_ERR_NOT_PERMITTED_TO_UNMOUNT;
	else
		return WIMLIB_ERR_NOT_A_MOUNTPOINT;
}

static int
do_unmount_discard(const char *dir)
{
	int ret;
	struct wimfs_unmount_info unmount_info;

	memset(&unmount_info, 0, sizeof(unmount_info));

	ret = set_unmount_info(dir, &unmount_info);
	if (ret)
		return ret;
	return do_unmount(dir);
}

/* Unmount a read-write mounted WIM image, committing the changes.  */
static int
do_unmount_commit(const char *dir, int unmount_flags,
		  wimlib_progress_func_t progfunc, void *progctx)
{
	struct wimfs_unmount_info unmount_info;
	mqd_t mq = (mqd_t)-1;
	struct commit_progress_thread_args args;
	struct thread commit_progress_tid;
	int ret;

	memset(&unmount_info, 0, sizeof(unmount_info));
	unmount_info.unmount_flags = unmount_flags;

	/* The current thread will be stuck in getxattr() until the image is
	 * committed.  Create a thread to handle the progress messages.  */
	if (progfunc) {
		generate_message_queue_name(unmount_info.mq_name);

		mq = create_message_queue(unmount_info.mq_name);
		if (mq == (mqd_t)-1) {
			ERROR_WITH_ERRNO("Can't create POSIX message queue");
			return WIMLIB_ERR_MQUEUE;
		}
		args.mq = mq;
		args.progfunc = progfunc;
		args.progctx = progctx;
		if (!_thread_create(&commit_progress_tid,
				   commit_progress_thread_proc, &args)) {
			ret = WIMLIB_ERR_NOMEM;
			goto out_delete_mq;
		}
		unmount_info.unmount_flags |= WIMLIB_UNMOUNT_FLAG_SEND_PROGRESS;
	}

	ret = set_unmount_info(dir, &unmount_info);
	if (!ret)
		ret = do_unmount(dir);
	if (progfunc) {
		/* Terminate the progress thread.  */
		char empty[1];
		mq_send(mq, empty, 0, 1);
		thread_join(&commit_progress_tid);
	}
out_delete_mq:
	if (progfunc) {
		mq_close(mq);
		mq_unlink(unmount_info.mq_name);
	}
	return ret;
}

static int
begin_unmount(const char *dir, int unmount_flags, int *mount_flags_ret,
	      wimlib_progress_func_t progfunc, void *progctx)
{
	int mount_flags;
	int mounted_image;
	int wim_filename_len;
	union wimlib_progress_info progress;

	if (getxattr(dir, "wimfs.mount_flags",
		     &mount_flags, sizeof(int)) != sizeof(int))
		return WIMLIB_ERR_NOT_A_MOUNTPOINT;

	*mount_flags_ret = mount_flags;

	if (!progfunc)
		return 0;

	if (getxattr(dir, "wimfs.mounted_image",
		     &mounted_image, sizeof(int)) != sizeof(int))
		return WIMLIB_ERR_NOT_A_MOUNTPOINT;

	wim_filename_len = getxattr(dir, "wimfs.wim_filename", NULL, 0);
	if (wim_filename_len < 0)
		return WIMLIB_ERR_NOT_A_MOUNTPOINT;

	char wim_filename[wim_filename_len + 1];
	if (getxattr(dir, "wimfs.wim_filename",
		     wim_filename, wim_filename_len) != wim_filename_len)
		return WIMLIB_ERR_NOT_A_MOUNTPOINT;
	wim_filename[wim_filename_len] = '\0';

	progress.unmount.mountpoint = dir;
	progress.unmount.mounted_wim = wim_filename;
	progress.unmount.mounted_image = mounted_image;
	progress.unmount.mount_flags = mount_flags;
	progress.unmount.unmount_flags = unmount_flags;

	return call_progress(progfunc, WIMLIB_PROGRESS_MSG_UNMOUNT_BEGIN,
			     &progress, progctx);
}

/* API function documented in wimlib.h  */
WIMLIBAPI int
wimlib_unmount_image_with_progress(const char *dir, int unmount_flags,
				   wimlib_progress_func_t progfunc, void *progctx)
{
	int mount_flags;
	int ret;

	ret = wimlib_global_init(0);
	if (ret)
		return ret;

	if (unmount_flags & ~(WIMLIB_UNMOUNT_FLAG_CHECK_INTEGRITY |
			      WIMLIB_UNMOUNT_FLAG_COMMIT |
			      WIMLIB_UNMOUNT_FLAG_REBUILD |
			      WIMLIB_UNMOUNT_FLAG_RECOMPRESS |
			      WIMLIB_UNMOUNT_FLAG_FORCE |
			      WIMLIB_UNMOUNT_FLAG_NEW_IMAGE))
		return WIMLIB_ERR_INVALID_PARAM;

	ret = begin_unmount(dir, unmount_flags, &mount_flags,
			    progfunc, progctx);
	if (ret)
		return ret;

	if ((unmount_flags & WIMLIB_UNMOUNT_FLAG_COMMIT) &&
	    (mount_flags & WIMLIB_MOUNT_FLAG_READWRITE))
		return do_unmount_commit(dir, unmount_flags,
					 progfunc, progctx);
	else
		return do_unmount_discard(dir);
}

#else /* WITH_FUSE */


static int
mount_unsupported_error(void)
{
#ifdef _WIN32
	ERROR("Sorry-- Mounting WIM images is not supported on Windows!");
#else
	ERROR("wimlib was compiled with --without-fuse, which disables support "
	      "for mounting WIMs.");
#endif
	return WIMLIB_ERR_UNSUPPORTED;
}

WIMLIBAPI int
wimlib_unmount_image_with_progress(const tchar *dir, int unmount_flags,
				   wimlib_progress_func_t progfunc, void *progctx)
{
	return mount_unsupported_error();
}

WIMLIBAPI int
wimlib_mount_image(WIMStruct *wim, int image, const tchar *dir,
		   int mount_flags, const tchar *staging_dir)
{
	return mount_unsupported_error();
}

#endif /* !WITH_FUSE */

WIMLIBAPI int
wimlib_unmount_image(const tchar *dir, int unmount_flags)
{
	return wimlib_unmount_image_with_progress(dir, unmount_flags, NULL, NULL);
}
