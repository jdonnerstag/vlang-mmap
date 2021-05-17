//
//
//
module mmap

import os

#include <sys/mman.h>

pub const (
	prot_none  = C.PROT_NONE
	prot_read  = C.PROT_READ
	prot_write = C.PROT_WRITE
	prot_exec  = C.PROT_EXEC
)

pub const (
	map_file         = C.MAP_FILE
	map_shared       = C.MAP_SHARED
	map_private      = C.MAP_PRIVATE
	map_type         = C.MAP_TYPE
	map_fixed        = C.MAP_FIXED
	map_anonymous    = C.MAP_ANONYMOUS
	map_anon         = map_anonymous
)

// Flags for msync.
pub const (
	ms_async      = C.MS_ASYNC
	ms_sync       = C.MS_SYNC
	ms_invalidate = C.MS_INVALIDATE
)

fn C.mmap(addr voidptr, len size_t, prot int, flags int, fd int, offset i64) voidptr
fn C.munmap(addr voidptr, len size_t) int
fn C.mprotect(addr voidptr, len size_t, prot int) int
fn C.msync(addr voidptr, len size_t, flags int) int
fn C.mlock(addr voidptr, len size_t) int
fn C.munlock(addr voidptr, len size_t) int

pub fn mmap(args MmapOptions) ?voidptr {
	addr := C.mmap(args.addr, size_t(args.len), args.prot, args.flags, args.fd, args.offset) 
	if addr != C.MAP_FAILED {
		return addr
	}

	match C.errno {
		C.EACCES {
			return error(
				"(EACCES) A file descriptor refers to a non-regular file.  Or a file " +
				"mapping was requested, but fd is not open for reading.  Or " +
				"MAP_SHARED was requested and PROT_WRITE is set, but fd is " +
				"not open in read/write (O_RDWR) mode.  Or PROT_WRITE is " +
				"set, but the file is append-only. "
			)
		} 
		C.EAGAIN {
			return error(
				"(EAGAIN) The file has been locked, or too much memory has been " +
				"locked (see setrlimit(2))."
			)
		} 
		C.EBADF {
			return error(
				"(EBADF) fd is not a valid file descriptor (and MAP_ANONYMOUS was not set)."
			)
		} 
		C.EEXIST {
			return error(
				"(EEXIST) MAP_FIXED_NOREPLACE was specified in flags, and the range " +
				"covered by addr and length clashes with an existing " +
				"mapping."
			)
		}
		C.EINVAL {
			return error(
				"(EINVAL) We don't like addr, length, or offset (e.g., they are too " +
				"large, or not aligned on a page boundary)." + 
				"Or: " + 
				"(EINVAL) (since Linux 2.6.12) length was 0." +
				"Or: " + 
				"(EINVAL) flags contained none of MAP_PRIVATE, MAP_SHARED, or " +
				"MAP_SHARED_VALIDATE."
			)
		}
		C.ENFILE {
			return error(
				"(ENFILE) The system-wide limit on the total number of open files " +
				"has been reached."
			)
		}
		C.ENODEV  {
			return error(
				"(ENODEV) The underlying filesystem of the specified file does not " +
				"support memory mapping."
			)
		}
		C.ENOMEM {
			return error(
				"(ENOMEN) No memory is available. " +
				"Or: " + 
				"(ENOMEM) The process's maximum number of mappings would have been " +
				"exceeded.  This error can also occur for munmap(), when " +
				"unmapping a region in the middle of an existing mapping, " +
				"since this results in two smaller mappings on either side " +
				"of the region being unmapped. " +
				"Or: " + 
				"(ENOMEM) (since Linux 4.7) The process's RLIMIT_DATA limit, " +
				"described in getrlimit(2), would have been exceeded."
			)
		}
		C.EOVERFLOW {
			return error(
				"(EOVERFLOW) On 32-bit architecture together with the large file " +
				"extension (i.e., using 64-bit off_t): the number of pages " +
				"used for length plus number of pages used for offset would " +
				"overflow unsigned long (32 bits). "
			)
		}
		C.EPERM {
			return error(
				"(EPERM) The prot argument asks for PROT_EXEC but the mapped area " +
				"belongs to a file on a filesystem that was mounted no-exec. " +
				"Or: " + 
				"(EPERM) The operation was prevented by a file seal; see fcntl(2)."
			)
		}
		C.ETXTBSY {
			return error(
				"(ETXTBSY) MAP_DENYWRITE was set but the object specified by fd is " +
				"open for writing."
			)
		}
		else {
			return error("($C.errno) Unknown error")
		}
	}
}

pub fn munmap(addr voidptr, len u64) ? {
	if C.munmap(addr, len) != 0 {
		return error("($C.errno) munmap() failed")
	}
}

pub fn mprotect(addr voidptr, len u64, prot int) ? {
	if C.mprotect(addr, len, prot) != 0 {
		return error("($C.errno) mprotect() failed")
	}
}

pub fn msync(addr voidptr, len u64, flags int) ? {
	if C.msync(addr, len, flags) != 0 {
		return error("($C.errno) msync() failed")
	}
}

pub fn mlock(addr voidptr, len u64) ? {
	if C.mlock(addr, len) != 0 {
		return error("($C.errno) mlock() failed")
	}
}

pub fn munlock(addr voidptr, len u64) ? {
	if C.munlock(addr, len) != 0 {
		return error("($C.errno) munlock() failed")
	}
}
