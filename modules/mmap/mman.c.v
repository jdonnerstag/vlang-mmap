module mmap

// mmap This module provides memory mapping related functionalities.
// The memory mapping functions are OS specific. The V-API is
// consistent across the OSes and has been choosen to be Linux-like.
import os

// MmapOptions These are the mmap() function arguments
pub struct MmapOptions {
pub:
	addr   voidptr = C.NULL // No preferred virtual address
	len    u64     = -1 // -1: use file size if fd != 0, else error
	prot   int     = prot_read //
	flags  int     = map_shared
	fd     int
	offset u64 // beginning of file
}

// to_byte_array mmap() returns a voidptr. Often you want a byte array,
// or some other structure
pub fn to_byte_array(addr voidptr, len u64) []byte {
	b := []byte{}
	eprintln('b.len before: $b.len')
	unsafe {
		// here b will be setup to work with the mmaped region
		mut pdata := &b.data
		mut plen := &b.len
		mut pcap := &b.cap
		*pdata = addr
		*plen = int(len)
		*pcap = int(len)

		// V's compiler issues a warning that ll pXXX vars as "unused".
		// Until that is fixed ...
		if false {
			_ = pdata
			_ = plen
			_ = pcap
		}
	}
	return b
}

pub struct MmapInfo {
pub mut:
	fd os.File
pub:
	fsize u64
	addr  voidptr
	data  []byte
}

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
		data: to_byte_array(addr, fsize)
	}
}
