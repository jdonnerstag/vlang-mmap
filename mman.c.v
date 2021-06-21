module mmap

// mmap This module provides memory mapping related functionalities.
// The memory mapping functions are OS specific. The V-API is
// consistent across the OSes and has been choosen to be Linux-like.
import os

// MmapOptions These are the mmap() function arguments
pub struct MmapOptions {
pub:
	addr   voidptr = C.NULL 	  // No preferred virtual address
	len    u64     = -1 		  // -1: use file size if fd != 0, else error
	prot   int     = prot_read
	flags  int     = map_shared
	fd     int  /* = 0 */
	offset u64  /* = 0 */	      // beginning of file
}

// vbytes Cast the memory mapped region to []byte
pub fn (this MmapInfo) vbytes() []byte {
	unsafe { return this.addr.vbytes(int(this.fsize)) }
}

// bytestr Cast the memory mapped region to string
pub fn (this MmapInfo) bytestr() string {
	return this.vbytes().bytestr()
}

// MmapInfo The struct returned from mmap_file()
pub struct MmapInfo {
pub mut:
	fd os.File
pub:
	fsize u64
	addr  voidptr
	data  []byte
}

// close Unmap the memory mapped region and close the underlying file
pub fn (mut this MmapInfo) close() {
	munmap(this.addr, this.fsize) or { eprintln('ignored => $err') }

	this.fd.close()
}

// mmap_file This is a convinience function to memory map a file's content for read-only
pub fn mmap_file(file string) ?MmapInfo {
	fsize := os.file_size(file)
	mut f := os.open(file) ?
	addr := mmap(len: fsize, prot: prot_read, flags: map_shared, fd: f.fd, offset: 0) ?
	return MmapInfo{
		fd: f
		fsize: u64(fsize)
		addr: addr
		data: unsafe { addr.vbytes(int(fsize)) }
	}
}
