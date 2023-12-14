#ifndef _WIMLIB_XML_H
#define _WIMLIB_XML_H

#include "types.h"

/*****************************************************************************/

struct wim_xml_info;

extern struct wim_xml_info *
xml_new_info_struct(void);

extern void
xml_free_info_struct(struct wim_xml_info *info);

/*****************************************************************************/

extern int
xml_get_image_count(const struct wim_xml_info *info);

extern u64
xml_get_total_bytes(const struct wim_xml_info *info);

extern u64
xml_get_image_total_bytes(const struct wim_xml_info *info, int image);

extern u64
xml_get_image_hard_link_bytes(const struct wim_xml_info *info, int image);

extern bool
xml_get_wimboot(const struct wim_xml_info *info, int image);

extern u64
xml_get_windows_build_number(const struct wim_xml_info *info, int image);

extern int
xml_set_wimboot(struct wim_xml_info *info, int image);

/*****************************************************************************/

extern int
xml_update_image_info(WIMStruct *wim, int image);

extern int
xml_add_image(struct wim_xml_info *info, const tchar *name);

extern int
xml_export_image(const struct wim_xml_info *src_info, int src_image,
		 struct wim_xml_info *dest_info, const tchar *dest_image_name,
		 const tchar *dest_image_description, bool wimboot);

extern void
xml_delete_image(struct wim_xml_info *info, int image);


extern void
xml_print_image_info(struct wim_xml_info *info, int image);

/*****************************************************************************/

struct wim_reshdr;

#define WIM_TOTALBYTES_USE_EXISTING  ((u64)(-1))
#define WIM_TOTALBYTES_OMIT          ((u64)(-2))

extern int
read_wim_xml_data(WIMStruct *wim);

extern int
write_wim_xml_data(WIMStruct *wim, int image,
		   u64 total_bytes, struct wim_reshdr *out_reshdr,
		   int write_resource_flags);

/*****************************************************************************/

extern void
xml_global_init(void);

extern void
xml_global_cleanup(void);

extern void
xml_set_memory_allocator(void *(*malloc_func)(size_t),
			 void (*free_func)(void *),
			 void *(*realloc_func)(void *, size_t));

#endif /* _WIMLIB_XML_H */
