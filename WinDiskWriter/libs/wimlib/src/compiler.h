/*
 * compiler.h
 *
 * Compiler-specific definitions.  Currently, only GCC and clang are supported.
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

#ifndef _WIMLIB_COMPILER_H
#define _WIMLIB_COMPILER_H

/* Is the compiler GCC of the specified version or later?  This always returns
 * false for clang, since clang is "frozen" at GNUC 4.2.  The __has_*
 * feature-test macros should be used to detect clang functionality instead.  */
#define GCC_PREREQ(major, minor)					\
	(!defined(__clang__) && !defined(__INTEL_COMPILER) &&		\
	 (__GNUC__ > major ||						\
	  (__GNUC__ == major && __GNUC_MINOR__ >= minor)))

/* Feature-test macros defined by recent versions of clang.  */
#ifndef __has_attribute
#  define __has_attribute(attribute)	0
#endif
#ifndef __has_feature
#  define __has_feature(feature)	0
#endif
#ifndef __has_builtin
#  define __has_builtin(builtin)	0
#endif

/* Declare that the annotated function should be exported from the shared
 * library (or DLL).  */
#ifdef __WIN32__
#  define WIMLIBAPI __declspec(dllexport)
#else
#  define WIMLIBAPI __attribute__((visibility("default")))
#endif

/* Declare that the annotated function should always be inlined.  This might be
 * desirable in highly tuned code, e.g. compression codecs.  */
#define forceinline		inline __attribute__((always_inline))

/* Declare that the annotated function should *not* be inlined.  */
#define noinline		__attribute__((noinline))

/* Functionally the same as 'noinline', but documents that the reason for not
 * inlining is to prevent the annotated function from being inlined into a
 * recursive function, thereby increasing its stack usage.  */
#define noinline_for_stack	noinline

/* Hint that the expression is usually true.  */
#define likely(expr)		__builtin_expect(!!(expr), 1)

/* Hint that the expression is usually false.  */
#define unlikely(expr)		__builtin_expect(!!(expr), 0)

/* Prefetch into L1 cache for read.  */
#define prefetchr(addr)		__builtin_prefetch((addr), 0)

/* Prefetch into L1 cache for write.  */
#define prefetchw(addr)		__builtin_prefetch((addr), 1)

/* Declare that the members of the annotated struct are tightly packed, and the
 * struct itself may be misaligned.  */
#define _packed_attribute	__attribute__((packed))

/* Declare that the annotated variable, or variables of the annotated type, are
 * to be aligned on n-byte boundaries.  */
#define _aligned_attribute(n)	__attribute__((aligned(n)))

/* Declare that pointers to the annotated type may alias other pointers.  */
#define _may_alias_attribute	__attribute__((may_alias))

/* Hint that the annotated function is rarely called.  */
#if GCC_PREREQ(4, 4) || __has_attribute(cold)
#  define _cold_attribute	__attribute__((cold))
#else
#  define _cold_attribute
#endif

/* Hint that the annotated function takes a printf()-like format string and
 * arguments.  This is currently disabled on Windows because MinGW does not
 * support this attribute on functions taking wide-character strings.  */
#ifdef __WIN32__
#  define _format_attribute(type, format_str, format_start)
#else
#  define _format_attribute(type, format_str, format_start)	\
			__attribute__((format(type, format_str, format_start)))
#endif

/* Hint that the annotated function is intentionally not used.  This might be
 * the case if the function contains only static assertions.  */
#define _unused_attribute	__attribute__((unused))

/* Endianness definitions.  Either CPU_IS_BIG_ENDIAN() or CPU_IS_LITTLE_ENDIAN()
 * evaluates to 1.  The other evaluates to 0.  Note that newer gcc supports
 * __BYTE_ORDER__ for easily determining the endianness; older gcc doesn't.  In
 * the latter case we fall back to a configure-time check.  */
#ifdef __BYTE_ORDER__
#  define CPU_IS_BIG_ENDIAN()	(__BYTE_ORDER__ == __ORDER_BIG_ENDIAN__)
#elif defined(HAVE_CONFIG_H)
#  include "config.h"
#  ifdef WORDS_BIGENDIAN
#    define CPU_IS_BIG_ENDIAN()	1
#  else
#    define CPU_IS_BIG_ENDIAN()	0
#  endif
#endif
#define CPU_IS_LITTLE_ENDIAN() (!CPU_IS_BIG_ENDIAN())

/* UNALIGNED_ACCESS_IS_FAST should be defined to 1 if unaligned memory accesses
 * can be performed efficiently on the target platform.  */
#if defined(__x86_64__) || defined(__i386__) || defined(__ARM_FEATURE_UNALIGNED)
#  define UNALIGNED_ACCESS_IS_FAST 1
#else
#  define UNALIGNED_ACCESS_IS_FAST 0
#endif

/* Get the type of the specified expression.  */
#define typeof     __typeof__

/* Get the minimum of two variables, without multiple evaluation.  */
#ifndef min
#  define min(a, b)  ({ typeof(a) _a = (a); typeof(b) _b = (b); \
			(_a < _b) ? _a : _b; })
#endif
#define MIN(a, b)	min((a), (b))

/* Get the maximum of two variables, without multiple evaluation.  */
#ifndef max
#  define max(a, b)  ({ typeof(a) _a = (a); typeof(b) _b = (b); \
			(_a > _b) ? _a : _b; })
#endif
#define MAX(a, b)	max((a), (b))

/* Swap the values of two variables, without multiple evaluation.  */
#ifndef swap
#  define swap(a, b) ({ typeof(a) _a = (a); (a) = (b); (b) = _a; })
#endif
#define SWAP(a, b)	swap((a), (b))

/* (Optional) Efficiently swap the bytes of a 16-bit integer.  */
#if GCC_PREREQ(4, 8) || __has_builtin(__builtin_bswap16)
#  define compiler_bswap16 __builtin_bswap16
#endif

/* (Optional) Efficiently swap the bytes of a 32-bit integer.  */
#if GCC_PREREQ(4, 3) || __has_builtin(__builtin_bswap32)
#  define compiler_bswap32 __builtin_bswap32
#endif

/* (Optional) Efficiently swap the bytes of a 64-bit integer.  */
#if GCC_PREREQ(4, 3) || __has_builtin(__builtin_bswap64)
#  define compiler_bswap64 __builtin_bswap64
#endif

/* (Optional) Find Last Set bit and Find First Set bit macros.  */
#define compiler_bsr32(n)	(31 - __builtin_clz(n))
#define compiler_bsr64(n)	(63 - __builtin_clzll(n))
#define compiler_bsf32(n)	__builtin_ctz(n)
#define compiler_bsf64(n)	__builtin_ctzll(n)

/* Optional definitions for checking with 'sparse'.  */
#ifdef __CHECKER__
#  define _bitwise_attr	__attribute__((bitwise))
#  define _force_attr	__attribute__((force))
#else
#  define _bitwise_attr
#  define _force_attr
#endif

/* STATIC_ASSERT() - verify the truth of an expression at compilation time.  */
#ifdef __CHECKER__
#  define STATIC_ASSERT(expr)
#elif __STDC_VERSION__ >= 201112L
#  define STATIC_ASSERT(expr)	_Static_assert((expr), "")
#else
#  define STATIC_ASSERT(expr)	((void)sizeof(char[1 - 2 * !(expr)]))
#endif

/* STATIC_ASSERT_ZERO() - verify the truth of an expression at compilation time
 * and also produce a result of value '0' to be used in constant expressions */
#define STATIC_ASSERT_ZERO(expr) ((int)sizeof(char[-!(expr)]))

#define CONCAT_IMPL(s1, s2)	s1##s2

/* CONCAT() - concatenate two tokens at preprocessing time.  */
#define CONCAT(s1, s2)		CONCAT_IMPL(s1, s2)

#endif /* _WIMLIB_COMPILER_H */
