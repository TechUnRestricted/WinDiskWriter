/*
 * ntfs-3g_capture.c
 *
 * Capture a WIM image directly from an NTFS volume using libntfs-3g.  We capture
 * everything we can, including security data and alternate data streams.
 */

/*
 * Copyright (C) 2012-2017 Eric Biggers
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

#ifdef WITH_NTFS_3G

#include <errno.h>

#include <ntfs-3g/attrib.h>
#include <ntfs-3g/compat.h> /* for ENODATA, if needed */
#include <ntfs-3g/object_id.h>
#include <ntfs-3g/reparse.h>
#include <ntfs-3g/security.h>
#include <ntfs-3g/volume.h>

#include "wimlib/alloca.h"
#include "wimlib/assert.h"
#include "wimlib/blob_table.h"
#include "wimlib/dentry.h"
#include "wimlib/encoding.h"
#include "wimlib/endianness.h"
#include "wimlib/error.h"
#include "wimlib/ntfs_3g.h"
#include "wimlib/object_id.h"
#include "wimlib/paths.h"
#include "wimlib/reparse.h"
#include "wimlib/scan.h"
#include "wimlib/security.h"

/* NTFS-3G 2013 renamed MS_RDONLY to NTFS_MNT_RDONLY.  We can't check for the
 * existence of NTFS_MNT_RDONLY at compilation time because it's an enum.  We
 * also can't check for MS_RDONLY being missing because it's also a system
 * constant.  So check if the NTFS-3G specific MS_IGNORE_HIBERFILE is defined;
 * if yes, then we need to use the old MS_RDONLY.  */
#ifdef MS_IGNORE_HIBERFILE
#  define NTFS_MNT_RDONLY MS_RDONLY
#endif

/* A reference-counted NTFS volume than is automatically unmounted when the
 * reference count reaches 0  */
struct ntfs_volume_wrapper {
	ntfs_volume *vol;
	size_t refcnt;
	bool dedup_warned;
};

/* Description of where data is located in an NTFS volume  */
struct ntfs_location {
	struct ntfs_volume_wrapper *volume;
	u64 mft_no;
	ATTR_TYPES attr_type;
	u32 attr_name_nchars;
	ntfschar *attr_name;
	u64 sort_key;
};

static struct ntfs_volume_wrapper *
get_ntfs_volume(struct ntfs_volume_wrapper *volume)
{
	volume->refcnt++;
	return volume;
}

static void
put_ntfs_volume(struct ntfs_volume_wrapper *volume)
{
	if (--volume->refcnt == 0) {
		ntfs_umount(volume->vol, FALSE);
		FREE(volume);
	}
}

static inline const ntfschar *
attr_record_name(const ATTR_RECORD *record)
{
	return (const ntfschar *)
		((const u8 *)record + le16_to_cpu(record->name_offset));
}

static ntfs_attr *
open_ntfs_attr(ntfs_inode *ni, const struct ntfs_location *loc)
{
	ntfs_attr *na;

	na = ntfs_attr_open(ni, loc->attr_type, loc->attr_name,
			    loc->attr_name_nchars);
	if (!na) {
		ERROR_WITH_ERRNO("Failed to open attribute of NTFS inode %"PRIu64,
				 loc->mft_no);
	}
	return na;
}

int
read_ntfs_attribute_prefix(const struct blob_descriptor *blob, u64 size,
			   const struct consume_chunk_callback *cb,
			   bool recover_data)
{
	const struct ntfs_location *loc = blob->ntfs_loc;
	ntfs_volume *vol = loc->volume->vol;
	ntfs_inode *ni;
	ntfs_attr *na;
	s64 pos;
	s64 bytes_remaining;
	int ret;
	u8 buf[BUFFER_SIZE];

	ni = ntfs_inode_open(vol, loc->mft_no);
	if (!ni) {
		ERROR_WITH_ERRNO("Failed to open NTFS inode %"PRIu64,
				 loc->mft_no);
		ret = WIMLIB_ERR_NTFS_3G;
		goto out;
	}

	na = open_ntfs_attr(ni, loc);
	if (!na) {
		ret = WIMLIB_ERR_NTFS_3G;
		goto out_close_ntfs_inode;
	}

	pos = (loc->attr_type == AT_REPARSE_POINT) ? REPARSE_DATA_OFFSET : 0;
	bytes_remaining = size;
	while (bytes_remaining) {
		s64 to_read = min(bytes_remaining, sizeof(buf));
		if (ntfs_attr_pread(na, pos, to_read, buf) != to_read) {
			ERROR_WITH_ERRNO("Error reading data from NTFS inode "
					 "%"PRIu64, loc->mft_no);
			ret = WIMLIB_ERR_NTFS_3G;
			goto out_close_ntfs_attr;
		}
		pos += to_read;
		bytes_remaining -= to_read;
		ret = consume_chunk(cb, buf, to_read);
		if (ret)
			goto out_close_ntfs_attr;
	}
	ret = 0;
out_close_ntfs_attr:
	ntfs_attr_close(na);
out_close_ntfs_inode:
	ntfs_inode_close(ni);
out:
	return ret;
}

void
free_ntfs_location(struct ntfs_location *loc)
{
	put_ntfs_volume(loc->volume);
	if (loc->attr_name != AT_UNNAMED)
		FREE(loc->attr_name);
	FREE(loc);
}

struct ntfs_location *
clone_ntfs_location(const struct ntfs_location *loc)
{
	struct ntfs_location *new = memdup(loc, sizeof(*loc));
	if (!new)
		goto err0;
	if (loc->attr_name != AT_UNNAMED) {
		new->attr_name = utf16le_dup(loc->attr_name);
		if (!new->attr_name)
			goto err1;
	}
	new->volume = get_ntfs_volume(loc->volume);
	return new;

err1:
	FREE(new);
err0:
	return NULL;
}

int
cmp_ntfs_locations(const struct ntfs_location *loc1,
		   const struct ntfs_location *loc2)
{
	return cmp_u64(loc1->sort_key, loc2->sort_key);
}

/* Read rptag and rpreserved from the NTFS inode and save them in the WIM inode.
 */
static int
read_reparse_header(ntfs_inode *ni, struct wim_inode *inode)
{
	struct {
		le32 rptag;
		le16 rpdatalen;
		le16 rpreserved;
	} hdr;
	s64 res;
	ntfs_attr *na;

	na = ntfs_attr_open(ni, AT_REPARSE_POINT, AT_UNNAMED, 0);
	if (!na)
		return WIMLIB_ERR_NTFS_3G;

	res = ntfs_attr_pread(na, 0, sizeof(hdr), &hdr);

	ntfs_attr_close(na);

	if (res != sizeof(hdr))
		return WIMLIB_ERR_NTFS_3G;

	inode->i_reparse_tag = le32_to_cpu(hdr.rptag);
	inode->i_rp_reserved = le16_to_cpu(hdr.rpreserved);
	return 0;
}


static void
warn_special_reparse_points(const struct wim_inode *inode,
			    const struct scan_params *params,
			    struct ntfs_volume_wrapper *volume)
{
	if (inode->i_reparse_tag == WIM_IO_REPARSE_TAG_DEDUP &&
	    (params->add_flags & WIMLIB_ADD_FLAG_WINCONFIG) &&
	    !volume->dedup_warned)
	{
		WARNING(
	  "Filesystem includes files deduplicated with Windows'\n"
"          Data Deduplication feature, which to properly restore\n"
"          would require that the chunk store in \"System Volume Information\"\n"
"          be included in the WIM image. By default \"System Volume Information\"\n"
"          is excluded, so you may want to use a custom capture configuration\n"
"          file which includes it.");
		volume->dedup_warned = true;
	}
}

static int
attr_type_to_wimlib_stream_type(ATTR_TYPES type)
{
	switch (type) {
	case AT_DATA:
		return STREAM_TYPE_DATA;
	case AT_REPARSE_POINT:
		return STREAM_TYPE_REPARSE_POINT;
	default:
		wimlib_assert(0);
		return STREAM_TYPE_UNKNOWN;
	}
}

/* When sorting blobs located in NTFS volumes for sequential reading, we sort
 * first by starting LCN of the attribute if available, otherwise no sort order
 * is defined.  This usually results in better sequential access to the volume.
 */
static int
set_attr_sort_key(ntfs_inode *ni, struct ntfs_location *loc)
{
	ntfs_attr *na;
	runlist_element *rl;

	na = open_ntfs_attr(ni, loc);
	if (!na)
		return WIMLIB_ERR_NTFS_3G;

	rl = ntfs_attr_find_vcn(na, 0);
	if (rl && rl->lcn != LCN_HOLE)
		loc->sort_key = rl->lcn;
	else
		loc->sort_key = 0;

	ntfs_attr_close(na);
	return 0;
}

/*
 * Add a new stream to the specified inode, with duplicate checking.
 *
 * This works around a problem where NTFS-3G can list multiple unnamed data
 * streams for a single file.  In this case we can only keep one.  We'll prefer
 * one that is nonempty.
 */
static int
add_stream(struct wim_inode *inode, const char *path, int stream_type,
	   const utf16lechar *stream_name, struct blob_descriptor **blob_p,
	   struct list_head *unhashed_blobs)
{
	struct blob_descriptor *blob = *blob_p;
	struct wim_inode_stream *strm;

	strm = inode_get_stream(inode, stream_type, stream_name);
	if (unlikely(strm)) {
		/* Stream already existed.  */
		if (!blob)
			return 0;
		if (stream_blob_resolved(strm)) {
			WARNING("\"%s\" has multiple nonempty streams "
				"with the same type and name!  Only the first "
				"will be saved.", path);
			return 0;
		}
		inode_replace_stream_blob(inode, strm, blob, NULL);
	} else {
		strm = inode_add_stream(inode, stream_type, stream_name, blob);
		if (unlikely(!strm))
			return WIMLIB_ERR_NOMEM;
	}
	prepare_unhashed_blob(blob, inode, strm->stream_id, unhashed_blobs);
	*blob_p = NULL;
	return 0;

}

/* Save information about an NTFS attribute (stream) to a WIM inode.  */
static int
scan_ntfs_attr(struct wim_inode *inode,
	       ntfs_inode *ni,
	       const char *path,
	       struct list_head *unhashed_blobs,
	       struct ntfs_volume_wrapper *volume,
	       ATTR_TYPES type,
	       const ATTR_RECORD *record)
{
	u64 data_size = ntfs_get_attribute_value_length(record);
	const u32 name_nchars = record->name_length;
	struct blob_descriptor *blob = NULL;
	utf16lechar *stream_name = (utf16lechar *)NO_STREAM_NAME;
	int ret;

	if (unlikely(name_nchars)) {
		/* Named stream  */
		stream_name = utf16le_dupz(attr_record_name(record),
					   name_nchars * sizeof(ntfschar));
		if (!stream_name) {
			ret = WIMLIB_ERR_NOMEM;
			goto out_cleanup;
		}
	}

	if (unlikely(type == AT_REPARSE_POINT)) {
		if (data_size < REPARSE_DATA_OFFSET) {
			ERROR("Reparse point attribute of \"%s\" "
			      "is too short!", path);
			ret = WIMLIB_ERR_INVALID_REPARSE_DATA;
			goto out_cleanup;
		}
		data_size -= REPARSE_DATA_OFFSET;

		ret = read_reparse_header(ni, inode);
		if (ret) {
			ERROR_WITH_ERRNO("Error reading reparse point header "
					 "of \"%s\"", path);
			goto out_cleanup;
		}
	}

	/* If the stream is non-empty, set up a blob descriptor for it.  */
	if (data_size != 0) {
		blob = new_blob_descriptor();
		if (unlikely(!blob)) {
			ret = WIMLIB_ERR_NOMEM;
			goto out_cleanup;
		}

		blob->ntfs_loc = MALLOC(sizeof(struct ntfs_location));
		if (unlikely(!blob->ntfs_loc)) {
			ret = WIMLIB_ERR_NOMEM;
			goto out_cleanup;
		}

		blob->blob_location = BLOB_IN_NTFS_VOLUME;
		blob->size = data_size;
		blob->ntfs_loc->volume = get_ntfs_volume(volume);
		blob->ntfs_loc->mft_no = ni->mft_no;
		blob->ntfs_loc->attr_type = type;

		if (unlikely(name_nchars)) {
			blob->ntfs_loc->attr_name_nchars = name_nchars;
			blob->ntfs_loc->attr_name = utf16le_dup(stream_name);
			if (!blob->ntfs_loc->attr_name) {
				ret = WIMLIB_ERR_NOMEM;
				goto out_cleanup;
			}
		} else {
			blob->ntfs_loc->attr_name_nchars = 0;
			blob->ntfs_loc->attr_name = AT_UNNAMED;
		}

		ret = set_attr_sort_key(ni, blob->ntfs_loc);
		if (ret)
			goto out_cleanup;
	}

	ret = add_stream(inode, path, attr_type_to_wimlib_stream_type(type),
			 stream_name, &blob, unhashed_blobs);
out_cleanup:
	free_blob_descriptor(blob);
	if (stream_name != NO_STREAM_NAME)
		FREE(stream_name);
	return ret;
}

/* Scan attributes of the specified type from a file in the NTFS volume  */
static int
scan_ntfs_attrs_with_type(struct wim_inode *inode,
			  ntfs_inode *ni,
			  const char *path,
			  struct list_head *unhashed_blobs,
			  struct ntfs_volume_wrapper *volume,
			  ATTR_TYPES type)
{
	ntfs_attr_search_ctx *actx;
	int ret;

	actx = ntfs_attr_get_search_ctx(ni, NULL);
	if (!actx) {
		ERROR_WITH_ERRNO("Failed to get NTFS attribute search "
				 "context for \"%s\"", path);
		return WIMLIB_ERR_NTFS_3G;
	}

	while (!ntfs_attr_lookup(type, NULL, 0,
				 CASE_SENSITIVE, 0, NULL, 0, actx))
	{
		ret = scan_ntfs_attr(inode,
				     ni,
				     path,
				     unhashed_blobs,
				     volume,
				     type,
				     actx->attr);
		if (ret)
			goto out_put_actx;
	}
	if (errno != ENOENT) {
		ERROR_WITH_ERRNO("Error listing NTFS attributes of \"%s\"", path);
		ret = WIMLIB_ERR_NTFS_3G;
		goto out_put_actx;
	}
	ret = 0;
out_put_actx:
	ntfs_attr_put_search_ctx(actx);
	return ret;
}

static noinline_for_stack int
load_object_id(ntfs_inode *ni, struct wim_inode *inode)
{
	OBJECT_ID_ATTR attr;
	int len;

	len = ntfs_get_ntfs_object_id(ni, (char *)&attr, sizeof(attr));
	if (likely(len == -ENODATA || len == 0))
		return 0;
	if (len < 0)
		return WIMLIB_ERR_NTFS_3G;
	if (!inode_set_object_id(inode, &attr, len))
		return WIMLIB_ERR_NOMEM;
	return 0;
}

/* Load the security descriptor of an NTFS inode into the corresponding WIM
 * inode and the WIM image's security descriptor set.  */
static noinline_for_stack int
get_security_descriptor(ntfs_inode *ni, struct wim_inode *inode,
			ntfs_volume *vol, struct wim_sd_set *sd_set)
{
	struct SECURITY_CONTEXT scx = {.vol = vol};
	char _buf[4096];
	char *buf = _buf;
	size_t avail_size = sizeof(_buf);
	int ret;

retry:
	ret = ntfs_get_ntfs_acl(&scx, ni, buf, avail_size);
	if (unlikely(ret < 0)) {
		ret = WIMLIB_ERR_NTFS_3G;
		goto out;
	}

	if (unlikely(ret > avail_size)) {
		if (unlikely(buf != _buf))
			FREE(buf);
		buf = MALLOC(ret);
		if (!buf) {
			ret = WIMLIB_ERR_NOMEM;
			goto out;
		}
		avail_size = ret;
		goto retry;
	}

	if (likely(ret > 0)) {
		inode->i_security_id = sd_set_add_sd(sd_set, buf, ret);
		if (unlikely(inode->i_security_id < 0)) {
			ret = WIMLIB_ERR_NOMEM;
			goto out;
		}
	}

	ret = 0;
out:
	if (unlikely(buf != _buf))
		FREE(buf);
	return ret;
}

/* Binary tree that maps NTFS inode numbers to DOS names */
struct dos_name_map {
	struct avl_tree_node *root;
};

struct dos_name_node {
	struct avl_tree_node index_node;
	char dos_name[24];
	int name_nbytes;
	u64 ntfs_ino;
};

#define DOS_NAME_NODE(avl_node) \
	avl_tree_entry(avl_node, struct dos_name_node, index_node)

static int
_avl_cmp_by_ntfs_ino(const struct avl_tree_node *n1,
		     const struct avl_tree_node *n2)
{
	return cmp_u64(DOS_NAME_NODE(n1)->ntfs_ino,
		       DOS_NAME_NODE(n2)->ntfs_ino);
}

/* Inserts a new DOS name into the map */
static int
insert_dos_name(struct dos_name_map *map, const ntfschar *dos_name,
		size_t name_nbytes, u64 ntfs_ino)
{
	struct dos_name_node *new_node;

	new_node = MALLOC(sizeof(struct dos_name_node));
	if (!new_node)
		return WIMLIB_ERR_NOMEM;

	/* DOS names are supposed to be 12 characters max (that's 24 bytes,
	 * assuming 2-byte ntfs characters) */
	wimlib_assert(name_nbytes <= sizeof(new_node->dos_name));

	/* Initialize the DOS name, DOS name length, and NTFS inode number of
	 * the search tree node */
	memcpy(new_node->dos_name, dos_name, name_nbytes);
	new_node->name_nbytes = name_nbytes;
	new_node->ntfs_ino = ntfs_ino;

	/* Insert the search tree node */
	if (avl_tree_insert(&map->root, &new_node->index_node,
			    _avl_cmp_by_ntfs_ino))
	{
		/* This should be impossible since an NTFS inode cannot have
		 * multiple DOS names, and we only should get each DOS name
		 * entry once from the ntfs_readdir() calls. */
		WARNING("NTFS inode %"PRIu64" has multiple DOS names", ntfs_ino);
		FREE(new_node);
	}
	return 0;
}

/* Returns a structure that contains the DOS name and its length for an NTFS
 * inode, or NULL if the inode has no DOS name. */
static struct dos_name_node *
lookup_dos_name(const struct dos_name_map *map, u64 ntfs_ino)
{
	struct dos_name_node dummy;
	struct avl_tree_node *res;

	dummy.ntfs_ino = ntfs_ino;

	res = avl_tree_lookup_node(map->root, &dummy.index_node,
				   _avl_cmp_by_ntfs_ino);
	if (!res)
		return NULL;
	return DOS_NAME_NODE(res);
}

static int
set_dentry_dos_name(struct wim_dentry *dentry, const struct dos_name_map *map)
{
	const struct dos_name_node *node;

	if (dentry->d_is_win32_name) {
		node = lookup_dos_name(map, dentry->d_inode->i_ino);
		if (node) {
			dentry->d_short_name = utf16le_dupz(node->dos_name,
							    node->name_nbytes);
			if (!dentry->d_short_name)
				return WIMLIB_ERR_NOMEM;
			dentry->d_short_name_nbytes = node->name_nbytes;
		} else {
			WARNING("NTFS inode %"PRIu64" has Win32 name with no "
				"corresponding DOS name",
				dentry->d_inode->i_ino);
		}
	}
	return 0;
}

static void
destroy_dos_name_map(struct dos_name_map *map)
{
	struct dos_name_node *node;
	avl_tree_for_each_in_postorder(node, map->root,
				       struct dos_name_node, index_node)
		FREE(node);
}

struct readdir_ctx {
	struct wim_dentry *parent;
	struct dos_name_map dos_name_map;
	struct ntfs_volume_wrapper *volume;
	struct scan_params *params;
	int ret;
};

static int
ntfs_3g_build_dentry_tree_recursive(struct wim_dentry **root_p,
				    const MFT_REF mref,
				    const char *filename,
				    int name_type,
				    struct ntfs_volume_wrapper *volume,
				    struct scan_params *params);

static int
filldir(void *_ctx, const ntfschar *name, const int name_nchars,
	const int name_type, const s64 pos, const MFT_REF mref,
	const unsigned dt_type)
{
	struct readdir_ctx *ctx = _ctx;
	struct scan_params *params = ctx->params;
	const size_t name_nbytes = name_nchars * sizeof(ntfschar);
	char *mbs_name;
	size_t mbs_name_nbytes;
	size_t orig_path_nchars;
	struct wim_dentry *child;
	int ret;

	if (name_type & FILE_NAME_DOS) {
		/* If this is the entry for a DOS name, store it for later. */
		ret = insert_dos_name(&ctx->dos_name_map, name,
				      name_nbytes, MREF(mref));

		/* Return now if an error occurred or if this is just a DOS name
		 * and not a Win32+DOS name. */
		if (ret != 0 || name_type == FILE_NAME_DOS)
			goto out;
	}

	ret = utf16le_to_tstr(name, name_nbytes, &mbs_name, &mbs_name_nbytes);
	if (ret)
		goto out;

	if (should_ignore_filename(mbs_name, mbs_name_nbytes))
		goto out_free_mbs_name;

	ret = WIMLIB_ERR_NOMEM;
	if (!pathbuf_append_name(params, mbs_name, mbs_name_nbytes,
				 &orig_path_nchars))
		goto out_free_mbs_name;

	child = NULL;
	ret = ntfs_3g_build_dentry_tree_recursive(&child, mref, mbs_name,
						  name_type, ctx->volume,
						  params);
	pathbuf_truncate(params, orig_path_nchars);
	attach_scanned_tree(ctx->parent, child, params->blob_table);
out_free_mbs_name:
	FREE(mbs_name);
out:
	ctx->ret = ret;
	return ret;
}

static int
ntfs_3g_recurse_directory(ntfs_inode *ni, struct wim_dentry *parent,
			  struct ntfs_volume_wrapper *volume,
			  struct scan_params *params)
{
	int ret;
	s64 pos = 0;
	struct readdir_ctx ctx = {
		.parent          = parent,
		.dos_name_map    = { .root = NULL },
		.volume          = volume,
		.params          = params,
		.ret		 = 0,
	};
	ret = ntfs_readdir(ni, &pos, &ctx, filldir);
	if (unlikely(ret)) {
		if (ctx.ret) {
			/* wimlib error  */
			ret = ctx.ret;
		} else {
			/* error from ntfs_readdir() itself  */
			ERROR_WITH_ERRNO("Error reading directory \"%s\"",
					 params->cur_path);
			ret = WIMLIB_ERR_NTFS_3G;
		}
	} else {
		struct wim_dentry *child;

		ret = 0;
		for_dentry_child(child, parent) {
			ret = set_dentry_dos_name(child, &ctx.dos_name_map);
			if (ret)
				break;
		}
	}
	destroy_dos_name_map(&ctx.dos_name_map);
	return ret;
}

static int
ntfs_3g_build_dentry_tree_recursive(struct wim_dentry **root_ret,
				    const MFT_REF mref,
				    const char *filename,
				    int name_type,
				    struct ntfs_volume_wrapper *volume,
				    struct scan_params *params)
{
	const char *path = params->cur_path;
	u32 attributes;
	int ret;
	struct wim_dentry *root = NULL;
	struct wim_inode *inode = NULL;
	ntfs_inode *ni = NULL;

	ret = try_exclude(params);
	if (unlikely(ret < 0)) /* Excluded? */
		goto out_progress;
	if (unlikely(ret > 0)) /* Error? */
		goto out;

	ni = ntfs_inode_open(volume->vol, mref);
	if (!ni) {
		ERROR_WITH_ERRNO("Failed to open NTFS file \"%s\"", path);
		ret = WIMLIB_ERR_NTFS_3G;
		goto out;
	}

	/* Get file attributes */
	ret = ntfs_get_ntfs_attrib(ni, (char*)&attributes, sizeof(attributes));
	if (ret != sizeof(attributes)) {
		ERROR_WITH_ERRNO("Failed to get NTFS attributes from \"%s\"", path);
		ret = WIMLIB_ERR_NTFS_3G;
		goto out;
	}

	if (unlikely(attributes & FILE_ATTRIBUTE_ENCRYPTED)) {
		if (params->add_flags & WIMLIB_ADD_FLAG_NO_UNSUPPORTED_EXCLUDE)
		{
			ERROR("Can't archive \"%s\" because NTFS-3G capture mode "
			      "does not support encrypted files and directories", path);
			ret = WIMLIB_ERR_UNSUPPORTED_FILE;
			goto out;
		}
		ret = do_scan_progress(params, WIMLIB_SCAN_DENTRY_UNSUPPORTED, NULL);
		goto out;
	}

	/* Create a WIM dentry with an associated inode, which may be shared */
	ret = inode_table_new_dentry(params->inode_table, filename,
				     ni->mft_no, 0, false, &root);
	if (ret)
		goto out;

	if (name_type & FILE_NAME_WIN32) /* Win32 or Win32+DOS name (rather than POSIX) */
		root->d_is_win32_name = 1;

	inode = root->d_inode;

	if (inode->i_nlink > 1) {
		/* Shared inode; nothing more to do */
		goto out_progress;
	}

	inode->i_creation_time    = le64_to_cpu(ni->creation_time);
	inode->i_last_write_time  = le64_to_cpu(ni->last_data_change_time);
	inode->i_last_access_time = le64_to_cpu(ni->last_access_time);
	inode->i_attributes       = attributes;

	if (attributes & FILE_ATTRIBUTE_REPARSE_POINT) {
		/* Scan the reparse point stream.  */
		ret = scan_ntfs_attrs_with_type(inode, ni, path,
						params->unhashed_blobs,
						volume, AT_REPARSE_POINT);
		if (ret)
			goto out;

		warn_special_reparse_points(inode, params, volume);
	}

	/* Load the object ID.  */
	ret = load_object_id(ni, inode);
	if (ret) {
		ERROR_WITH_ERRNO("Error reading object ID of \"%s\"", path);
		goto out;
	}

	/* Scan the data streams.
	 *
	 * Note: directories should not have an unnamed data stream, but they
	 * may have named data streams.  Nondirectories (including reparse
	 * points) can have an unnamed data stream as well as named data
	 * streams.  */
	ret = scan_ntfs_attrs_with_type(inode, ni, path, params->unhashed_blobs,
					volume, AT_DATA);
	if (ret)
		goto out;

	/* Reparse-point fixups are a no-op because in NTFS-3G capture mode we
	 * only allow capturing an entire volume. */
	if (params->add_flags & WIMLIB_ADD_FLAG_RPFIX &&
	    inode_is_symlink(inode))
		inode->i_rp_flags &= ~WIM_RP_FLAG_NOT_FIXED;

	if (!(params->add_flags & WIMLIB_ADD_FLAG_NO_ACLS)) {
		ret = get_security_descriptor(ni, inode, volume->vol,
					      params->sd_set);
		if (ret) {
			ERROR_WITH_ERRNO("Error reading security descriptor "
					 "of \"%s\"", path);
			goto out;
		}
	}

	if (inode_is_directory(inode)) {
		ret = ntfs_3g_recurse_directory(ni, root, volume, params);
		if (ret)
			goto out;
	}

out_progress:
	if (root == NULL)
		ret = do_scan_progress(params, WIMLIB_SCAN_DENTRY_EXCLUDED, NULL);
	else
		ret = do_scan_progress(params, WIMLIB_SCAN_DENTRY_OK, inode);
out:
	if (ni)
		ntfs_inode_close(ni);
	if (unlikely(ret)) {
		free_dentry_tree(root, params->blob_table);
		root = NULL;
		ret = report_scan_error(params, ret);
	}
	*root_ret = root;
	return ret;
}

int
ntfs_3g_build_dentry_tree(struct wim_dentry **root_ret,
			  const char *device, struct scan_params *params)
{
	struct ntfs_volume_wrapper *volume;
	ntfs_volume *vol;
	int ret;

	volume = CALLOC(1, sizeof(struct ntfs_volume_wrapper));
	if (!volume)
		return WIMLIB_ERR_NOMEM;

	vol = ntfs_mount(device, NTFS_MNT_RDONLY);
	if (!vol) {
		ERROR_WITH_ERRNO("Failed to mount NTFS volume \"%s\" read-only",
				 device);
		FREE(volume);
		return WIMLIB_ERR_NTFS_3G;
	}

	volume->vol = vol;
	volume->refcnt = 1;

	/* Currently, libntfs-3g users that need to read security descriptors
	 * are required to call ntfs_open_secure() to open the volume's security
	 * descriptor index, "$Secure".  This is only required to work on NTFS
	 * v3.0+, as older versions did not have a security descriptor index. */
	if (ntfs_open_secure(vol) && vol->major_ver >= 3) {
		ERROR_WITH_ERRNO("Unable to open security descriptor index of "
				 "NTFS volume \"%s\"", device);
		ret = WIMLIB_ERR_NTFS_3G;
		goto out_put_ntfs_volume;
	}

	/* We don't want to capture the special NTFS files such as $Bitmap.  Not
	 * to be confused with "hidden" or "system" files which are real files
	 * that we do need to capture.  */
	NVolClearShowSysFiles(vol);

	ret = pathbuf_init(params, "/");
	if (ret)
		goto out_close_secure;

	ret = ntfs_3g_build_dentry_tree_recursive(root_ret, FILE_root, "",
						  FILE_NAME_POSIX, volume,
						  params);
out_close_secure:
	/* Undo the effects of ntfs_open_secure().  This is not yet done
	 * automatically by ntfs_umount().  But NULL out the inode to
	 * potentially be robust against future versions doing so. */
	if (vol->secure_ni) {
		ntfs_index_ctx_put(vol->secure_xsii);
		ntfs_index_ctx_put(vol->secure_xsdh);
		ntfs_inode_close(vol->secure_ni);
		vol->secure_ni = NULL;
	}
out_put_ntfs_volume:
	put_ntfs_volume(volume);
	return ret;
}
#endif /* WITH_NTFS_3G */
