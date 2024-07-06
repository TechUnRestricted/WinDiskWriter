/*
 * test_support.c - Supporting code for tests
 */

/*
 * Copyright 2015-2023 Eric Biggers
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

/*
 * This file contains specialized test code which is only compiled when the
 * library is configured with --enable-test-support.  The major features are:
 *
 *	- Random directory tree generation
 *	- Directory tree comparison
 */

#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif

#ifdef ENABLE_TEST_SUPPORT

#include <ctype.h>
#include <math.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
#ifdef _WIN32
#  include <windows.h>
#  include <sddl.h>
#  undef ERROR
#endif

#include "wimlib.h"
#include "wimlib/endianness.h"
#include "wimlib/encoding.h"
#include "wimlib/metadata.h"
#include "wimlib/dentry.h"
#include "wimlib/inode.h"
#include "wimlib/object_id.h"
#include "wimlib/reparse.h"
#include "wimlib/scan.h"
#include "wimlib/security_descriptor.h"
#include "wimlib/test_support.h"
#include "wimlib/timestamp.h"
#include "wimlib/unix_data.h"
#include "wimlib/xattr.h"

/*----------------------------------------------------------------------------*
 *                            File tree generation                            *
 *----------------------------------------------------------------------------*/

struct generation_context {
	struct scan_params *params;
	struct wim_dentry *used_short_names[256];
	bool metadata_only;
};

static u64 random_state;

WIMLIBAPI void
wimlib_seed_random(u64 seed)
{
	random_state = seed;
}

static u32
rand32(void)
{
	/* A simple linear congruential generator */
	random_state = (random_state * 25214903917 + 11) % (1ULL << 48);
	return random_state >> 16;
}

static bool
randbool(void)
{
	return rand32() % 2;
}

static u8
rand8(void)
{
	return (u8)rand32();
}

static u16
rand16(void)
{
	return (u16)rand32();
}

static u64
rand64(void)
{
	return ((u64)rand32() << 32) | rand32();
}

static u64
generate_random_timestamp(void)
{
	u64 ts;

	if (randbool())
		ts = rand64();
	else
		ts = time_t_to_wim_timestamp(rand64() % (1ULL << 34));
	/*
	 * When setting timestamps on Windows:
	 * - 0 is a special value meaning "not specified"
	 * - if the high bit is set you get STATUS_INVALID_PARAMETER
	 */
	return max(1, ts % (1ULL << 63));
}

static inline bool
is_valid_windows_filename_char(utf16lechar c)
{
	return le16_to_cpu(c) > 31 &&
		c != cpu_to_le16('/') &&
		c != cpu_to_le16('<') &&
		c != cpu_to_le16('>') &&
		c != cpu_to_le16(':') &&
		c != cpu_to_le16('"') &&
		c != cpu_to_le16('/' ) &&
		c != cpu_to_le16('\\') &&
		c != cpu_to_le16('|') &&
		c != cpu_to_le16('?') &&
		c != cpu_to_le16('*');
}

/* Is the character valid in a filename on the current platform? */
static inline bool
is_valid_filename_char(utf16lechar c)
{
#ifdef _WIN32
	return is_valid_windows_filename_char(c);
#else
	return c != cpu_to_le16('\0') && c != cpu_to_le16('/');
#endif
}

/* Generate a random filename and return its length. */
static int
generate_random_filename(utf16lechar name[], int max_len,
			 struct generation_context *ctx)
{
	int len;

	/* Choose the length of the name. */
	switch (rand32() % 8) {
	default:
		/* short name  */
		len = 1 + (rand32() % 6);
		break;
	case 2:
	case 3:
	case 4:
		/* medium-length name  */
		len = 7 + (rand32() % 8);
		break;
	case 5:
	case 6:
		/* long name  */
		len = 15 + (rand32() % 15);
		break;
	case 7:
		/* very long name  */
		len = 30 + (rand32() % 90);
		break;
	}
	len = min(len, max_len);

retry:
	/* Generate the characters in the name. */
	for (int i = 0; i < len; i++) {
		do {
			name[i] = cpu_to_le16(rand16());
		} while (!is_valid_filename_char(name[i]));
	}

	/* Add a null terminator. */
	name[len] = cpu_to_le16('\0');

	/* Don't generate . and .. */
	if (name[0] == cpu_to_le16('.') &&
	    (len == 1 || (len == 2 && name[1] == cpu_to_le16('.'))))
		goto retry;

	return len;
}

/* The set of characters which are valid in short filenames. */
static const char valid_short_name_chars[] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
	'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
	'!', '#', '$', '%', '&', '\'', '(', ')', '-', '@', '^', '_', '`', '{',
	'}', '~',
	/* Note: Windows does not allow space and 128-255 in short filenames
	 * (tested on both NTFS and FAT). */
};

static int
generate_short_name_component(utf16lechar p[], int len)
{
	for (int i = 0; i < len; i++) {
		char c = valid_short_name_chars[rand32() %
						ARRAY_LEN(valid_short_name_chars)];
		p[i] = cpu_to_le16(c);
	}
	return len;
}

/* Generate a random short (8.3) filename and return its length.
 * The @name array must have length >= 13 (8 + 1 + 3 + 1). */
static int
generate_random_short_name(utf16lechar name[], struct generation_context *ctx)
{
	/*
	 * Legal short names on Windows consist of 1 to 8 characters, optionally
	 * followed by a dot then 1 to 3 more characters.  Only certain
	 * characters are allowed.
	 */
	int base_len = 1 + (rand32() % 8);
	int ext_len = rand32() % 4;
	int total_len;

	base_len = generate_short_name_component(name, base_len);

	if (ext_len) {
		name[base_len] = cpu_to_le16('.');
		ext_len = generate_short_name_component(&name[base_len + 1],
							ext_len);
		total_len = base_len + 1 + ext_len;
	} else {
		total_len = base_len;
	}
	name[total_len] = cpu_to_le16('\0');
	return total_len;
}


static const struct {
	u8 num_subauthorities;
	u64 identifier_authority;
	u32 subauthorities[6];
} common_sids[] = {
	{ 1, 0, {0}}, /* NULL_SID  */
	{ 1, 1, {0}}, /* WORLD_SID */
	{ 1, 2, {0}}, /* LOCAL_SID */
	{ 1, 3, {0}}, /* CREATOR_OWNER_SID */
	{ 1, 3, {1}}, /* CREATOR_GROUP_SID */
	{ 1, 3, {2}}, /* CREATOR_OWNER_SERVER_SID */
	{ 1, 3, {3}}, /* CREATOR_GROUP_SERVER_SID */
	// { 0, 5, {}},	 /* NT_AUTHORITY_SID */
	{ 1, 5, {1}}, /* DIALUP_SID */
	{ 1, 5, {2}}, /* NETWORK_SID */
	{ 1, 5, {3}}, /* BATCH_SID */
	{ 1, 5, {4}}, /* INTERACTIVE_SID */
	{ 1, 5, {6}}, /* SERVICE_SID */
	{ 1, 5, {7}}, /* ANONYMOUS_LOGON_SID */
	{ 1, 5, {8}}, /* PROXY_SID */
	{ 1, 5, {9}}, /* SERVER_LOGON_SID */
	{ 1, 5, {10}}, /* SELF_SID */
	{ 1, 5, {11}}, /* AUTHENTICATED_USER_SID */
	{ 1, 5, {12}}, /* RESTRICTED_CODE_SID */
	{ 1, 5, {13}}, /* TERMINAL_SERVER_SID */
	{ 1, 5, {18}}, /* NT AUTHORITY\SYSTEM */
	{ 1, 5, {19}}, /* NT AUTHORITY\LOCAL SERVICE */
	{ 1, 5, {20}}, /* NT AUTHORITY\NETWORK SERVICE */
	{ 5 ,80, {956008885, 3418522649, 1831038044, 1853292631, 2271478464}}, /* trusted installer  */
	{ 2 ,5, {32, 544} } /* BUILTIN\ADMINISTRATORS  */
};

/* Generate a SID and return its size in bytes.  */
static size_t
generate_random_sid(wimlib_SID *sid, struct generation_context *ctx)
{
	u32 r = rand32();

	sid->revision = 1;

	if (r & 1) {
		/* Common SID  */
		r = (r >> 1) % ARRAY_LEN(common_sids);

		sid->sub_authority_count = common_sids[r].num_subauthorities;
		for (int i = 0; i < 6; i++) {
			sid->identifier_authority[i] =
				common_sids[r].identifier_authority >> (40 - i * 8);
		}
		for (int i = 0; i < common_sids[r].num_subauthorities; i++)
			sid->sub_authority[i] = cpu_to_le32(common_sids[r].subauthorities[i]);
	} else {
		/* Random SID  */

		sid->sub_authority_count = 1 + ((r >> 1) % 15);

		for (int i = 0; i < 6; i++)
			sid->identifier_authority[i] = rand8();

		for (int i = 0; i < sid->sub_authority_count; i++)
			sid->sub_authority[i] = cpu_to_le32(rand32());
	}
	return (u8 *)&sid->sub_authority[sid->sub_authority_count] - (u8 *)sid;
}

/* Generate an ACL and return its size in bytes.  */
static size_t
generate_random_acl(wimlib_ACL *acl, bool dacl, struct generation_context *ctx)
{
	u8 *p;
	u16 ace_count;

	ace_count = rand32() % 16;

	acl->revision = 2;
	acl->sbz1 = 0;
	acl->ace_count = cpu_to_le16(ace_count);
	acl->sbz2 = 0;

	p = (u8 *)(acl + 1);

	for (int i = 0; i < ace_count; i++) {
		wimlib_ACCESS_ALLOWED_ACE *ace = (wimlib_ACCESS_ALLOWED_ACE *)p;

		/* ACCESS_ALLOWED, ACCESS_DENIED, or SYSTEM_AUDIT; format is the
		 * same for all  */
		if (dacl)
			ace->hdr.type = rand32() % 2;
		else
			ace->hdr.type = 2;
		ace->hdr.flags = rand8();
		ace->mask = cpu_to_le32(rand32() & 0x001F01FF);

		p += offsetof(wimlib_ACCESS_ALLOWED_ACE, sid) +
			generate_random_sid(&ace->sid, ctx);
		ace->hdr.size = cpu_to_le16(p - (u8 *)ace);
	}

	acl->acl_size = cpu_to_le16(p - (u8 *)acl);
	return p - (u8 *)acl;
}

/* Generate a security descriptor and return its size in bytes.  */
static size_t
generate_random_security_descriptor(void *_desc, struct generation_context *ctx)
{
	wimlib_SECURITY_DESCRIPTOR_RELATIVE *desc = _desc;
	u16 control;
	u8 *p;

	control = rand16();

	control &= (wimlib_SE_DACL_AUTO_INHERITED |
		    wimlib_SE_SACL_AUTO_INHERITED);

	control |= wimlib_SE_SELF_RELATIVE |
		   wimlib_SE_DACL_PRESENT |
		   wimlib_SE_SACL_PRESENT;

	desc->revision = 1;
	desc->sbz1 = 0;
	desc->control = cpu_to_le16(control);

	p = (u8 *)(desc + 1);

	desc->owner_offset = cpu_to_le32(p - (u8 *)desc);
	p += generate_random_sid((wimlib_SID *)p, ctx);

	desc->group_offset = cpu_to_le32(p - (u8 *)desc);
	p += generate_random_sid((wimlib_SID *)p, ctx);

	if ((control & wimlib_SE_DACL_PRESENT) && randbool()) {
		desc->dacl_offset = cpu_to_le32(p - (u8 *)desc);
		p += generate_random_acl((wimlib_ACL *)p, true, ctx);
	} else {
		desc->dacl_offset = cpu_to_le32(0);
	}

	if ((control & wimlib_SE_SACL_PRESENT) && randbool()) {
		desc->sacl_offset = cpu_to_le32(p - (u8 *)desc);
		p += generate_random_acl((wimlib_ACL *)p, false, ctx);
	} else {
		desc->sacl_offset = cpu_to_le32(0);
	}

	return p - (u8 *)desc;
}

static bool
am_root(void)
{
#ifdef _WIN32
	return false;
#else
	return (getuid() == 0);
#endif
}

static u32
generate_uid(void)
{
#ifdef _WIN32
	return 0;
#else
	if (am_root())
		return rand32();
	return getuid();
#endif
}

static u32
generate_gid(void)
{
#ifdef _WIN32
	return 0;
#else
	if (am_root())
		return rand32();
	return getgid();
#endif
}

#ifdef _WIN32
#  ifndef S_IFLNK
#    define S_IFLNK  0120000
#  endif
#  ifndef S_IFSOCK
#    define S_IFSOCK 0140000
#  endif
#endif

static int
set_random_unix_metadata(struct wim_inode *inode)
{
	struct wimlib_unix_data dat;

	dat.uid = generate_uid();
	dat.gid = generate_gid();
	if (inode_is_symlink(inode))
		dat.mode = S_IFLNK | 0777;
	else if (inode->i_attributes & FILE_ATTRIBUTE_DIRECTORY)
		dat.mode = S_IFDIR | 0700 | (rand32() % 07777);
	else if (is_zero_hash(inode_get_hash_of_unnamed_data_stream(inode)) &&
		 randbool() && am_root())
	{
		dat.mode = rand32() % 07777;
		switch (rand32() % 4) {
		case 0:
			dat.mode |= S_IFIFO;
			break;
		case 1:
			dat.mode |= S_IFCHR;
			dat.rdev = 261; /* /dev/zero */
			break;
		case 2:
			dat.mode |= S_IFBLK;
			dat.rdev = 261; /* /dev/zero */
			break;
		default:
			dat.mode |= S_IFSOCK;
			break;
		}
	} else {
		dat.mode = S_IFREG | 0400 | (rand32() % 07777);
	}
	dat.rdev = 0;

	if (!inode_set_unix_data(inode, &dat, UNIX_DATA_ALL))
		return WIMLIB_ERR_NOMEM;

	return 0;
}

static noinline_for_stack int
set_random_xattrs(struct wim_inode *inode)
{
	int num_xattrs = 1 + rand32() % 16;
	char entries[8192];
	struct wim_xattr_entry *entry = (void *)entries;
	size_t entries_size;
	struct wimlib_unix_data unix_data;
#ifdef _WIN32
	const char *prefix = "";
#else
	const char *prefix = "user.";
#endif
	static const char capability_name[] = "security.capability";
	bool generated_capability_xattr = false;

	/*
	 * On Linux, xattrs in the "user" namespace are only permitted on
	 * regular files and directories.  For other types of files we can use
	 * the "trusted" namespace, but this requires root.
	 */
	if (inode_is_symlink(inode) ||
	    (inode_get_unix_data(inode, &unix_data) &&
	     !S_ISREG(unix_data.mode) && !S_ISDIR(unix_data.mode)))
	{
		if (!am_root())
			return 0;
		prefix = "trusted.";
	}

	for (int i = 0; i < num_xattrs; i++) {
		int value_len = rand32() % 64;
		u8 *p;

	#ifdef _WIN32
		if (value_len == 0)
			value_len++;
	#endif

		entry->value_len = cpu_to_le16(value_len);
		entry->flags = 0;

		if (rand32() % 16 == 0 && am_root() &&
		    !generated_capability_xattr) {
			int name_len = sizeof(capability_name) - 1;
			entry->name_len = name_len;
			p = mempcpy(entry->name, capability_name, name_len + 1);
			generated_capability_xattr = true;
		} else {
			int name_len = 1 + rand32() % 64;

			entry->name_len = strlen(prefix) + name_len;
			p = mempcpy(entry->name, prefix, strlen(prefix));
			*p++ = 'A' + i;
			for (int j = 1; j < name_len; j++) {
				do {
				#ifdef _WIN32
					*p = 'A' + rand8() % 26;
				#else
					*p = rand8();
				#endif
				} while (*p == '\0');
				p++;
			}
			*p++ = '\0';
		}
		for (int j = 0; j < value_len; j++)
			*p++ = rand8();

		entry = (void *)p;
	}

	entries_size = (char *)entry - entries;
	wimlib_assert(entries_size > 0 && entries_size <= sizeof(entries));

	if (!inode_set_xattrs(inode, entries, entries_size))
		return WIMLIB_ERR_NOMEM;

	return 0;
}

static int
set_random_metadata(struct wim_inode *inode, struct generation_context *ctx)
{
	u32 attrib = (rand32() & (FILE_ATTRIBUTE_READONLY |
				  FILE_ATTRIBUTE_HIDDEN |
				  FILE_ATTRIBUTE_SYSTEM |
				  FILE_ATTRIBUTE_ARCHIVE |
				  FILE_ATTRIBUTE_NOT_CONTENT_INDEXED |
				  FILE_ATTRIBUTE_COMPRESSED |
				  FILE_ATTRIBUTE_SPARSE_FILE));

	/* File attributes  */
	inode->i_attributes |= attrib;

	/* Timestamps  */
	inode->i_creation_time = generate_random_timestamp();
	inode->i_last_access_time = generate_random_timestamp();
	inode->i_last_write_time = generate_random_timestamp();

	/* Security descriptor  */
	if (randbool()) {
		char desc[8192] __attribute__((aligned(8)));
		size_t size;

		size = generate_random_security_descriptor(desc, ctx);

		wimlib_assert(size <= sizeof(desc));

		inode->i_security_id = sd_set_add_sd(ctx->params->sd_set,
						     desc, size);
		if (unlikely(inode->i_security_id < 0))
			return WIMLIB_ERR_NOMEM;
	}

	/* Object ID  */
	if (rand32() % 32 == 0) {
		struct wimlib_object_id object_id;

		for (int i = 0; i < sizeof(object_id); i++)
			*((u8 *)&object_id + i) = rand8();
		if (!inode_set_object_id(inode, &object_id, sizeof(object_id)))
			return WIMLIB_ERR_NOMEM;
	}

	/* Standard UNIX permissions and special files */
	if (rand32() % 16 == 0) {
		int ret = set_random_unix_metadata(inode);
		if (ret)
			return ret;
	}

	/* Extended attributes */
	if (rand32() % 32 == 0) {
		int ret = set_random_xattrs(inode);
		if (ret)
			return ret;
	}

	return 0;

}

/* Choose a random size for generated file data.  We want to usually generate
 * empty, small, or medium files, but occasionally generate large files.  */
static size_t
select_stream_size(struct generation_context *ctx)
{
	if (ctx->metadata_only)
		return 0;

	switch (rand32() % 2048) {
	default:
		/* Empty  */
		return 0;
	case 600 ... 799:
		/* Microscopic  */
		return rand32() % 64;
	case 800 ... 1319:
		/* Tiny  */
		return rand32() % 4096;
	case 1320 ... 1799:
		/* Small  */
		return rand32() % 32768;
	case 1800 ... 2046:
		/* Medium  */
		return rand32() % 262144;
	case 2047:
		/* Large  */
		return rand32() % 134217728;
	}
}

/* Fill 'buffer' with 'size' bytes of "interesting" file data.  */
static void
generate_data(u8 *buffer, size_t size, struct generation_context *ctx)
{
	size_t mask = -1;
	size_t num_byte_fills = rand32() % 256;

	if (size == 0)
		return;

	/* Start by initializing to a random byte */
	memset(buffer, rand32() % 256, size);

	/* Add some random bytes in some random places */
	for (size_t i = 0; i < num_byte_fills; i++) {
		u8 b = rand8();

		size_t count = ((double)size / (double)num_byte_fills) *
				((double)rand32() / 2e9);
		size_t offset = rand32() & ~mask;

		while (count--) {
			buffer[(offset +
				((rand32()) & mask)) % size] = b;
		}


		if (rand32() % 4 == 0)
			mask = (size_t)-1 << rand32() % 4;
	}

	/* Sometimes add a wave pattern */
	if (rand32() % 8 == 0) {
		double magnitude = rand32() % 128;
		double scale = 1.0 / (1 + (rand32() % 256));

		for (size_t i = 0; i < size; i++)
			buffer[i] += (int)(magnitude * cos(i * scale));
	}

	/* Sometimes add some zero regions (holes) */
	if (rand32() % 4 == 0) {
		size_t num_holes = 1 + (rand32() % 16);
		for (size_t i = 0; i < num_holes; i++) {
			size_t hole_offset = rand32() % size;
			size_t hole_len = min(size - hole_offset,
					      size / (1 + (rand32() % 16)));
			memset(&buffer[hole_offset], 0, hole_len);
		}
	}
}

static noinline_for_stack int
set_random_reparse_point(struct wim_inode *inode, struct generation_context *ctx)
{
	struct reparse_buffer_disk rpbuf;
	size_t rpdatalen;

	inode->i_attributes |= FILE_ATTRIBUTE_REPARSE_POINT;

	if (randbool()) {
		/* Symlink */
		int target_nchars;
		utf16lechar *targets = (utf16lechar *)rpbuf.link.symlink.data;

		inode->i_reparse_tag = WIM_IO_REPARSE_TAG_SYMLINK;

		target_nchars = generate_random_filename(targets, 255, ctx);

		rpbuf.link.substitute_name_offset = cpu_to_le16(0);
		rpbuf.link.substitute_name_nbytes = cpu_to_le16(2*target_nchars);
		rpbuf.link.print_name_offset = cpu_to_le16(2*(target_nchars + 1));
		rpbuf.link.print_name_nbytes = cpu_to_le16(2*target_nchars);
		targets[target_nchars] = cpu_to_le16(0);
		memcpy(&targets[target_nchars + 1], targets, 2*target_nchars);
		targets[target_nchars + 1 + target_nchars] = cpu_to_le16(0);

		rpbuf.link.symlink.flags = cpu_to_le32(SYMBOLIC_LINK_RELATIVE);
		rpdatalen = ((u8 *)targets - rpbuf.rpdata) +
				2*(target_nchars + 1 + target_nchars + 1);
	} else {
		rpdatalen = select_stream_size(ctx) % REPARSE_DATA_MAX_SIZE;
		generate_data(rpbuf.rpdata, rpdatalen, ctx);

		if (rpdatalen >= GUID_SIZE && randbool()) {
			/* Non-Microsoft reparse tag (16-byte GUID required)  */
			u8 *guid = rpbuf.rpdata;
			guid[6] = (guid[6] & 0x0F) | 0x40;
			guid[8] = (guid[8] & 0x3F) | 0x80;
			inode->i_reparse_tag = 0x00000100;
		} else {
			/* Microsoft reparse tag  */
			inode->i_reparse_tag = 0x80000000;
		}
		inode->i_rp_reserved = rand16();
	}

	wimlib_assert(rpdatalen < REPARSE_DATA_MAX_SIZE);

	if (!inode_add_stream_with_data(inode, STREAM_TYPE_REPARSE_POINT,
					NO_STREAM_NAME, rpbuf.rpdata,
					rpdatalen, ctx->params->blob_table))
		return WIMLIB_ERR_NOMEM;

	return 0;
}

static int
add_random_data_stream(struct wim_inode *inode, struct generation_context *ctx,
		       const utf16lechar *stream_name)
{
	void *buffer = NULL;
	size_t size;
	int ret;

	size = select_stream_size(ctx);
	if (size) {
		buffer = MALLOC(size);
		if (!buffer)
			return WIMLIB_ERR_NOMEM;
		generate_data(buffer, size, ctx);
	}

	ret = 0;
	if (!inode_add_stream_with_data(inode, STREAM_TYPE_DATA, stream_name,
					buffer, size, ctx->params->blob_table))
		ret = WIMLIB_ERR_NOMEM;
	FREE(buffer);
	return ret;
}

static int
set_random_streams(struct wim_inode *inode, struct generation_context *ctx)
{
	int ret;
	u32 r;

	/* Reparse point (sometimes)  */
	if (inode->i_attributes & FILE_ATTRIBUTE_REPARSE_POINT) {
		ret = set_random_reparse_point(inode, ctx);
		if (ret)
			return ret;
	}

	/* Unnamed data stream (nondirectories and non-symlinks only)  */
	if (!(inode->i_attributes & FILE_ATTRIBUTE_DIRECTORY) &&
	    !inode_is_symlink(inode)) {
		ret = add_random_data_stream(inode, ctx, NO_STREAM_NAME);
		if (ret)
			return ret;
	}

	/* Named data streams (sometimes)  */
	r = rand32() % 256;
	if (r > 230) {
		utf16lechar stream_name[2] = {cpu_to_le16('a'), '\0'};
		r -= 230;
		while (r--) {
			ret = add_random_data_stream(inode, ctx, stream_name);
			if (ret)
				return ret;
			stream_name[0] =
				cpu_to_le16(le16_to_cpu(stream_name[0]) + 1);
		}
	}

	return 0;
}

static u64
select_inode_number(struct generation_context *ctx)
{
	const struct wim_inode_table *table = ctx->params->inode_table;
	const struct hlist_head *head;
	const struct wim_inode *inode;

	head = &table->array[rand32() % table->capacity];
	hlist_for_each_entry(inode, head, i_hlist_node)
		if (randbool())
			return inode->i_ino;

	return rand32();
}

static u32
select_num_children(u32 depth, struct generation_context *ctx)
{
	const double b = 1.01230;
	u32 r = rand32() % 500;
	return ((pow(b, pow(b, r)) - 1) / pow(depth, 1.5)) +
		(2 - exp(0.04/depth));
}

static bool
is_name_valid_in_win32_namespace(const utf16lechar *name)
{
	const utf16lechar *p;

	static const char * const reserved_names[] = {
		 "CON",  "PRN",  "AUX",  "NUL",
		 "COM1", "COM2", "COM3", "COM4", "COM5",
		 "COM6", "COM7", "COM8", "COM9",
		 "LPT1", "LPT2", "LPT3", "LPT4", "LPT5",
		 "LPT6", "LPT7", "LPT8", "LPT9",
	};

	/* The name must be nonempty. */
	if (!name || !*name)
		return false;

	/* All characters must be valid on Windows. */
	for (p = name; *p; p++)
		if (!is_valid_windows_filename_char(*p))
			return false;

	/* Note: a trailing dot or space is permitted, even though on Windows
	 * such a file can only be accessed using a WinNT-style path. */

	/* The name can't be one of the reserved names or be a reserved name
	 * with an extension.  Case insensitive. */
	for (size_t i = 0; i < ARRAY_LEN(reserved_names); i++) {
		for (size_t j = 0; ; j++) {
			u16 c1 = le16_to_cpu(name[j]);
			u16 c2 = reserved_names[i][j];
			if (c2 == '\0') {
				if (c1 == '\0' || c1 == '.')
					return false;
				break;
			}
			if (upcase[c1] != upcase[c2])
				break;
		}
	}

	return true;
}

static int
set_random_short_name(struct wim_dentry *dir, struct wim_dentry *child,
		      struct generation_context *ctx)
{
	utf16lechar name[12 + 1];
	int name_len;
	u32 hash;
	struct wim_dentry **bucket;

	/* If the long name is not allowed in the Win32 namespace, then it
	 * cannot be assigned a corresponding short name.  */
	if (!is_name_valid_in_win32_namespace(child->d_name))
		return 0;

retry:
	/* Don't select a short name that is already used by a long name within
	 * the same directory.  */
	do {
		name_len = generate_random_short_name(name, ctx);
	} while (get_dentry_child_with_utf16le_name(dir, name, name_len * 2,
						    WIMLIB_CASE_INSENSITIVE));


	/* Don't select a short name that is already used by another short name
	 * within the same directory.  */
	hash = 0;
	for (const utf16lechar *p = name; *p; p++)
		hash = (hash * 31) + le16_to_cpu(*p);
	FREE(child->d_short_name);
	child->d_short_name = memdup(name, (name_len + 1) * 2);
	child->d_short_name_nbytes = name_len * 2;

	if (!child->d_short_name)
		return WIMLIB_ERR_NOMEM;

	bucket = &ctx->used_short_names[hash % ARRAY_LEN(ctx->used_short_names)];

	for (struct wim_dentry *d = *bucket; d != NULL;
	     d = d->d_next_extraction_alias) {
		if (!cmp_utf16le_strings(child->d_short_name, name_len,
					 d->d_short_name, d->d_short_name_nbytes / 2,
					 true)) {
			goto retry;
		}
	}

	if (!is_name_valid_in_win32_namespace(child->d_short_name))
		goto retry;

	child->d_next_extraction_alias = *bucket;
	*bucket = child;
	return 0;
}

static bool
inode_has_short_name(const struct wim_inode *inode)
{
	const struct wim_dentry *dentry;

	inode_for_each_dentry(dentry, inode)
		if (dentry_has_short_name(dentry))
			return true;

	return false;
}

static int
generate_dentry_tree_recursive(struct wim_dentry *dir, u32 depth,
			       struct generation_context *ctx)
{
	u32 num_children = select_num_children(depth, ctx);
	struct wim_dentry *child;
	int ret;

	memset(ctx->used_short_names, 0, sizeof(ctx->used_short_names));

	/* Generate 'num_children' dentries within 'dir'.  Some may be
	 * directories themselves.  */

	for (u32 i = 0; i < num_children; i++) {

		/* Generate the next child dentry.  */
		struct wim_inode *inode;
		u64 ino;
		bool is_directory = (rand32() % 16 <= 6);
		bool is_reparse = (rand32() % 8 == 0);
		utf16lechar name[63 + 1]; /* for UNIX extraction: 63 * 4 <= 255 */
		int name_len;
		struct wim_dentry *duplicate;

		/*
		 * Select an inode number for the new file.  Sometimes choose an
		 * existing inode number (i.e. create a hard link).  However,
		 * wimlib intentionally doesn't honor directory hard links, and
		 * reparse points cannot be represented in the WIM file format
		 * at all; so don't create hard links for such files.
		 */
		if (is_directory || is_reparse)
			ino = 0;
		else
			ino = select_inode_number(ctx);

		/* Create the dentry. */
		ret = inode_table_new_dentry(ctx->params->inode_table, NULL,
					     ino, 0, ino == 0, &child);
		if (ret)
			return ret;

		/* Choose a filename that is unique within the directory.*/
		do {
			name_len = generate_random_filename(name,
							    ARRAY_LEN(name) - 1,
							    ctx);
		} while (get_dentry_child_with_utf16le_name(dir, name, name_len * 2,
							    WIMLIB_CASE_PLATFORM_DEFAULT));

		ret = dentry_set_name_utf16le(child, name, name_len * 2);
		if (ret) {
			free_dentry(child);
			return ret;
		}

		/* Add the dentry to the directory. */
		duplicate = dentry_add_child(dir, child);
		wimlib_assert(!duplicate);

		inode = child->d_inode;

		if (inode->i_nlink > 1)  /* Existing inode?  */
			continue;

		/* New inode; set attributes, metadata, and data.  */

		if (is_directory)
			inode->i_attributes |= FILE_ATTRIBUTE_DIRECTORY;
		if (is_reparse)
			inode->i_attributes |= FILE_ATTRIBUTE_REPARSE_POINT;

		ret = set_random_streams(inode, ctx);
		if (ret)
			return ret;

		ret = set_random_metadata(inode, ctx);
		if (ret)
			return ret;

		/* Recurse if it's a directory.  */
		if (is_directory && !is_reparse) {
			ret = generate_dentry_tree_recursive(child, depth + 1,
							     ctx);
			if (ret)
				return ret;
		}
	}

	for_dentry_child(child, dir) {
		/* sometimes generate a unique short name  */
		if (randbool() && !inode_has_short_name(child->d_inode)) {
			ret = set_random_short_name(dir, child, ctx);
			if (ret)
				return ret;
		}
	}

	return 0;
}

int
generate_dentry_tree(struct wim_dentry **root_ret, const tchar *_ignored,
		     struct scan_params *params)
{
	int ret;
	struct wim_dentry *root = NULL;
	struct generation_context ctx = {
		.params = params,
	};

	ctx.metadata_only = ((rand32() % 8) != 0); /* usually metadata only  */

	ret = inode_table_new_dentry(params->inode_table, NULL, 0, 0, true, &root);
	if (!ret) {
		root->d_inode->i_attributes = FILE_ATTRIBUTE_DIRECTORY;
		ret = set_random_streams(root->d_inode, &ctx);
	}
	if (!ret)
		ret = set_random_metadata(root->d_inode, &ctx);
	if (!ret)
		ret = generate_dentry_tree_recursive(root, 1, &ctx);
	if (!ret)
		*root_ret = root;
	else
		free_dentry_tree(root, params->blob_table);
	return ret;
}

/*----------------------------------------------------------------------------*
 *                            File tree comparison                            *
 *----------------------------------------------------------------------------*/

#define INDEX_NODE_TO_DENTRY(node)	\
	((node) ? avl_tree_entry((node), struct wim_dentry, d_index_node) : NULL)

static struct wim_dentry *
dentry_first_child(struct wim_dentry *dentry)
{
	return INDEX_NODE_TO_DENTRY(
			avl_tree_first_in_order(dentry->d_inode->i_children));
}

static struct wim_dentry *
dentry_next_sibling(struct wim_dentry *dentry)
{
	return INDEX_NODE_TO_DENTRY(
			avl_tree_next_in_order(&dentry->d_index_node));
}

/*
 * Verify that the dentries in the tree 'd1' exactly match the dentries in the
 * tree 'd2', considering long and short filenames.  In addition, set
 * 'd_corresponding' of each dentry to point to the corresponding dentry in the
 * other tree, and set 'i_corresponding' of each inode to point to the
 * unverified corresponding inode in the other tree.
 */
static int
calc_corresponding_files_recursive(struct wim_dentry *d1, struct wim_dentry *d2,
				   int cmp_flags)
{
	struct wim_dentry *child1;
	struct wim_dentry *child2;
	int ret;

	/* Compare long filenames, case sensitively.  */
	if (cmp_utf16le_strings(d1->d_name, d1->d_name_nbytes / 2,
				d2->d_name, d2->d_name_nbytes / 2,
				false))
	{
		ERROR("Filename mismatch; path1=\"%"TS"\", path2=\"%"TS"\"",
		      dentry_full_path(d1), dentry_full_path(d2));
		return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
	}

	/* Compare short filenames, case insensitively.  */
	if (!(d2->d_short_name_nbytes == 0 &&
	      (cmp_flags & WIMLIB_CMP_FLAG_UNIX_MODE)) &&
	    cmp_utf16le_strings(d1->d_short_name, d1->d_short_name_nbytes / 2,
				d2->d_short_name, d2->d_short_name_nbytes / 2,
				true))
	{
		ERROR("Short name mismatch; path=\"%"TS"\"",
		      dentry_full_path(d1));
		return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
	}

	/* Match up the dentries  */
	d1->d_corresponding = d2;
	d2->d_corresponding = d1;

	/* Match up the inodes (may overwrite previous value)  */
	d1->d_inode->i_corresponding = d2->d_inode;
	d2->d_inode->i_corresponding = d1->d_inode;

	/* Process children  */
	child1 = dentry_first_child(d1);
	child2 = dentry_first_child(d2);
	while (child1 || child2) {

		if (!child1 || !child2) {
			ERROR("Child count mismatch; "
			      "path1=\"%"TS"\", path2=\"%"TS"\"",
			      dentry_full_path(d1), dentry_full_path(d2));
			return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
		}

		/* Recurse on this pair of children.  */
		ret = calc_corresponding_files_recursive(child1, child2,
							 cmp_flags);
		if (ret)
			return ret;

		/* Continue to the next pair of children.  */
		child1 = dentry_next_sibling(child1);
		child2 = dentry_next_sibling(child2);
	}
	return 0;
}

/* Perform sanity checks on an image's inodes.  All assertions here should pass,
 * even if the images being compared are different.  */
static void
assert_inodes_sane(const struct wim_image_metadata *imd)
{
	const struct wim_inode *inode;
	const struct wim_dentry *dentry;
	size_t link_count;

	image_for_each_inode(inode, imd) {
		link_count = 0;
		inode_for_each_dentry(dentry, inode) {
			wimlib_assert(dentry->d_inode == inode);
			link_count++;
		}
		wimlib_assert(link_count > 0);
		wimlib_assert(link_count == inode->i_nlink);
		wimlib_assert(inode->i_corresponding != NULL);
	}
}

static int
check_hard_link(struct wim_dentry *dentry, void *_ignore)
{
	/* My inode is my corresponding dentry's inode's corresponding inode,
	 * and my inode's corresponding inode is my corresponding dentry's
	 * inode.  */
	const struct wim_inode *a = dentry->d_inode;
	const struct wim_inode *b = dentry->d_corresponding->d_inode;
	if (a == b->i_corresponding && a->i_corresponding == b)
		return 0;
	ERROR("Hard link difference; path=%"TS"", dentry_full_path(dentry));
	return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
}

static const struct {
	u32 flag;
	const char *name;
} file_attr_flags[] = {
	{FILE_ATTRIBUTE_READONLY,	     "READONLY"},
	{FILE_ATTRIBUTE_HIDDEN,		     "HIDDEN"},
	{FILE_ATTRIBUTE_SYSTEM,		     "SYSTEM"},
	{FILE_ATTRIBUTE_DIRECTORY,	     "DIRECTORY"},
	{FILE_ATTRIBUTE_ARCHIVE,	     "ARCHIVE"},
	{FILE_ATTRIBUTE_DEVICE,		     "DEVICE"},
	{FILE_ATTRIBUTE_NORMAL,		     "NORMAL"},
	{FILE_ATTRIBUTE_TEMPORARY,	     "TEMPORARY"},
	{FILE_ATTRIBUTE_SPARSE_FILE,	     "SPARSE_FILE"},
	{FILE_ATTRIBUTE_REPARSE_POINT,	     "REPARSE_POINT"},
	{FILE_ATTRIBUTE_COMPRESSED,	     "COMPRESSED"},
	{FILE_ATTRIBUTE_OFFLINE,	     "OFFLINE"},
	{FILE_ATTRIBUTE_NOT_CONTENT_INDEXED, "NOT_CONTENT_INDEXED"},
	{FILE_ATTRIBUTE_ENCRYPTED,	     "ENCRYPTED"},
	{FILE_ATTRIBUTE_VIRTUAL,	     "VIRTUAL"},
};

static int
cmp_attributes(const struct wim_inode *inode1,
	       const struct wim_inode *inode2, int cmp_flags)
{
	const u32 changed = inode1->i_attributes ^ inode2->i_attributes;
	const u32 set = inode2->i_attributes & ~inode1->i_attributes;
	const u32 cleared = inode1->i_attributes & ~inode2->i_attributes;

	/* NORMAL may change, but it must never be set along with other
	 * attributes. */
	if ((inode2->i_attributes & FILE_ATTRIBUTE_NORMAL) &&
	    (inode2->i_attributes & ~FILE_ATTRIBUTE_NORMAL))
		goto mismatch;

	/* DIRECTORY may change in UNIX mode for symlinks. */
	if (changed & FILE_ATTRIBUTE_DIRECTORY) {
		if (!(inode_is_symlink(inode1) &&
		      (cmp_flags & WIMLIB_CMP_FLAG_UNIX_MODE)))
			goto mismatch;
	}

	/* REPARSE_POINT may be cleared in UNIX mode if the inode is not a
	 * symlink. */
	if ((changed & FILE_ATTRIBUTE_REPARSE_POINT) &&
	    !((cleared & FILE_ATTRIBUTE_REPARSE_POINT) &&
	      (cmp_flags & WIMLIB_CMP_FLAG_UNIX_MODE) &&
	      !inode_is_symlink(inode1)))
		goto mismatch;

	/* SPARSE_FILE may be cleared.  This is true in UNIX and NTFS-3G modes.
	 * In Windows mode it should only be true for directories, but even on
	 * nondirectories it doesn't work 100% of the time for some reason. */
	if ((changed & FILE_ATTRIBUTE_SPARSE_FILE) &&
	    !(cleared & FILE_ATTRIBUTE_SPARSE_FILE))
		goto mismatch;

	/* COMPRESSED may change in UNIX and NTFS-3G modes.  (It *should* be
	 * preserved in NTFS-3G mode, but it's not implemented yet.) */
	if ((changed & FILE_ATTRIBUTE_COMPRESSED) &&
	    !(cmp_flags & (WIMLIB_CMP_FLAG_UNIX_MODE |
			   WIMLIB_CMP_FLAG_NTFS_3G_MODE)))
		goto mismatch;

	/* All other attributes can change in UNIX mode, but not in any other
	 * mode. */
	if ((changed & ~(FILE_ATTRIBUTE_NORMAL |
			 FILE_ATTRIBUTE_DIRECTORY |
			 FILE_ATTRIBUTE_REPARSE_POINT |
			 FILE_ATTRIBUTE_SPARSE_FILE |
			 FILE_ATTRIBUTE_COMPRESSED)) &&
	    !(cmp_flags & WIMLIB_CMP_FLAG_UNIX_MODE))
		goto mismatch;

	return 0;

mismatch:
	ERROR("Attribute mismatch for %"TS": 0x%08"PRIx32" vs. 0x%08"PRIx32":",
	      inode_any_full_path(inode1), inode1->i_attributes,
	      inode2->i_attributes);
	for (size_t i = 0; i < ARRAY_LEN(file_attr_flags); i++) {
		u32 flag = file_attr_flags[i].flag;
		if (changed & flag) {
			fprintf(stderr, "\tFILE_ATTRIBUTE_%s was %s\n",
				file_attr_flags[i].name,
				(set & flag) ? "set" : "cleared");
		}
	}
	return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
}

static void
print_security_descriptor(const void *desc, size_t size, FILE *fp)
{
	print_byte_field(desc, size, fp);
#ifdef _WIN32
	wchar_t *str = NULL;
	ConvertSecurityDescriptorToStringSecurityDescriptorW(
			(void *)desc,
			SDDL_REVISION_1,
			OWNER_SECURITY_INFORMATION |
				GROUP_SECURITY_INFORMATION |
				DACL_SECURITY_INFORMATION |
				SACL_SECURITY_INFORMATION,
			&str,
			NULL);
	if (str) {
		fprintf(fp, " [ %ls ]", str);
		LocalFree(str);
	}
#endif /* _WIN32 */
}

static int
cmp_security(const struct wim_inode *inode1, const struct wim_inode *inode2,
	     const struct wim_image_metadata *imd1,
	     const struct wim_image_metadata *imd2, int cmp_flags)
{
	/*
	 * Unfortunately this has to be disabled on Windows for now, since
	 * Windows changes security descriptors upon backup/restore in ways that
	 * are difficult to replicate...
	 */
	if (cmp_flags & WIMLIB_CMP_FLAG_WINDOWS_MODE)
		return 0;

	if (inode_has_security_descriptor(inode1)) {
		if (inode_has_security_descriptor(inode2)) {
			const void *desc1 = imd1->security_data->descriptors[inode1->i_security_id];
			const void *desc2 = imd2->security_data->descriptors[inode2->i_security_id];
			size_t size1 = imd1->security_data->sizes[inode1->i_security_id];
			size_t size2 = imd2->security_data->sizes[inode2->i_security_id];

			if (size1 != size2 || memcmp(desc1, desc2, size1)) {
				ERROR("Security descriptor of %"TS" differs!",
				      inode_any_full_path(inode1));
				fprintf(stderr, "desc1=");
				print_security_descriptor(desc1, size1, stderr);
				fprintf(stderr, "\ndesc2=");
				print_security_descriptor(desc2, size2, stderr);
				fprintf(stderr, "\n");
				return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
			}
		} else if (!(cmp_flags & WIMLIB_CMP_FLAG_UNIX_MODE)) {
			ERROR("%"TS" has a security descriptor in the first image but "
			      "not in the second image!", inode_any_full_path(inode1));
			return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
		}
	} else if (inode_has_security_descriptor(inode2)) {
		/* okay --- consider it acceptable if a default security
		 * descriptor was assigned  */
		/*ERROR("%"TS" has a security descriptor in the second image but "*/
		      /*"not in the first image!", inode_any_full_path(inode1));*/
		/*return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;*/
	}
	return 0;
}

static int
cmp_object_ids(const struct wim_inode *inode1,
	       const struct wim_inode *inode2, int cmp_flags)
{
	const void *objid1, *objid2;
	u32 len1, len2;

	objid1 = inode_get_object_id(inode1, &len1);
	objid2 = inode_get_object_id(inode2, &len2);

	if (!objid1 && !objid2)
		return 0;

	if (objid1 && !objid2) {
		if (cmp_flags & WIMLIB_CMP_FLAG_UNIX_MODE)
			return 0;
		ERROR("%"TS" unexpectedly lost its object ID",
		      inode_any_full_path(inode1));
		return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
	}

	if (!objid1 && objid2) {
		ERROR("%"TS" unexpectedly gained an object ID",
		      inode_any_full_path(inode1));
		return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
	}

	if (len1 != len2 || memcmp(objid1, objid2, len1) != 0) {
		ERROR("Object ID of %"TS" differs",
		      inode_any_full_path(inode1));
		fprintf(stderr, "objid1=");
		print_byte_field(objid1, len1, stderr);
		fprintf(stderr, "\nobjid2=");
		print_byte_field(objid2, len2, stderr);
		fprintf(stderr, "\n");
		return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
	}

	return 0;
}

static int
cmp_unix_metadata(const struct wim_inode *inode1,
		  const struct wim_inode *inode2, int cmp_flags)
{
	struct wimlib_unix_data dat1, dat2;
	bool present1, present2;

	present1 = inode_get_unix_data(inode1, &dat1);
	present2 = inode_get_unix_data(inode2, &dat2);

	if (!present1 && !present2)
		return 0;

	if (present1 && !present2) {
		if (cmp_flags & (WIMLIB_CMP_FLAG_NTFS_3G_MODE |
				 WIMLIB_CMP_FLAG_WINDOWS_MODE))
			return 0;
		ERROR("%"TS" unexpectedly lost its UNIX metadata",
		      inode_any_full_path(inode1));
		return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
	}

	if (!present1 && present2) {
		if (cmp_flags & WIMLIB_CMP_FLAG_UNIX_MODE)
			return 0;
		ERROR("%"TS" unexpectedly gained UNIX metadata",
		      inode_any_full_path(inode1));
		return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
	}

	if (memcmp(&dat1, &dat2, sizeof(dat1)) != 0) {
		ERROR("UNIX metadata of %"TS" differs: "
		      "[uid=%u, gid=%u, mode=0%o, rdev=%u] vs. "
		      "[uid=%u, gid=%u, mode=0%o, rdev=%u]",
		      inode_any_full_path(inode1),
		      dat1.uid, dat1.gid, dat1.mode, dat1.rdev,
		      dat2.uid, dat2.gid, dat2.mode, dat2.rdev);
		return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
	}

	return 0;
}

static int
cmp_xattr_names(const void *p1, const void *p2)
{
	const struct wim_xattr_entry *entry1 = *(const struct wim_xattr_entry **)p1;
	const struct wim_xattr_entry *entry2 = *(const struct wim_xattr_entry **)p2;
	int res;

	res = entry1->name_len - entry2->name_len;
	if (res)
		return res;

	return memcmp(entry1->name, entry2->name, entry1->name_len);
}

/* Validate and sort by name a list of extended attributes */
static int
parse_xattrs(const void *xattrs, u32 len,
	     const struct wim_xattr_entry *entries[],
	     u32 *num_entries_p)
{
	u32 limit = *num_entries_p;
	u32 num_entries = 0;
	const struct wim_xattr_entry *entry = xattrs;

	while ((void *)entry < xattrs + len) {
		if (!valid_xattr_entry(entry, xattrs + len - (void *)entry)) {
			ERROR("Invalid xattr entry");
			return WIMLIB_ERR_INVALID_XATTR;
		}
		if (num_entries >= limit) {
			ERROR("Too many xattr entries");
			return WIMLIB_ERR_INVALID_XATTR;
		}
		entries[num_entries++] = entry;
		entry = xattr_entry_next(entry);
	}

	if (num_entries == 0) {
		ERROR("No xattr entries");
		return WIMLIB_ERR_INVALID_XATTR;
	}

	qsort(entries, num_entries, sizeof(entries[0]), cmp_xattr_names);

	for (u32 i = 1; i < num_entries; i++) {
		if (cmp_xattr_names(&entries[i - 1], &entries[i]) == 0) {
			ERROR("Duplicate xattr names");
			return WIMLIB_ERR_INVALID_XATTR;
		}
	}

	*num_entries_p = num_entries;
	return 0;
}

static int
cmp_xattrs(const struct wim_inode *inode1, const struct wim_inode *inode2,
	   int cmp_flags)
{
	const void *xattrs1, *xattrs2;
	u32 len1, len2;

	xattrs1 = inode_get_xattrs(inode1, &len1);
	xattrs2 = inode_get_xattrs(inode2, &len2);

	if (!xattrs1 && !xattrs2) {
		return 0;
	} else if (xattrs1 && !xattrs2) {
		if (cmp_flags & WIMLIB_CMP_FLAG_NTFS_3G_MODE)
			return 0;
		ERROR("%"TS" unexpectedly lost its xattrs",
		      inode_any_full_path(inode1));
		return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
	} else if (!xattrs1 && xattrs2) {
		ERROR("%"TS" unexpectedly gained xattrs",
		      inode_any_full_path(inode1));
		return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
	} else {
		const int max_entries = 64;
		const struct wim_xattr_entry *entries1[max_entries];
		const struct wim_xattr_entry *entries2[max_entries];
		u32 xattr_count1 = max_entries;
		u32 xattr_count2 = max_entries;
		int ret;

		ret = parse_xattrs(xattrs1, len1, entries1, &xattr_count1);
		if (ret) {
			ERROR("%"TS": invalid xattrs",
			      inode_any_full_path(inode1));
			return ret;
		}
		ret = parse_xattrs(xattrs2, len2, entries2, &xattr_count2);
		if (ret) {
			ERROR("%"TS": invalid xattrs",
			      inode_any_full_path(inode2));
			return ret;
		}
		if (xattr_count1 != xattr_count2) {
			ERROR("%"TS": number of xattrs changed.  had %u "
			      "before, now has %u", inode_any_full_path(inode1),
			      xattr_count1, xattr_count2);
		}
		for (u32 i = 0; i < xattr_count1; i++) {
			const struct wim_xattr_entry *entry1 = entries1[i];
			const struct wim_xattr_entry *entry2 = entries2[i];

			if (entry1->value_len != entry2->value_len ||
			    entry1->name_len != entry2->name_len ||
			    entry1->flags != entry2->flags ||
			    memcmp(entry1->name, entry2->name,
				   entry1->name_len) ||
			    memcmp(entry1->name + entry1->name_len + 1,
				   entry2->name + entry2->name_len + 1,
				   le16_to_cpu(entry1->value_len)))
			{
				ERROR("xattr %.*s of %"TS" differs",
				      entry1->name_len, entry1->name,
				      inode_any_full_path(inode1));
				return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
			}
		}
		return 0;
	}
}

/*
 * ext4 only supports timestamps from years 1901 to 2446, more specifically the
 * range [-0x80000000, 0x380000000) seconds relative to the start of UNIX epoch.
 */
static bool
in_ext4_range(u64 ts)
{
	return ts >= time_t_to_wim_timestamp(-0x80000000LL) &&
		ts < time_t_to_wim_timestamp(0x380000000LL);
}

static bool
timestamps_differ(u64 ts1, u64 ts2, int cmp_flags)
{
	if (ts1 == ts2)
		return false;
	if ((cmp_flags & WIMLIB_CMP_FLAG_EXT4) &&
	    (!in_ext4_range(ts1) || !in_ext4_range(ts2)))
		return false;
	return true;
}

static int
cmp_timestamps(const struct wim_inode *inode1, const struct wim_inode *inode2,
	       int cmp_flags)
{
	if (timestamps_differ(inode1->i_creation_time,
			      inode2->i_creation_time, cmp_flags) &&
	    !(cmp_flags & WIMLIB_CMP_FLAG_UNIX_MODE)) {
		ERROR("Creation time of %"TS" differs; %"PRIu64" != %"PRIu64,
		      inode_any_full_path(inode1),
		      inode1->i_creation_time, inode2->i_creation_time);
		return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
	}

	if (timestamps_differ(inode1->i_last_write_time,
			      inode2->i_last_write_time, cmp_flags)) {
		ERROR("Last write time of %"TS" differs; %"PRIu64" != %"PRIu64,
		      inode_any_full_path(inode1),
		      inode1->i_last_write_time, inode2->i_last_write_time);
		return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
	}

	if (timestamps_differ(inode1->i_last_access_time,
			      inode2->i_last_access_time, cmp_flags) &&
	    /*
	     * On Windows, sometimes a file's last access time will end up as
	     * the current time rather than the expected time.  Maybe caused by
	     * some OS process scanning the files?
	     */
	    !(cmp_flags & WIMLIB_CMP_FLAG_WINDOWS_MODE)) {
		ERROR("Last access time of %"TS" differs; %"PRIu64" != %"PRIu64,
		      inode_any_full_path(inode1),
		      inode1->i_last_access_time, inode2->i_last_access_time);
		return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
	}

	return 0;
}

static int
cmp_inodes(const struct wim_inode *inode1, const struct wim_inode *inode2,
	   const struct wim_image_metadata *imd1,
	   const struct wim_image_metadata *imd2, int cmp_flags)
{
	int ret;

	/* Compare attributes  */
	ret = cmp_attributes(inode1, inode2, cmp_flags);
	if (ret)
		return ret;

	/* Compare security descriptors  */
	ret = cmp_security(inode1, inode2, imd1, imd2, cmp_flags);
	if (ret)
		return ret;

	/* Compare streams  */
	for (unsigned i = 0; i < inode1->i_num_streams; i++) {
		const struct wim_inode_stream *strm1 = &inode1->i_streams[i];
		const struct wim_inode_stream *strm2;

		if (strm1->stream_type == STREAM_TYPE_REPARSE_POINT &&
		    (cmp_flags & WIMLIB_CMP_FLAG_UNIX_MODE &&
		     !inode_is_symlink(inode1)))
			continue;

		if (strm1->stream_type == STREAM_TYPE_UNKNOWN)
			continue;

		/* Get the corresponding stream from the second file  */
		strm2 = inode_get_stream(inode2, strm1->stream_type, strm1->stream_name);

		if (!strm2) {
			/* Corresponding stream not found  */
			if (stream_is_named(strm1) &&
			    (cmp_flags & WIMLIB_CMP_FLAG_UNIX_MODE))
				continue;
			ERROR("Stream of %"TS" is missing in second image; "
			      "type %d, named=%d, empty=%d",
			      inode_any_full_path(inode1),
			      strm1->stream_type,
			      stream_is_named(strm1),
			      is_zero_hash(stream_hash(strm1)));
			return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
		}

		if (!hashes_equal(stream_hash(strm1), stream_hash(strm2))) {
			ERROR("Stream of %"TS" differs; type %d",
			      inode_any_full_path(inode1), strm1->stream_type);
			return WIMLIB_ERR_IMAGES_ARE_DIFFERENT;
		}
	}

	/* Compare object IDs  */
	ret = cmp_object_ids(inode1, inode2, cmp_flags);
	if (ret)
		return ret;

	/* Compare timestamps  */
	ret = cmp_timestamps(inode1, inode2, cmp_flags);
	if (ret)
		return ret;

	/* Compare standard UNIX metadata  */
	ret = cmp_unix_metadata(inode1, inode2, cmp_flags);
	if (ret)
		return ret;

	/* Compare extended attributes  */
	ret = cmp_xattrs(inode1, inode2, cmp_flags);
	if (ret)
		return ret;

	return 0;
}

static int
cmp_images(const struct wim_image_metadata *imd1,
	   const struct wim_image_metadata *imd2, int cmp_flags)
{
	struct wim_dentry *root1 = imd1->root_dentry;
	struct wim_dentry *root2 = imd2->root_dentry;
	const struct wim_inode *inode;
	int ret;

	ret = calc_corresponding_files_recursive(root1, root2, cmp_flags);
	if (ret)
		return ret;

	/* Verify that the hard links match up between the two images.  */
	assert_inodes_sane(imd1);
	assert_inodes_sane(imd2);
	ret = for_dentry_in_tree(root1, check_hard_link, NULL);
	if (ret)
		return ret;

	/* Compare corresponding inodes.  */
	image_for_each_inode(inode, imd1) {
		ret = cmp_inodes(inode, inode->i_corresponding,
				 imd1, imd2, cmp_flags);
		if (ret)
			return ret;
	}

	return 0;
}

static int
load_image(WIMStruct *wim, int image, struct wim_image_metadata **imd_ret)
{
	int ret = select_wim_image(wim, image);
	if (!ret) {
		*imd_ret = wim_get_current_image_metadata(wim);
		mark_image_dirty(*imd_ret);
	}
	return ret;
}

WIMLIBAPI int
wimlib_compare_images(WIMStruct *wim1, int image1,
		      WIMStruct *wim2, int image2, int cmp_flags)
{
	int ret;
	struct wim_image_metadata *imd1, *imd2;

	ret = load_image(wim1, image1, &imd1);
	if (!ret)
		ret = load_image(wim2, image2, &imd2);
	if (!ret)
		ret = cmp_images(imd1, imd2, cmp_flags);
	return ret;
}

#endif /* ENABLE_TEST_SUPPORT */
