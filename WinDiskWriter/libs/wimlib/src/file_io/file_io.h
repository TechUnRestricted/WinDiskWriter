#ifndef _WIMLIB_FILE_IO_H
#define _WIMLIB_FILE_IO_H

#include <stdbool.h>
#include <stddef.h>
#include <sys/types.h>

/* Wrapper around a file descriptor that keeps track of offset (including in
 * pipes, which don't support lseek()) and a cached flag that tells whether the
 * file descriptor is a pipe or not.  */
struct filedes {
	int fd;
	unsigned int is_pipe : 1;
	off_t offset;
};

extern int
full_read(struct filedes *fd, void *buf, size_t n);

extern int
full_pread(struct filedes *fd, void *buf, size_t nbyte, off_t offset);

extern int
full_write(struct filedes *fd, const void *buf, size_t n);

extern int
full_pwrite(struct filedes *fd, const void *buf, size_t count, off_t offset);

#ifndef __WIN32__
#  define O_BINARY 0
#endif

extern off_t
filedes_seek(struct filedes *fd, off_t offset);

extern bool
filedes_is_seekable(struct filedes *fd);

static inline void filedes_init(struct filedes *fd, int raw_fd)
{
	fd->fd = raw_fd;
	fd->offset = 0;
	fd->is_pipe = 0;
}

static inline void filedes_invalidate(struct filedes *fd)
{
	fd->fd = -1;
}

#define filedes_close(f) close((f)->fd)

static inline bool
filedes_valid(const struct filedes *fd)
{
	return fd->fd != -1;
}

#endif /* _WIMLIB_FILE_IO_H */
