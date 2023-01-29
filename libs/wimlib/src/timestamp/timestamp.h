/*
 * timestamp.h
 *
 * Conversion between Windows NT timestamps and UNIX timestamps.
 */

#ifndef _WIMLIB_TIMESTAMP_H
#define _WIMLIB_TIMESTAMP_H

#include <sys/time.h>
#include <time.h>

#include "types.h"

struct wimlib_timespec;

extern time_t
wim_timestamp_to_time_t(u64 timestamp);

extern void
wim_timestamp_to_wimlib_timespec(u64 timestamp, struct wimlib_timespec *wts,
				 s32 *high_part_ret);

extern struct timeval
wim_timestamp_to_timeval(u64 timestamp);

extern struct timespec
wim_timestamp_to_timespec(u64 timestamp);

extern u64
time_t_to_wim_timestamp(time_t t);

extern u64
timeval_to_wim_timestamp(const struct timeval *tv);

extern u64
timespec_to_wim_timestamp(const struct timespec *ts);

extern u64
now_as_wim_timestamp(void);

extern void
wim_timestamp_to_str(u64 timestamp, tchar *buf, size_t len);

#endif /* _WIMLIB_TIMESTAMP_H */
