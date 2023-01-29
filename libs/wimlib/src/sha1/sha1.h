/*
 * sha1.h
 *
 * Copyright 2022 Eric Biggers
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef _WIMLIB_SHA1_H
#define _WIMLIB_SHA1_H

#include <string.h>

#include "types.h"
#include "util.h"

#define SHA1_HASH_SIZE 20

extern const u8 zero_hash[SHA1_HASH_SIZE];

extern void
sprint_hash(const u8 hash[SHA1_HASH_SIZE], tchar strbuf[SHA1_HASH_SIZE * 2 + 1]);

static inline void
copy_hash(u8 dest[SHA1_HASH_SIZE], const u8 src[SHA1_HASH_SIZE])
{
	memcpy(dest, src, SHA1_HASH_SIZE);
}

static inline int
hashes_cmp(const u8 h1[SHA1_HASH_SIZE], const u8 h2[SHA1_HASH_SIZE])
{
	return memcmp(h1, h2, SHA1_HASH_SIZE);
}

static inline bool
hashes_equal(const u8 h1[SHA1_HASH_SIZE], const u8 h2[SHA1_HASH_SIZE])
{
	return !hashes_cmp(h1, h2);
}

static inline bool
is_zero_hash(const u8 *hash)
{
	return (hash == zero_hash || hashes_equal(hash, zero_hash));
}

#ifdef WITH_LIBCRYPTO

#include <openssl/sha.h>

#define sha1_init     SHA1_Init
#define sha1_update   SHA1_Update
#define sha1_final    SHA1_Final

static inline void
sha1_buffer(const void *buffer, size_t len, u8 hash[SHA1_HASH_SIZE])
{
	SHA1(buffer, len, hash);
}

#else /* WITH_LIBCRYPTO */

typedef struct {
	u64 bytecount;
	u32 state[5];
	u8 buffer[64];
} SHA_CTX;

extern void
sha1_init(SHA_CTX *ctx);

extern void
sha1_update(SHA_CTX *ctx, const void *data, size_t len);

extern void
sha1_final(u8 hash[SHA1_HASH_SIZE], SHA_CTX *ctx);

extern void
sha1_buffer(const void *buffer, size_t len, u8 hash[SHA1_HASH_SIZE]);

#endif /* !WITH_LIBCRYPTO */

#endif /* _WIMLIB_SHA1_H */
