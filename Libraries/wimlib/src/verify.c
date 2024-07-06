/*
 * verify.c
 *
 * Verify WIM files.
 */

/*
 * Copyright (C) 2012, 2013, 2014 Eric Biggers
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

#include "wimlib/blob_table.h"
#include "wimlib/dentry.h"
#include "wimlib/error.h"
#include "wimlib/metadata.h"
#include "wimlib/progress.h"
#include "wimlib/security.h"

static int
append_blob_to_list(struct blob_descriptor *blob, void *_list)
{
	list_add(&blob->extraction_list, (struct list_head *)_list);
	return 0;
}

struct verify_blob_list_ctx {
	wimlib_progress_func_t progfunc;
	void *progctx;
	union wimlib_progress_info *progress;
	u64 next_progress;
};

static int
verify_continue_blob(const struct blob_descriptor *blob, u64 offset,
		     const void *chunk, size_t size, void *_ctx)
{
	struct verify_blob_list_ctx *ctx = _ctx;
	union wimlib_progress_info *progress = ctx->progress;

	if (offset + size == blob->size)
		progress->verify_streams.completed_streams++;

	progress->verify_streams.completed_bytes += size;

	if (progress->verify_streams.completed_bytes >= ctx->next_progress) {

		int ret = call_progress(ctx->progfunc,
					WIMLIB_PROGRESS_MSG_VERIFY_STREAMS,
					progress, ctx->progctx);
		if (ret)
			return ret;

		set_next_progress(progress->verify_streams.completed_bytes,
				  progress->verify_streams.total_bytes,
				  &ctx->next_progress);
	}
	return 0;
}

static int
verify_file_data_present(struct wim_image_metadata *imd,
			 struct blob_table *blob_table)
{
	struct wim_inode *inode;
	int ret;

	image_for_each_inode(inode, imd) {
		ret = inode_resolve_streams(inode, blob_table, false);
		if (ret)
			return ret;
	}
	return 0;
}

/* API function documented in wimlib.h  */
WIMLIBAPI int
wimlib_verify_wim(WIMStruct *wim, int verify_flags)
{
	int ret;
	LIST_HEAD(blob_list);
	union wimlib_progress_info progress;
	struct verify_blob_list_ctx ctx;
	struct blob_descriptor *blob;
	struct read_blob_callbacks cbs = {
		.continue_blob	= verify_continue_blob,
		.ctx		= &ctx,
	};

	/* Check parameters  */

	if (!wim)
		return WIMLIB_ERR_INVALID_PARAM;

	if (verify_flags)
		return WIMLIB_ERR_INVALID_PARAM;

	/* Verify the images  */

	if (wim_has_metadata(wim)) {

		memset(&progress, 0, sizeof(progress));
		progress.verify_image.wimfile = wim->filename;
		progress.verify_image.total_images = wim->hdr.image_count;

		for (int i = 1; i <= wim->hdr.image_count; i++) {

			progress.verify_image.current_image = i;

			ret = call_progress(wim->progfunc, WIMLIB_PROGRESS_MSG_BEGIN_VERIFY_IMAGE,
					    &progress, wim->progctx);
			if (ret)
				return ret;

			ret = select_wim_image(wim, i);
			if (ret)
				return ret;

			ret = verify_file_data_present(wim_get_current_image_metadata(wim),
						       wim->blob_table);
			if (ret)
				return ret;

			ret = call_progress(wim->progfunc, WIMLIB_PROGRESS_MSG_END_VERIFY_IMAGE,
					    &progress, wim->progctx);
			if (ret)
				return ret;
		}
	} else {
		WARNING("\"%"TS"\" does not contain image metadata.  Skipping image verification.",
			wim->filename);
	}

	/* Verify the blobs: SHA-1 message digests must match  */

	for_blob_in_table(wim->blob_table, append_blob_to_list, &blob_list);

	memset(&progress, 0, sizeof(progress));

	progress.verify_streams.wimfile = wim->filename;
	list_for_each_entry(blob, &blob_list, extraction_list) {
		progress.verify_streams.total_streams++;
		progress.verify_streams.total_bytes += blob->size;
	}

	ctx.progfunc = wim->progfunc;
	ctx.progctx = wim->progctx;
	ctx.progress = &progress;
	ctx.next_progress = 0;

	ret = call_progress(ctx.progfunc, WIMLIB_PROGRESS_MSG_VERIFY_STREAMS,
			    ctx.progress, ctx.progctx);
	if (ret)
		return ret;

	return read_blob_list(&blob_list,
			      offsetof(struct blob_descriptor, extraction_list),
			      &cbs, VERIFY_BLOB_HASHES);
}
