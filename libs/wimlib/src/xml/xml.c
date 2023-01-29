/*
 * xml.c
 *
 * Deals with the XML information in WIM files.  Uses the C library libxml2.
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
 * along with this file; if not, see http://www.gnu.org/licenses/.
 */

#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif

#include <libxml/parser.h>
#include <libxml/tree.h>
#include <libxml/xmlsave.h>
#include <string.h>

#include "blob_table.h"
#include "dentry.h"
#include "encoding.h"
#include "error.h"
#include "file_io.h"
#include "metadata.h"
#include "resource.h"
#include "timestamp.h"
#include "xml.h"
#include "write.h"

/*
 * A wrapper around a WIM file's XML document.  The XML document contains
 * metadata about each image in the WIM file as well as metadata about the WIM
 * file itself.
 */
struct wim_xml_info {

	/* The parsed XML document as a libxml2 document tree  */
	xmlDocPtr doc;

	/* The root element of the document.  This is a cached value, equal to
	 * xmlDocGetRootElement(doc).  */
	xmlNode *root;

	/* A malloc()ed array containing a pointer to the IMAGE element for each
	 * WIM image.  The image with 1-based index 'i' is at index 'i - 1' in
	 * this array.  Note: these pointers are cached values, since they could
	 * also be found by searching the document.  */
	xmlNode **images;

	/* The number of WIM images (the length of 'images')  */
	int image_count;

#if TCHAR_IS_UTF16LE
	/* Temporary memory for UTF-8 => 'tchar' string translations.  When an
	 * API function needs to return a 'tchar' string, it uses one of these
	 * array slots to hold the string and returns a pointer to it.  */
	tchar *strings[128];
	size_t next_string_idx;
	size_t num_strings;
#endif
};

/*----------------------------------------------------------------------------*
 *                            Internal functions                              *
 *----------------------------------------------------------------------------*/

/* Iterate through the children of an xmlNode.  */
#define node_for_each_child(parent, child)	\
	for (child = (parent)->children; child != NULL; child = child->next)

/* Is the specified node an element of the specified name?  */
static bool
node_is_element(const xmlNode *node, const xmlChar *name)
{
	return node->type == XML_ELEMENT_NODE && xmlStrEqual(node->name, name);
}

/* Retrieve a pointer to the UTF-8 text contents of the specified node, or NULL
 * if the node has no text contents.  This assumes the simple case where the
 * node has a single TEXT child node.  */
static const xmlChar *
node_get_text(const xmlNode *node)
{
	const xmlNode *child;

	if (!node)
		return NULL;
	node_for_each_child(node, child)
		if (child->type == XML_TEXT_NODE && child->content)
			return child->content;
	return NULL;
}

/* Retrieve an unsigned integer from the contents of the specified node,
 * decoding it using the specified base.  If the node has no contents or does
 * not contain a valid number, returns 0.  */
static u64
node_get_number(const xmlNode *node, int base)
{
	const xmlChar *str = node_get_text(node);
	char *end;
	unsigned long long v;

	if (!str)
		return 0;
	v = strtoull(str, &end, base);
	if ((xmlChar *)end == str || *end || v >= UINT64_MAX)
		return 0;
	return v;
}

/* Retrieve the timestamp from a time node.  This node should have child
 * elements HIGHPART and LOWPART; these elements will be used to construct a
 * Windows-style timestamp.  */
static u64
node_get_timestamp(const xmlNode *node)
{
	u64 timestamp = 0;
	xmlNode *child;

	if (!node)
		return 0;
	node_for_each_child(node, child) {
		if (node_is_element(child, "HIGHPART"))
			timestamp |= node_get_number(child, 16) << 32;
		else if (node_is_element(child, "LOWPART"))
			timestamp |= node_get_number(child, 16);
	}
	return timestamp;
}

static int
tstr_get_utf8(const tchar *tstr, const xmlChar **utf8_ret)
{
#if TCHAR_IS_UTF16LE
	return utf16le_to_utf8(tstr, tstrlen(tstr) * sizeof(tchar),
			       (char **)utf8_ret, NULL);
#else
	*utf8_ret = (const xmlChar *)tstr;
	return 0;
#endif
}

static void
tstr_put_utf8(const xmlChar *utf8)
{
#if TCHAR_IS_UTF16LE
	FREE((char *)utf8);
#endif
}

/* Retrieve the text contents of an XML element as a 'tchar' string.  If not
 * found or if the text could not be translated, returns NULL.  */
static const tchar *
node_get_ttext(struct wim_xml_info *info, xmlNode *node)
{
	const xmlChar *text = node_get_text(node);

#if TCHAR_IS_UTF16LE
	tchar **ttext_p;

	if (!text)
		return NULL;

	ttext_p = &info->strings[info->next_string_idx];
	if (info->num_strings >= ARRAY_LEN(info->strings)) {
		FREE(*ttext_p);
		*ttext_p = NULL;
	}
	if (utf8_to_tstr(text, strlen(text), ttext_p, NULL))
		return NULL;
	if (info->num_strings < ARRAY_LEN(info->strings))
		info->num_strings++;
	info->next_string_idx++;
	info->next_string_idx %= ARRAY_LEN(info->strings);
	return *ttext_p;
#else
	return text;
#endif
}

/* Unlink the specified node from its parent, then free it (recursively).  */
static void
unlink_and_free_tree(xmlNode *node)
{
	xmlUnlinkNode(node);
	xmlFreeNode(node);
}

/* Unlink and free (recursively) all children of the specified node.  */
static void
unlink_and_free_children(xmlNode *node)
{
	xmlNode *child;

	while ((child = node->last) != NULL)
		unlink_and_free_tree(child);
}

/* Add the new child element 'replacement' to 'parent', replacing any same-named
 * element that may already exist.  */
static void
node_replace_child_element(xmlNode *parent, xmlNode *replacement)
{
	xmlNode *child;

	node_for_each_child(parent, child) {
		if (node_is_element(child, replacement->name)) {
			xmlReplaceNode(child, replacement);
			xmlFreeNode(child);
			return;
		}
	}

	xmlAddChild(parent, replacement);
}

/* Set the text contents of the specified element to the specified string,
 * replacing the existing contents (if any).  The string is "raw" and is
 * permitted to contain characters that have special meaning in XML.  */
static int
node_set_text(xmlNode *node, const xmlChar *text)
{
	xmlNode *text_node = xmlNewText(text);
	if (!text_node)
		return WIMLIB_ERR_NOMEM;
	unlink_and_free_children(node);
	xmlAddChild(node, text_node);
	return 0;
}

/* Like 'node_set_text()', but takes in a 'tchar' string.  */
static int
node_set_ttext(xmlNode *node, const tchar *ttext)
{
	const xmlChar *text;
	int ret;

	ret = tstr_get_utf8(ttext, &text);
	if (ret)
		return ret;
	ret = node_set_text(node, text);
	tstr_put_utf8(text);
	return ret;
}

/* Create a new element containing text and optionally link it into a tree.  */
static xmlNode *
new_element_with_text(xmlNode *parent, const xmlChar *name, const xmlChar *text)
{
	xmlNode *node;

	node = xmlNewNode(NULL, name);
	if (!node)
		return NULL;

	if (node_set_text(node, text)) {
		xmlFreeNode(node);
		return NULL;
	}

	if (parent)
		xmlAddChild(parent, node);
	return node;
}

/* Create a new element containing text and optionally link it into a tree.  */
static int
new_element_with_ttext(xmlNode *parent, const xmlChar *name, const tchar *ttext,
		       xmlNode **node_ret)
{
	const xmlChar *text;
	int ret;
	xmlNode *node;

	ret = tstr_get_utf8(ttext, &text);
	if (ret)
		return ret;
	node = new_element_with_text(parent, name, text);
	tstr_put_utf8(text);
	if (!node)
		return WIMLIB_ERR_NOMEM;
	if (node_ret)
		*node_ret = node;
	return 0;
}

/* Create a new timestamp element and optionally link it into a tree.  */
static xmlNode *
new_element_with_timestamp(xmlNode *parent, const xmlChar *name, u64 timestamp)
{
	xmlNode *node;
	char buf[32];

	node = xmlNewNode(NULL, name);
	if (!node)
		goto err;

	sprintf(buf, "0x%08"PRIX32, (u32)(timestamp >> 32));
	if (!new_element_with_text(node, "HIGHPART", buf))
		goto err;

	sprintf(buf, "0x%08"PRIX32, (u32)timestamp);
	if (!new_element_with_text(node, "LOWPART", buf))
		goto err;

	if (parent)
		xmlAddChild(parent, node);
	return node;

err:
	xmlFreeNode(node);
	return NULL;
}

/* Create a new number element and optionally link it into a tree.  */
static xmlNode *
new_element_with_u64(xmlNode *parent, const xmlChar *name, u64 value)
{
	char buf[32];

	sprintf(buf, "%"PRIu64, value);
	return new_element_with_text(parent, name, buf);
}

/* Allocate a 'struct wim_xml_info'.  The caller is responsible for initializing
 * the document and the images array.  */
static struct wim_xml_info *
alloc_wim_xml_info(void)
{
	struct wim_xml_info *info = MALLOC(sizeof(*info));
#if TCHAR_IS_UTF16LE
	if (info) {
		info->next_string_idx = 0;
		info->num_strings = 0;
	}
#endif
	return info;
}

static bool
parse_index(xmlChar **pp, u32 *index_ret)
{
	xmlChar *p = *pp;
	u32 index = 0;

	*p++ = '\0'; /* overwrite '[' */
	while (*p >= '0' && *p <= '9') {
		u32 n = (index * 10) + (*p++ - '0');
		if (n < index)
			return false;
		index = n;
	}
	if (index == 0)
		return false;
	if (*p != ']')
		return false;
	p++;
	if (*p != '/' && *p != '\0')
		return false;

	*pp = p;
	*index_ret = index;
	return true;
}

static int
do_xml_path_walk(xmlNode *node, const xmlChar *path, bool create,
		 xmlNode **result_ret)
{
	size_t n = strlen(path) + 1;
	xmlChar buf[n];
	xmlChar *p;
	xmlChar c;

	*result_ret = NULL;

	if (!node)
		return 0;

	/* Copy the path to a temporary buffer.  */
	memcpy(buf, path, n);
	p = buf;

	if (*p == '/')
		goto bad_syntax;
	c = *p;

	while (c != '\0') {
		const xmlChar *name;
		xmlNode *child;
		u32 index = 1;

		/* We have another path component.  */

		/* Parse the element name.  */
		name = p;
		while (*p != '/' && *p != '\0' && *p != '[')
			p++;
		if (p == name) /* empty name?  */
			goto bad_syntax;

		/* Handle a bracketed index, if one was specified.  */
		if (*p == '[' && !parse_index(&p, &index))
			goto bad_syntax;

		c = *p;
		*p = '\0';

		/* Look for a matching child.  */
		node_for_each_child(node, child)
			if (node_is_element(child, name) && !--index)
				goto next_step;

		/* No child matched the path.  If create=false, the lookup
		 * failed.  If create=true, create the needed element.  */
		if (!create)
			return 0;

		/* We can't create an element at index 'n' if indices 1...n-1
		 * didn't already exist.  */
		if (index != 1)
			return WIMLIB_ERR_INVALID_PARAM;

		child = xmlNewChild(node, NULL, name, NULL);
		if (!child)
			return WIMLIB_ERR_NOMEM;
	next_step:
		/* Continue to the next path component, if there is one.  */
		node = child;
		p++;
	}

	*result_ret = node;
	return 0;

bad_syntax:
	ERROR("The XML path \"%s\" has invalid syntax.", path);
	return WIMLIB_ERR_INVALID_PARAM;
}

/* Retrieve the XML element, if any, at the specified 'path'.  This supports a
 * simple filesystem-like syntax.  If the element was found, returns a pointer
 * to it; otherwise returns NULL.  */
static xmlNode *
xml_get_node_by_path(xmlNode *root, const xmlChar *path)
{
	xmlNode *node;
	do_xml_path_walk(root, path, false, &node);
	return node;
}

/* Similar to xml_get_node_by_path(), but creates the element and any requisite
 * ancestor elements as needed.   If successful, 0 is returned and *node_ret is
 * set to a pointer to the resulting element.  If unsuccessful, an error code is
 * returned and *node_ret is set to NULL.  */
static int
xml_ensure_node_by_path(xmlNode *root, const xmlChar *path, xmlNode **node_ret)
{
	return do_xml_path_walk(root, path, true, node_ret);
}

static u64
xml_get_number_by_path(xmlNode *root, const xmlChar *path)
{
	return node_get_number(xml_get_node_by_path(root, path), 10);
}

static u64
xml_get_timestamp_by_path(xmlNode *root, const xmlChar *path)
{
	return node_get_timestamp(xml_get_node_by_path(root, path));
}

static const xmlChar *
xml_get_text_by_path(xmlNode *root, const xmlChar *path)
{
	return node_get_text(xml_get_node_by_path(root, path));
}

static const tchar *
xml_get_ttext_by_path(struct wim_xml_info *info, xmlNode *root,
		      const xmlChar *path)
{
	return node_get_ttext(info, xml_get_node_by_path(root, path));
}

/* Creates/replaces (if ttext is not NULL and not empty) or removes (if ttext is
 * NULL or empty) an element containing text.  */
static int
xml_set_ttext_by_path(xmlNode *root, const xmlChar *path, const tchar *ttext)
{
	int ret;
	xmlNode *node;

	if (ttext && *ttext) {
		/* Create or replace  */
		ret = xml_ensure_node_by_path(root, path, &node);
		if (ret)
			return ret;
		return node_set_ttext(node, ttext);
	} else {
		/* Remove  */
		node = xml_get_node_by_path(root, path);
		if (node)
			unlink_and_free_tree(node);
		return 0;
	}
}

/* Unlink and return the node which represents the INDEX attribute of the
 * specified IMAGE element.  */
static xmlAttr *
unlink_index_attribute(xmlNode *image_node)
{
	xmlAttr *attr = xmlHasProp(image_node, "INDEX");
	xmlUnlinkNode((xmlNode *)attr);
	return attr;
}

/* Compute the total uncompressed size of the streams of the specified inode. */
static u64
inode_sum_stream_sizes(const struct wim_inode *inode,
		       const struct blob_table *blob_table)
{
	u64 total_size = 0;

	for (unsigned i = 0; i < inode->i_num_streams; i++) {
		const struct blob_descriptor *blob;

		blob = stream_blob(&inode->i_streams[i], blob_table);
		if (blob)
			total_size += blob->size;
	}
	return total_size;
}

static int
append_image_node(struct wim_xml_info *info, xmlNode *image_node)
{
	char buf[32];
	xmlNode **images;

	/* Limit exceeded?  */
	if (unlikely(info->image_count >= MAX_IMAGES))
		return WIMLIB_ERR_IMAGE_COUNT;

	/* Add the INDEX attribute.  */
	sprintf(buf, "%d", info->image_count + 1);
	if (!xmlNewProp(image_node, "INDEX", buf))
		return WIMLIB_ERR_NOMEM;

	/* Append the IMAGE element to the 'images' array.  */
	images = REALLOC(info->images,
			 (info->image_count + 1) * sizeof(info->images[0]));
	if (unlikely(!images))
		return WIMLIB_ERR_NOMEM;
	info->images = images;
	images[info->image_count++] = image_node;

	/* Add the IMAGE element to the document.  */
	xmlAddChild(info->root, image_node);
	return 0;
}

/*----------------------------------------------------------------------------*
 *                     Functions for internal library use                     *
 *----------------------------------------------------------------------------*/

/* Allocate an empty 'struct wim_xml_info', containing no images.  */
struct wim_xml_info *
xml_new_info_struct(void)
{
	struct wim_xml_info *info;

	info = alloc_wim_xml_info();
	if (!info)
		goto err;

	info->doc = xmlNewDoc("1.0");
	if (!info->doc)
		goto err_free_info;

	info->root = xmlNewNode(NULL, "WIM");
	if (!info->root)
		goto err_free_doc;
	xmlDocSetRootElement(info->doc, info->root);

	info->images = NULL;
	info->image_count = 0;
	return info;

err_free_doc:
	xmlFreeDoc(info->doc);
err_free_info:
	FREE(info);
err:
	return NULL;
}

/* Free a 'struct wim_xml_info'.  */
void
xml_free_info_struct(struct wim_xml_info *info)
{
	if (info) {
		xmlFreeDoc(info->doc);
		FREE(info->images);
	#if TCHAR_IS_UTF16LE
		for (size_t i = 0; i < info->num_strings; i++)
			FREE(info->strings[i]);
	#endif
		FREE(info);
	}
}

/* Retrieve the number of images for which there exist IMAGE elements in the XML
 * document.  */
int
xml_get_image_count(const struct wim_xml_info *info)
{
	return info->image_count;
}

/* Retrieve the TOTALBYTES value for the WIM file, or 0 if this value is
 * unavailable.  */
u64
xml_get_total_bytes(const struct wim_xml_info *info)
{
	return xml_get_number_by_path(info->root, "TOTALBYTES");
}

/* Retrieve the TOTALBYTES value for the specified image, or 0 if this value is
 * unavailable.  */
u64
xml_get_image_total_bytes(const struct wim_xml_info *info, int image)
{
	return xml_get_number_by_path(info->images[image - 1], "TOTALBYTES");
}

/* Retrieve the HARDLINKBYTES value for the specified image, or 0 if this value
 * is unavailable.  */
u64
xml_get_image_hard_link_bytes(const struct wim_xml_info *info, int image)
{
	return xml_get_number_by_path(info->images[image - 1], "HARDLINKBYTES");
}

/* Retrieve the WIMBOOT value for the specified image, or false if this value is
 * unavailable.  */
bool
xml_get_wimboot(const struct wim_xml_info *info, int image)
{
	return xml_get_number_by_path(info->images[image - 1], "WIMBOOT");
}

/* Retrieve the Windows build number for the specified image, or 0 if this
 * information is not available.  */
u64
xml_get_windows_build_number(const struct wim_xml_info *info, int image)
{
	return xml_get_number_by_path(info->images[image - 1],
				      "WINDOWS/VERSION/BUILD");
}

/* Set the WIMBOOT value for the specified image.  */
int
xml_set_wimboot(struct wim_xml_info *info, int image)
{
	return xml_set_ttext_by_path(info->images[image - 1], "WIMBOOT", T("1"));
}

/*
 * Update the DIRCOUNT, FILECOUNT, TOTALBYTES, HARDLINKBYTES, and
 * LASTMODIFICATIONTIME elements for the specified WIM image.
 *
 * Note: since these stats are likely to be used for display purposes only, we
 * no longer attempt to duplicate WIMGAPI's weird bugs when calculating them.
 */
int
xml_update_image_info(WIMStruct *wim, int image)
{
	const struct wim_image_metadata *imd = wim->image_metadata[image - 1];
	xmlNode *image_node = wim->xml_info->images[image - 1];
	const struct wim_inode *inode;
	u64 dir_count = 0;
	u64 file_count = 0;
	u64 total_bytes = 0;
	u64 hard_link_bytes = 0;
	u64 size;
	xmlNode *dircount_node;
	xmlNode *filecount_node;
	xmlNode *totalbytes_node;
	xmlNode *hardlinkbytes_node;
	xmlNode *lastmodificationtime_node;

	image_for_each_inode(inode, imd) {
		if (inode_is_directory(inode))
			dir_count += inode->i_nlink;
		else
			file_count += inode->i_nlink;
		size = inode_sum_stream_sizes(inode, wim->blob_table);
		total_bytes += size * inode->i_nlink;
		hard_link_bytes += size * (inode->i_nlink - 1);
	}

	dircount_node = new_element_with_u64(NULL, "DIRCOUNT", dir_count);
	filecount_node = new_element_with_u64(NULL, "FILECOUNT", file_count);
	totalbytes_node = new_element_with_u64(NULL, "TOTALBYTES", total_bytes);
	hardlinkbytes_node = new_element_with_u64(NULL, "HARDLINKBYTES",
						  hard_link_bytes);
	lastmodificationtime_node =
		new_element_with_timestamp(NULL, "LASTMODIFICATIONTIME",
					   now_as_wim_timestamp());

	if (unlikely(!dircount_node || !filecount_node || !totalbytes_node ||
		     !hardlinkbytes_node || !lastmodificationtime_node)) {
		xmlFreeNode(dircount_node);
		xmlFreeNode(filecount_node);
		xmlFreeNode(totalbytes_node);
		xmlFreeNode(hardlinkbytes_node);
		xmlFreeNode(lastmodificationtime_node);
		return WIMLIB_ERR_NOMEM;
	}

	node_replace_child_element(image_node, dircount_node);
	node_replace_child_element(image_node, filecount_node);
	node_replace_child_element(image_node, totalbytes_node);
	node_replace_child_element(image_node, hardlinkbytes_node);
	node_replace_child_element(image_node, lastmodificationtime_node);
	return 0;
}

/* Add an image to the XML information. */
int
xml_add_image(struct wim_xml_info *info, const tchar *name)
{
	const u64 now = now_as_wim_timestamp();
	xmlNode *image_node;
	int ret;

	ret = WIMLIB_ERR_NOMEM;
	image_node = xmlNewNode(NULL, "IMAGE");
	if (!image_node)
		goto err;

	if (name && *name) {
		ret = new_element_with_ttext(image_node, "NAME", name, NULL);
		if (ret)
			goto err;
	}
	ret = WIMLIB_ERR_NOMEM;
	if (!new_element_with_u64(image_node, "DIRCOUNT", 0))
		goto err;
	if (!new_element_with_u64(image_node, "FILECOUNT", 0))
		goto err;
	if (!new_element_with_u64(image_node, "TOTALBYTES", 0))
		goto err;
	if (!new_element_with_u64(image_node, "HARDLINKBYTES", 0))
		goto err;
	if (!new_element_with_timestamp(image_node, "CREATIONTIME", now))
		goto err;
	if (!new_element_with_timestamp(image_node, "LASTMODIFICATIONTIME", now))
		goto err;
	ret = append_image_node(info, image_node);
	if (ret)
		goto err;
	return 0;

err:
	xmlFreeNode(image_node);
	return ret;
}

/*
 * Make a copy of the XML information for the image with index @src_image in the
 * @src_info XML document and append it to the @dest_info XML document.
 *
 * In the process, change the image's name and description to the values
 * specified by @dest_image_name and @dest_image_description.  Either or both
 * may be NULL, which indicates that the corresponding element will not be
 * included in the destination image.
 */
int
xml_export_image(const struct wim_xml_info *src_info, int src_image,
		 struct wim_xml_info *dest_info, const tchar *dest_image_name,
		 const tchar *dest_image_description, bool wimboot)
{
	xmlNode *dest_node;
	int ret;

	ret = WIMLIB_ERR_NOMEM;
	dest_node = xmlDocCopyNode(src_info->images[src_image - 1],
				   dest_info->doc, 1);
	if (!dest_node)
		goto err;

	ret = xml_set_ttext_by_path(dest_node, "NAME", dest_image_name);
	if (ret)
		goto err;

	ret = xml_set_ttext_by_path(dest_node, "DESCRIPTION",
				    dest_image_description);
	if (ret)
		goto err;

	if (wimboot) {
		ret = xml_set_ttext_by_path(dest_node, "WIMBOOT", T("1"));
		if (ret)
			goto err;
	}

	xmlFreeProp(unlink_index_attribute(dest_node));

	ret = append_image_node(dest_info, dest_node);
	if (ret)
		goto err;
	return 0;

err:
	xmlFreeNode(dest_node);
	return ret;
}

/* Remove the specified image from the XML document.  */
void
xml_delete_image(struct wim_xml_info *info, int image)
{
	xmlNode *next_image;
	xmlAttr *index_attr, *next_index_attr;

	/* Free the IMAGE element for the deleted image.  Then, shift all
	 * higher-indexed IMAGE elements down by 1, in the process re-assigning
	 * their INDEX attributes.  */

	next_image = info->images[image - 1];
	next_index_attr = unlink_index_attribute(next_image);
	unlink_and_free_tree(next_image);

	while (image < info->image_count) {
		index_attr = next_index_attr;
		next_image = info->images[image];
		next_index_attr = unlink_index_attribute(next_image);
		xmlAddChild(next_image, (xmlNode *)index_attr);
		info->images[image - 1] = next_image;
		image++;
	}

	xmlFreeProp(next_index_attr);
	info->image_count--;
}

/* Architecture constants are from w64 mingw winnt.h  */
#define PROCESSOR_ARCHITECTURE_INTEL		0
#define PROCESSOR_ARCHITECTURE_MIPS		1
#define PROCESSOR_ARCHITECTURE_ALPHA		2
#define PROCESSOR_ARCHITECTURE_PPC		3
#define PROCESSOR_ARCHITECTURE_SHX		4
#define PROCESSOR_ARCHITECTURE_ARM		5
#define PROCESSOR_ARCHITECTURE_IA64		6
#define PROCESSOR_ARCHITECTURE_ALPHA64		7
#define PROCESSOR_ARCHITECTURE_MSIL		8
#define PROCESSOR_ARCHITECTURE_AMD64		9
#define PROCESSOR_ARCHITECTURE_IA32_ON_WIN64	10
#define PROCESSOR_ARCHITECTURE_ARM64		12

static const tchar *
describe_arch(u64 arch)
{
	static const tchar * const descriptions[] = {
		[PROCESSOR_ARCHITECTURE_INTEL] = T("x86"),
		[PROCESSOR_ARCHITECTURE_MIPS]  = T("MIPS"),
		[PROCESSOR_ARCHITECTURE_ARM]   = T("ARM"),
		[PROCESSOR_ARCHITECTURE_IA64]  = T("ia64"),
		[PROCESSOR_ARCHITECTURE_AMD64] = T("x86_64"),
		[PROCESSOR_ARCHITECTURE_ARM64] = T("ARM64"),
	};

	if (arch < ARRAY_LEN(descriptions) && descriptions[arch] != NULL)
		return descriptions[arch];

	return T("unknown");
}

/* Print information from the WINDOWS element, if present.  */
static void
print_windows_info(struct wim_xml_info *info, xmlNode *image_node)
{
	xmlNode *windows_node;
	xmlNode *langs_node;
	xmlNode *version_node;
	const tchar *text;

	windows_node = xml_get_node_by_path(image_node, "WINDOWS");
	if (!windows_node)
		return;

	tprintf(T("Architecture:           %"TS"\n"),
		describe_arch(xml_get_number_by_path(windows_node, "ARCH")));

	text = xml_get_ttext_by_path(info, windows_node, "PRODUCTNAME");
	if (text)
		tprintf(T("Product Name:           %"TS"\n"), text);

	text = xml_get_ttext_by_path(info, windows_node, "EDITIONID");
	if (text)
		tprintf(T("Edition ID:             %"TS"\n"), text);

	text = xml_get_ttext_by_path(info, windows_node, "INSTALLATIONTYPE");
	if (text)
		tprintf(T("Installation Type:      %"TS"\n"), text);

	text = xml_get_ttext_by_path(info, windows_node, "HAL");
	if (text)
		tprintf(T("HAL:                    %"TS"\n"), text);

	text = xml_get_ttext_by_path(info, windows_node, "PRODUCTTYPE");
	if (text)
		tprintf(T("Product Type:           %"TS"\n"), text);

	text = xml_get_ttext_by_path(info, windows_node, "PRODUCTSUITE");
	if (text)
		tprintf(T("Product Suite:          %"TS"\n"), text);

	langs_node = xml_get_node_by_path(windows_node, "LANGUAGES");
	if (langs_node) {
		xmlNode *lang_node;

		tprintf(T("Languages:              "));
		node_for_each_child(langs_node, lang_node) {
			if (!node_is_element(lang_node, "LANGUAGE"))
				continue;
			text = node_get_ttext(info, lang_node);
			if (!text)
				continue;
			tprintf(T("%"TS" "), text);
		}
		tputchar(T('\n'));

		text = xml_get_ttext_by_path(info, langs_node, "DEFAULT");
		if (text)
			tprintf(T("Default Language:       %"TS"\n"), text);
	}

	text = xml_get_ttext_by_path(info, windows_node, "SYSTEMROOT");
	if (text)
		tprintf(T("System Root:            %"TS"\n"), text);

	version_node = xml_get_node_by_path(windows_node, "VERSION");
	if (version_node) {
		tprintf(T("Major Version:          %"PRIu64"\n"),
			xml_get_number_by_path(version_node, "MAJOR"));
		tprintf(T("Minor Version:          %"PRIu64"\n"),
			xml_get_number_by_path(version_node, "MINOR"));
		tprintf(T("Build:                  %"PRIu64"\n"),
			xml_get_number_by_path(version_node, "BUILD"));
		tprintf(T("Service Pack Build:     %"PRIu64"\n"),
			xml_get_number_by_path(version_node, "SPBUILD"));
		tprintf(T("Service Pack Level:     %"PRIu64"\n"),
			xml_get_number_by_path(version_node, "SPLEVEL"));
	}
}

/* Prints information about the specified image.  */
void
xml_print_image_info(struct wim_xml_info *info, int image)
{
	xmlNode * const image_node = info->images[image - 1];
	const tchar *text;
	tchar timebuf[64];

	tprintf(T("Index:                  %d\n"), image);

	/* Always print the Name and Description, even if the corresponding XML
	 * elements are not present.  */
	text = xml_get_ttext_by_path(info, image_node, "NAME");
	tprintf(T("Name:                   %"TS"\n"), text ? text : T(""));
	text = xml_get_ttext_by_path(info, image_node, "DESCRIPTION");
	tprintf(T("Description:            %"TS"\n"), text ? text : T(""));

	text = xml_get_ttext_by_path(info, image_node, "DISPLAYNAME");
	if (text)
		tprintf(T("Display Name:           %"TS"\n"), text);

	text = xml_get_ttext_by_path(info, image_node, "DISPLAYDESCRIPTION");
	if (text)
		tprintf(T("Display Description:    %"TS"\n"), text);

	tprintf(T("Directory Count:        %"PRIu64"\n"),
		xml_get_number_by_path(image_node, "DIRCOUNT"));

	tprintf(T("File Count:             %"PRIu64"\n"),
		xml_get_number_by_path(image_node, "FILECOUNT"));

	tprintf(T("Total Bytes:            %"PRIu64"\n"),
		xml_get_number_by_path(image_node, "TOTALBYTES"));

	tprintf(T("Hard Link Bytes:        %"PRIu64"\n"),
		xml_get_number_by_path(image_node, "HARDLINKBYTES"));

	wim_timestamp_to_str(xml_get_timestamp_by_path(image_node,
						       "CREATIONTIME"),
			     timebuf, ARRAY_LEN(timebuf));
	tprintf(T("Creation Time:          %"TS"\n"), timebuf);

	wim_timestamp_to_str(xml_get_timestamp_by_path(image_node,
						       "LASTMODIFICATIONTIME"),
			     timebuf, ARRAY_LEN(timebuf));
	tprintf(T("Last Modification Time: %"TS"\n"), timebuf);

	print_windows_info(info, image_node);

	text = xml_get_ttext_by_path(info, image_node, "FLAGS");
	if (text)
		tprintf(T("Flags:                  %"TS"\n"), text);

	tprintf(T("WIMBoot compatible:     %"TS"\n"),
		xml_get_number_by_path(image_node, "WIMBOOT") ?
			T("yes") : T("no"));

	tputchar('\n');
}

/*----------------------------------------------------------------------------*
 *                      Reading and writing the XML data                      *
 *----------------------------------------------------------------------------*/

static int
image_node_get_index(xmlNode *node)
{
	u64 v = node_get_number((const xmlNode *)xmlHasProp(node, "INDEX"), 10);
	return min(v, INT_MAX);
}

/* Prepare the 'images' array from the XML document tree.  */
static int
setup_images(struct wim_xml_info *info, xmlNode *root)
{
	xmlNode *child;
	int index;
	int max_index = 0;
	int ret;

	info->images = NULL;
	info->image_count = 0;

	node_for_each_child(root, child) {
		if (!node_is_element(child, "IMAGE"))
			continue;
		index = image_node_get_index(child);
		if (unlikely(index < 1 || info->image_count >= MAX_IMAGES))
			goto err_indices;
		max_index = max(max_index, index);
		info->image_count++;
	}
	if (unlikely(max_index != info->image_count))
		goto err_indices;
	ret = WIMLIB_ERR_NOMEM;
	info->images = CALLOC(info->image_count, sizeof(info->images[0]));
	if (unlikely(!info->images))
		goto err;
	node_for_each_child(root, child) {
		if (!node_is_element(child, "IMAGE"))
			continue;
		index = image_node_get_index(child);
		if (unlikely(info->images[index - 1]))
			goto err_indices;
		info->images[index - 1] = child;
	}
	return 0;

err_indices:
	ERROR("The WIM file's XML document does not contain exactly one IMAGE "
	      "element per image!");
	ret = WIMLIB_ERR_XML;
err:
	FREE(info->images);
	return ret;
}

/* Reads the XML data from a WIM file.  */
int
read_wim_xml_data(WIMStruct *wim)
{
	struct wim_xml_info *info;
	void *buf;
	size_t bufsize;
	xmlDoc *doc;
	xmlNode *root;
	int ret;

	/* Allocate the 'struct wim_xml_info'.  */
	ret = WIMLIB_ERR_NOMEM;
	info = alloc_wim_xml_info();
	if (!info)
		goto err;

	/* Read the raw UTF-16LE bytes.  */
	ret = wimlib_get_xml_data(wim, &buf, &bufsize);
	if (ret)
		goto err_free_info;

	/* Parse the document with libxml2, creating the document tree.  */
	doc = xmlReadMemory(buf, bufsize, NULL, "UTF-16LE", XML_PARSE_NONET);
	FREE(buf);
	buf = NULL;
	if (!doc) {
		ERROR("Unable to parse the WIM file's XML document!");
		ret = WIMLIB_ERR_XML;
		goto err_free_info;
	}

	/* Verify the root element.  */
	root = xmlDocGetRootElement(doc);
	if (!node_is_element(root, "WIM")) {
		ERROR("The WIM file's XML document has an unexpected format!");
		ret = WIMLIB_ERR_XML;
		goto err_free_doc;
	}

	/* Verify the WIM file is not encrypted.  */
	if (xml_get_node_by_path(root, "ESD/ENCRYPTED")) {
		ret = WIMLIB_ERR_WIM_IS_ENCRYPTED;
		goto err_free_doc;
	}

	/* Validate the image elements and set up the images[] array.  */
	ret = setup_images(info, root);
	if (ret)
		goto err_free_doc;

	/* Save the document and return.  */
	info->doc = doc;
	info->root = root;
	wim->xml_info = info;
	return 0;

err_free_doc:
	xmlFreeDoc(doc);
err_free_info:
	FREE(info);
err:
	return ret;
}

/* Swap the INDEX attributes of two IMAGE elements.  */
static void
swap_index_attributes(xmlNode *image_node_1, xmlNode *image_node_2)
{
	xmlAttr *attr_1, *attr_2;

	if (image_node_1 != image_node_2) {
		attr_1 = unlink_index_attribute(image_node_1);
		attr_2 = unlink_index_attribute(image_node_2);
		xmlAddChild(image_node_1, (xmlNode *)attr_2);
		xmlAddChild(image_node_2, (xmlNode *)attr_1);
	}
}

static int
prepare_document_for_write(struct wim_xml_info *info, int image, u64 total_bytes,
			   xmlNode **orig_totalbytes_node_ret)
{
	xmlNode *totalbytes_node = NULL;

	/* Allocate the new TOTALBYTES element if needed.  */
	if (total_bytes != WIM_TOTALBYTES_USE_EXISTING &&
	    total_bytes != WIM_TOTALBYTES_OMIT) {
		totalbytes_node = new_element_with_u64(NULL, "TOTALBYTES",
						       total_bytes);
		if (!totalbytes_node)
			return WIMLIB_ERR_NOMEM;
	}

	/* Adjust the IMAGE elements if needed.  */
	if (image != WIMLIB_ALL_IMAGES) {
		/* We're writing a single image only.  Temporarily unlink all
		 * other IMAGE elements from the document.  */
		for (int i = 0; i < info->image_count; i++)
			if (i + 1 != image)
				xmlUnlinkNode(info->images[i]);

		/* Temporarily set the INDEX attribute of the needed IMAGE
		 * element to 1.  */
		swap_index_attributes(info->images[0], info->images[image - 1]);
	}

	/* Adjust (add, change, or remove) the TOTALBYTES element if needed.  */
	*orig_totalbytes_node_ret = NULL;
	if (total_bytes != WIM_TOTALBYTES_USE_EXISTING) {
		/* Unlink the previous TOTALBYTES element, if any.  */
		*orig_totalbytes_node_ret = xml_get_node_by_path(info->root,
								 "TOTALBYTES");
		if (*orig_totalbytes_node_ret)
			xmlUnlinkNode(*orig_totalbytes_node_ret);

		/* Link in the new TOTALBYTES element, if any.  */
		if (totalbytes_node)
			xmlAddChild(info->root, totalbytes_node);
	}
	return 0;
}

static void
restore_document_after_write(struct wim_xml_info *info, int image,
			     xmlNode *orig_totalbytes_node)
{
	/* Restore the IMAGE elements if needed.  */
	if (image != WIMLIB_ALL_IMAGES) {
		/* We wrote a single image only.  Re-link all other IMAGE
		 * elements to the document.  */
		for (int i = 0; i < info->image_count; i++)
			if (i + 1 != image)
				xmlAddChild(info->root, info->images[i]);

		/* Restore the original INDEX attributes.  */
		swap_index_attributes(info->images[0], info->images[image - 1]);
	}

	/* Restore the original TOTALBYTES element if needed.  */
	if (orig_totalbytes_node)
		node_replace_child_element(info->root, orig_totalbytes_node);
}

/*
 * Writes the XML data to a WIM file.
 *
 * 'image' specifies the image(s) to include in the XML data.  Normally it is
 * WIMLIB_ALL_IMAGES, but it can also be a 1-based image index.
 *
 * 'total_bytes' is the number to use in the top-level TOTALBYTES element, or
 * WIM_TOTALBYTES_USE_EXISTING to use the existing value from the XML document
 * (if any), or WIM_TOTALBYTES_OMIT to omit the TOTALBYTES element entirely.
 */
int
write_wim_xml_data(WIMStruct *wim, int image, u64 total_bytes,
		   struct wim_reshdr *out_reshdr, int write_resource_flags)
{
	struct wim_xml_info *info = wim->xml_info;
	long ret;
	long ret2;
	xmlBuffer *buffer;
	xmlNode *orig_totalbytes_node;
	xmlSaveCtxt *save_ctx;

	/* Make any needed temporary changes to the document.  */
	ret = prepare_document_for_write(info, image, total_bytes,
					 &orig_totalbytes_node);
	if (ret)
		goto out;

	/* Create an in-memory buffer to hold the encoded document.  */
	ret = WIMLIB_ERR_NOMEM;
	buffer = xmlBufferCreate();
	if (!buffer)
		goto out_restore_document;

	/* Encode the document in UTF-16LE, with a byte order mark, and with no
	 * XML declaration.  Some other WIM software requires all of these
	 * characteristics.  */
	ret = WIMLIB_ERR_NOMEM;
	if (xmlBufferCat(buffer, "\xff\xfe"))
		goto out_free_buffer;
	save_ctx = xmlSaveToBuffer(buffer, "UTF-16LE", XML_SAVE_NO_DECL);
	if (!save_ctx)
		goto out_free_buffer;
	ret = xmlSaveDoc(save_ctx, info->doc);
	ret2 = xmlSaveClose(save_ctx);
	if (ret < 0 || ret2 < 0) {
		ERROR("Unable to serialize the WIM file's XML document!");
		ret = WIMLIB_ERR_NOMEM;
		goto out_free_buffer;
	}

	/* Write the XML data uncompressed.  Although wimlib can handle
	 * compressed XML data, some other WIM software cannot.  */
	ret = write_wim_resource_from_buffer(xmlBufferContent(buffer),
					     xmlBufferLength(buffer),
					     true,
					     &wim->out_fd,
					     WIMLIB_COMPRESSION_TYPE_NONE,
					     0,
					     out_reshdr,
					     NULL,
					     write_resource_flags);
out_free_buffer:
	xmlBufferFree(buffer);
out_restore_document:
	/* Revert any temporary changes we made to the document.  */
	restore_document_after_write(info, image, orig_totalbytes_node);
out:
	return ret;
}

/*----------------------------------------------------------------------------*
 *                           Global setup functions                           *
 *----------------------------------------------------------------------------*/

void
xml_global_init(void)
{
	xmlInitParser();
}

void
xml_global_cleanup(void)
{
	xmlCleanupParser();
}

void
xml_set_memory_allocator(void *(*malloc_func)(size_t),
			 void (*free_func)(void *),
			 void *(*realloc_func)(void *, size_t))
{
	xmlMemSetup(free_func, malloc_func, realloc_func, wimlib_strdup);
}

/*----------------------------------------------------------------------------*
 *                           Library API functions                            *
 *----------------------------------------------------------------------------*/

WIMLIBAPI int
wimlib_get_xml_data(WIMStruct *wim, void **buf_ret, size_t *bufsize_ret)
{
	const struct wim_reshdr *xml_reshdr;

	if (wim->filename == NULL && filedes_is_seekable(&wim->in_fd))
		return WIMLIB_ERR_NO_FILENAME;

	if (buf_ret == NULL || bufsize_ret == NULL)
		return WIMLIB_ERR_INVALID_PARAM;

	xml_reshdr = &wim->hdr.xml_data_reshdr;

	*bufsize_ret = xml_reshdr->uncompressed_size;
	return wim_reshdr_to_data(xml_reshdr, wim, buf_ret);
}

WIMLIBAPI int
wimlib_extract_xml_data(WIMStruct *wim, FILE *fp)
{
	int ret;
	void *buf;
	size_t bufsize;

	ret = wimlib_get_xml_data(wim, &buf, &bufsize);
	if (ret)
		return ret;

	if (fwrite(buf, 1, bufsize, fp) != bufsize) {
		ERROR_WITH_ERRNO("Failed to extract XML data");
		ret = WIMLIB_ERR_WRITE;
	}
	FREE(buf);
	return ret;
}

static bool
image_name_in_use(const WIMStruct *wim, const tchar *name, int excluded_image)
{
	const struct wim_xml_info *info = wim->xml_info;
	const xmlChar *name_utf8;
	bool found = false;

	/* Any number of images can have "no name".  */
	if (!name || !*name)
		return false;

	/* Check for images that have the specified name.  */
	if (tstr_get_utf8(name, &name_utf8))
		return false;
	for (int i = 0; i < info->image_count && !found; i++) {
		if (i + 1 == excluded_image)
			continue;
		found = xmlStrEqual(name_utf8, xml_get_text_by_path(
						    info->images[i], "NAME"));
	}
	tstr_put_utf8(name_utf8);
	return found;
}

WIMLIBAPI bool
wimlib_image_name_in_use(const WIMStruct *wim, const tchar *name)
{
	return image_name_in_use(wim, name, WIMLIB_NO_IMAGE);
}

WIMLIBAPI const tchar *
wimlib_get_image_name(const WIMStruct *wim, int image)
{
	const struct wim_xml_info *info = wim->xml_info;
	const tchar *name;

	if (image < 1 || image > info->image_count)
		return NULL;
	name = wimlib_get_image_property(wim, image, T("NAME"));
	return name ? name : T("");
}

WIMLIBAPI const tchar *
wimlib_get_image_description(const WIMStruct *wim, int image)
{
	return wimlib_get_image_property(wim, image, T("DESCRIPTION"));
}

WIMLIBAPI const tchar *
wimlib_get_image_property(const WIMStruct *wim, int image,
			  const tchar *property_name)
{
	const xmlChar *name;
	const tchar *value;
	struct wim_xml_info *info = wim->xml_info;

	if (!property_name || !*property_name)
		return NULL;
	if (image < 1 || image > info->image_count)
		return NULL;
	if (tstr_get_utf8(property_name, &name))
		return NULL;
	value = xml_get_ttext_by_path(info, info->images[image - 1], name);
	tstr_put_utf8(name);
	return value;
}

WIMLIBAPI int
wimlib_set_image_name(WIMStruct *wim, int image, const tchar *name)
{
	return wimlib_set_image_property(wim, image, T("NAME"), name);
}

WIMLIBAPI int
wimlib_set_image_descripton(WIMStruct *wim, int image, const tchar *description)
{
	return wimlib_set_image_property(wim, image, T("DESCRIPTION"), description);
}

WIMLIBAPI int
wimlib_set_image_flags(WIMStruct *wim, int image, const tchar *flags)
{
	return wimlib_set_image_property(wim, image, T("FLAGS"), flags);
}

WIMLIBAPI int
wimlib_set_image_property(WIMStruct *wim, int image, const tchar *property_name,
			  const tchar *property_value)
{
	const xmlChar *name;
	struct wim_xml_info *info = wim->xml_info;
	int ret;

	if (!property_name || !*property_name)
		return WIMLIB_ERR_INVALID_PARAM;

	if (image < 1 || image > info->image_count)
		return WIMLIB_ERR_INVALID_IMAGE;

	if (!tstrcmp(property_name, T("NAME")) &&
	    image_name_in_use(wim, property_value, image))
		return WIMLIB_ERR_IMAGE_NAME_COLLISION;

	ret = tstr_get_utf8(property_name, &name);
	if (ret)
		return ret;
	ret = xml_set_ttext_by_path(info->images[image - 1], name, property_value);
	tstr_put_utf8(name);
	return ret;
}
