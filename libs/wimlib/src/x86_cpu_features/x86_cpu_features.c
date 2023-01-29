/*
 * x86_cpu_features.c - feature detection for x86 processors
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

#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif

#include "x86_cpu_features.h"

#if defined(__i386__) || defined(__x86_64__)

#define DEBUG 0

#if DEBUG
#  include <stdio.h>
#endif

u32 _x86_cpu_features = 0;

/* With old GCC versions we have to manually save and restore the x86_32 PIC
 * register (ebx).  See: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=47602  */
#if defined(__i386__) && defined(__PIC__)
#  define EBX_CONSTRAINT "=r"
#else
#  define EBX_CONSTRAINT "=b"
#endif

/* Execute the CPUID instruction.  */
static inline void
cpuid(u32 leaf, u32 subleaf, u32 *a, u32 *b, u32 *c, u32 *d)
{
	__asm__(".ifnc %%ebx, %1; mov  %%ebx, %1; .endif\n"
		"cpuid                                  \n"
		".ifnc %%ebx, %1; xchg %%ebx, %1; .endif\n"
		: "=a" (*a), EBX_CONSTRAINT (*b), "=c" (*c), "=d" (*d)
		: "a" (leaf), "c" (subleaf));
}

/* Read an extended control register.  */
static inline u64
read_xcr(u32 index)
{
	u32 edx, eax;

	/* Execute the "xgetbv" instruction.  Old versions of binutils do not
	 * recognize this instruction, so list the raw bytes instead.  */
	__asm__ (".byte 0x0f, 0x01, 0xd0" : "=d" (edx), "=a" (eax) : "c" (index));

	return ((u64)edx << 32) | eax;
}

#define IS_SET(reg, bit) ((reg) & ((u32)1 << (bit)))

/* Initialize _x86_cpu_features with bits for interesting processor features. */
void
x86_setup_cpu_features(void)
{
	u32 features = 0;
	u32 dummy1, dummy2, dummy3, dummy4;
	u32 max_function;
	u32 features_1, features_2, features_3, features_4;
	bool os_saves_ymm_regs = false;

	/* Get maximum supported function  */
	cpuid(0, 0, &max_function, &dummy2, &dummy3, &dummy4);
	if (max_function < 1)
		goto out;

	/* Standard feature flags  */
	cpuid(1, 0, &dummy1, &dummy2, &features_2, &features_1);

	if (IS_SET(features_1, 25))
		features |= X86_CPU_FEATURE_SSE;

	if (IS_SET(features_1, 26))
		features |= X86_CPU_FEATURE_SSE2;

	if (IS_SET(features_2, 0))
		features |= X86_CPU_FEATURE_SSE3;

	if (IS_SET(features_2, 9))
		features |= X86_CPU_FEATURE_SSSE3;

	if (IS_SET(features_2, 19))
		features |= X86_CPU_FEATURE_SSE4_1;

	if (IS_SET(features_2, 20))
		features |= X86_CPU_FEATURE_SSE4_2;

	if (IS_SET(features_2, 27)) /* OSXSAVE set?  */
		if ((read_xcr(0) & 0x6) == 0x6)
			os_saves_ymm_regs = true;

	if (os_saves_ymm_regs && IS_SET(features_2, 28))
		features |= X86_CPU_FEATURE_AVX;

	if (max_function < 7)
		goto out;

	/* Extended feature flags  */
	cpuid(7, 0, &dummy1, &features_3, &features_4, &dummy4);

	if (IS_SET(features_3, 3))
		features |= X86_CPU_FEATURE_BMI;

	if (os_saves_ymm_regs && IS_SET(features_3, 5))
		features |= X86_CPU_FEATURE_AVX2;

	if (IS_SET(features_3, 8))
		features |= X86_CPU_FEATURE_BMI2;

out:

#if DEBUG
	printf("Detected x86 CPU features: ");
	if (features & X86_CPU_FEATURE_SSE)
		printf("SSE ");
	if (features & X86_CPU_FEATURE_SSE2)
		printf("SSE2 ");
	if (features & X86_CPU_FEATURE_SSE3)
		printf("SSE3 ");
	if (features & X86_CPU_FEATURE_SSSE3)
		printf("SSSE3 ");
	if (features & X86_CPU_FEATURE_SSE4_1)
		printf("SSE4.1 ");
	if (features & X86_CPU_FEATURE_SSE4_2)
		printf("SSE4.2 ");
	if (features & X86_CPU_FEATURE_BMI)
		printf("BMI ");
	if (features & X86_CPU_FEATURE_AVX)
		printf("AVX ");
	if (features & X86_CPU_FEATURE_BMI2)
		printf("BMI2 ");
	if (features & X86_CPU_FEATURE_AVX2)
		printf("AVX2 ");
	printf("\n");
#endif /* DEBUG */

	_x86_cpu_features = features | X86_CPU_FEATURES_KNOWN;
}

#endif /* __i386__ || __x86_64__ */
