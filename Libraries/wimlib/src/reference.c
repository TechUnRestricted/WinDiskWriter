/*
 * reference.c
 *
 * Reference blobs from external WIM file(s).
 */

/*
 * Copyright (C) 2013, 2014, 2015 Eric Biggers
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
#include "wimlib/blob_table.h"
#include "wimlib/error.h"
#include "wimlib/glob.h"
#include "wimlib/wim.h"

#define WIMLIB_REF_MASK_PUBLIC (WIMLIB_REF_FLAG_GLOB_ENABLE | \
				WIMLIB_REF_FLAG_GLOB_ERR_ON_NOMATCH)

struct reference_info {
	WIMStruct *dest_wim;
	struct list_head new_blobs;
	int ref_flags;
	struct blob_table *src_table;
};

static void
init_reference_info(struct reference_info *info, WIMStruct *dest_wim,
		    int ref_flags)
{
	info->dest_wim = dest_wim;
	INIT_LIST_HEAD(&info->new_blobs);
	info->ref_flags = ref_flags;
}

static void
rollback_reference_info(struct reference_info *info)
{
	struct blob_descriptor *blob;

	while (!list_empty(&info->new_blobs)) {
		blob = list_first_entry(&info->new_blobs,
					struct blob_descriptor, blob_table_list);
		list_del(&blob->blob_table_list);
		blob_table_unlink(info->dest_wim->blob_table, blob);
		free_blob_descriptor(blob);
	}
}

static bool
need_blob(const struct reference_info *info, const struct blob_descriptor *blob)
{
	return !lookup_blob(info->dest_wim->blob_table, blob->hash);
}

static void
reference_blob(struct reference_info *info, struct blob_descriptor *blob)
{
	blob_table_insert(info->dest_wim->blob_table, blob);
	list_add(&blob->blob_table_list, &info->new_blobs);
}

static int
blob_clone_if_new(struct blob_descriptor *blob, void *_info)
{
	struct reference_info *info = _info;

	if (need_blob(info, blob)) {
		blob = clone_blob_descriptor(blob);
		if (unlikely(!blob))
			return WIMLIB_ERR_NOMEM;
		reference_blob(info, blob);
	}
	return 0;
}

/* API function documented in wimlib.h  */
WIMLIBAPI int
wimlib_reference_resources(WIMStruct *wim, WIMStruct **resource_wims,
			   unsigned num_resource_wims, int ref_flags)
{
	unsigned i;
	struct reference_info info;
	int ret = 0;

	if (wim == NULL)
		return WIMLIB_ERR_INVALID_PARAM;

	if (num_resource_wims != 0 && resource_wims == NULL)
		return WIMLIB_ERR_INVALID_PARAM;

	if (ref_flags & ~WIMLIB_REF_MASK_PUBLIC)
		return WIMLIB_ERR_INVALID_PARAM;

	for (i = 0; i < num_resource_wims; i++)
		if (resource_wims[i] == NULL)
			return WIMLIB_ERR_INVALID_PARAM;

	init_reference_info(&info, wim, ref_flags);

	for (i = 0; i < num_resource_wims; i++) {
		ret = for_blob_in_table(resource_wims[i]->blob_table,
					blob_clone_if_new, &info);
		if (ret)
			break;
	}

	if (unlikely(ret))
		rollback_reference_info(&info);
	return ret;
}

static int
blob_gift(struct blob_descriptor *blob, void *_info)
{
	struct reference_info *info = _info;

	blob_table_unlink(info->src_table, blob);
	if (need_blob(info, blob))
		reference_blob(info, blob);
	else
		free_blob_descriptor(blob);
	return 0;
}

static int
reference_resource_path(struct reference_info *info, const tchar *path,
			int open_flags)
{
	int ret;
	WIMStruct *src_wim;

	ret = wimlib_open_wim_with_progress(path, open_flags, &src_wim,
					    info->dest_wim->progfunc,
					    info->dest_wim->progctx);
	if (ret)
		return ret;

	info->src_table = src_wim->blob_table;
	for_blob_in_table(src_wim->blob_table, blob_gift, info);
	wimlib_free(src_wim);
	return 0;
}

static int
reference_resource_paths(struct reference_info *info,
			 const tchar * const *paths, unsigned num_paths,
			 int open_flags)
{
	for (unsigned i = 0; i < num_paths; i++) {
		int ret = reference_resource_path(info, paths[i], open_flags);
		if (ret)
			return ret;
	}
	return 0;
}

static int
reference_resource_glob(struct reference_info *info,
			const tchar *refglob, int open_flags)
{
	int ret;
	glob_t globbuf;

	/* Note: glob() is replaced in Windows native builds.  */
	ret = tglob(refglob, GLOB_ERR | GLOB_NOSORT, NULL, &globbuf);
	if (unlikely(ret)) {
		if (ret == GLOB_NOMATCH) {
			if (info->ref_flags &
			    WIMLIB_REF_FLAG_GLOB_ERR_ON_NOMATCH)
			{
				ERROR("Found no files for glob \"%"TS"\"", refglob);
				return WIMLIB_ERR_GLOB_HAD_NO_MATCHES;
			}
			return reference_resource_path(info,
						       refglob,
						       open_flags);
		}
		ERROR_WITH_ERRNO("Failed to process glob \"%"TS"\"", refglob);
		if (ret == GLOB_NOSPACE)
			return WIMLIB_ERR_NOMEM;
		return WIMLIB_ERR_READ;
	}

	ret = reference_resource_paths(info,
				       (const tchar * const *)globbuf.gl_pathv,
				       globbuf.gl_pathc,
				       open_flags);
	globfree(&globbuf);
	return ret;
}

static int
reference_resource_globs(struct reference_info *info,
			 const tchar * const *globs, unsigned num_globs,
			 int open_flags)
{
	for (unsigned i = 0; i < num_globs; i++) {
		int ret = reference_resource_glob(info, globs[i], open_flags);
		if (ret)
			return ret;
	}
	return 0;
}

/* API function documented in wimlib.h  */
WIMLIBAPI int
wimlib_reference_resource_files(WIMStruct *wim,
				const tchar * const *paths_or_globs,
				unsigned count, int ref_flags, int open_flags)
{
	struct reference_info info;
	int ret;

	if (ref_flags & ~WIMLIB_REF_MASK_PUBLIC)
		return WIMLIB_ERR_INVALID_PARAM;

	init_reference_info(&info, wim, ref_flags);

	if (ref_flags & WIMLIB_REF_FLAG_GLOB_ENABLE)
		ret = reference_resource_globs(&info, paths_or_globs, count, open_flags);
	else
		ret = reference_resource_paths(&info, paths_or_globs, count, open_flags);

	if (unlikely(ret))
		rollback_reference_info(&info);
	return ret;
}
