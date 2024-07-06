/*
 * join.c
 *
 * Join split WIMs (sometimes named as .swm files) together into one WIM.
 */

/*
 * Copyright (C) 2012-2016 Eric Biggers
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

#include <stdlib.h>

#include "wimlib.h"
#include "wimlib/error.h"
#include "wimlib/types.h"
#include "wimlib/util.h"
#include "wimlib/wim.h"

/*
 * Verify that a list of WIM files sorted by part number is a spanned set.
 *
 * Return: 0 on success; WIMLIB_ERR_SPLIT_INVALID if the set is not valid.
 */
static int
verify_swm_set(WIMStruct * const *swms, unsigned num_swms)
{
	for (unsigned i = 0; i < num_swms; i++) {
		if (!guids_equal(swms[i]->hdr.guid, swms[0]->hdr.guid)) {
			ERROR("The split WIM parts specified belong to "
			      "different split WIMs!");
			return WIMLIB_ERR_SPLIT_INVALID;
		}
		if (swms[i]->hdr.total_parts != num_swms) {
			ERROR("\"%"TS"\" says there are %u parts in the split "
			      "WIM, but %s%u part%s provided",
			      swms[i]->filename, swms[i]->hdr.total_parts,
			      num_swms < swms[i]->hdr.total_parts ? "only ":"",
			      num_swms, num_swms > 1 ? "s were" : " was");
			return WIMLIB_ERR_SPLIT_INVALID;
		}
		if (swms[i]->hdr.part_number != i + 1) {
			ERROR("The parts of the split WIM are not numbered "
			      "1..%u as expected.  Did you specify duplicate "
			      "parts?", num_swms);
			return WIMLIB_ERR_SPLIT_INVALID;
		}
	}
	return 0;
}

static int
cmp_swms_by_part_number(const void *p1, const void *p2)
{
	WIMStruct *swm1 = *(WIMStruct **)p1;
	WIMStruct *swm2 = *(WIMStruct **)p2;

	return (int)swm1->hdr.part_number - (int)swm2->hdr.part_number;
}

WIMLIBAPI int
wimlib_join_with_progress(const tchar * const *swm_names,
			  unsigned num_swms,
			  const tchar *output_path,
			  int swm_open_flags,
			  int wim_write_flags,
			  wimlib_progress_func_t progfunc,
			  void *progctx)
{
	WIMStruct **swms;
	unsigned i;
	int ret;

	if (num_swms < 1 || num_swms > 0xffff)
		return WIMLIB_ERR_INVALID_PARAM;

	swms = CALLOC(num_swms, sizeof(swms[0]));
	if (!swms)
		return WIMLIB_ERR_NOMEM;

	for (i = 0; i < num_swms; i++) {
		ret = wimlib_open_wim_with_progress(swm_names[i],
						    swm_open_flags,
						    &swms[i],
						    progfunc,
						    progctx);
		if (ret)
			goto out;
	}

	qsort(swms, num_swms, sizeof(swms[0]), cmp_swms_by_part_number);

	ret = verify_swm_set(swms, num_swms);
	if (ret)
		goto out;

	ret = wimlib_reference_resources(swms[0], swms + 1, num_swms - 1, 0);
	if (ret)
		goto out;

	/* It is reasonably safe to provide WIMLIB_WRITE_FLAG_STREAMS_OK, as we
	 * have verified that the specified split WIM parts form a spanned set.
	 */
	ret = wimlib_write(swms[0], output_path, WIMLIB_ALL_IMAGES,
			   wim_write_flags |
				WIMLIB_WRITE_FLAG_STREAMS_OK |
				WIMLIB_WRITE_FLAG_RETAIN_GUID,
			   1);
out:
	for (i = 0; i < num_swms; i++)
		wimlib_free(swms[i]);
	FREE(swms);
	return ret;
}

/* API function documented in wimlib.h  */
WIMLIBAPI int
wimlib_join(const tchar * const *swm_names,
	    unsigned num_swms,
	    const tchar *output_path,
	    int swm_open_flags,
	    int wim_write_flags)
{
	return wimlib_join_with_progress(swm_names, num_swms, output_path,
					 swm_open_flags, wim_write_flags,
					 NULL, NULL);
}
