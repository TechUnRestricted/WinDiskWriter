#ifndef _WIMLIB_X86_CPU_FEATURES_H
#define _WIMLIB_X86_CPU_FEATURES_H

#include "types.h"

#if defined(__i386__) || defined(__x86_64__)

#define X86_CPU_FEATURE_SSE		0x00000001
#define X86_CPU_FEATURE_SSE2		0x00000002
#define X86_CPU_FEATURE_SSE3		0x00000004
#define X86_CPU_FEATURE_SSSE3		0x00000008
#define X86_CPU_FEATURE_SSE4_1		0x00000010
#define X86_CPU_FEATURE_SSE4_2		0x00000020
#define X86_CPU_FEATURE_AVX		0x00000040
#define X86_CPU_FEATURE_BMI		0x00000080
#define X86_CPU_FEATURE_AVX2		0x00000100
#define X86_CPU_FEATURE_BMI2		0x00000200

#define X86_CPU_FEATURES_KNOWN		0x80000000

extern u32 _x86_cpu_features;

extern void
x86_setup_cpu_features(void);

/* Does the processor has the specified feature?  */
static inline bool
x86_have_cpu_feature(u32 feature)
{
	if (!(_x86_cpu_features & X86_CPU_FEATURES_KNOWN))
		x86_setup_cpu_features();
	return _x86_cpu_features & feature;
}

#else

static inline bool
x86_have_cpu_feature(u32 feature)
{
	return false;
}

#endif /* __i386__ || __x86_64__ */

#endif /* _WIMLIB_X86_CPU_FEATURES_H */
