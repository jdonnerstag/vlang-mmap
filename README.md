# Memory Mapping support for [vlang](https://vlang.io)

Inspired by [mman-win32](https://github.com/alitrack/mman-win32), this module
provides [vlang](https://vlang.io) with easy to use memory mapping support. 

## Key Features

- Supports Linux and Windows
- Consistent public API for Linux and Windows
- V-lang like error handling

## API

```v
	pub fn mmap(args MmapOptions) ?voidptr
	pub fn munmap(addr voidptr, len u64) ?
	pub fn mprotect(addr voidptr, len u64, prot int) ?
	pub fn msync(addr voidptr, len u64, flags int) ?
	pub fn mlock(addr voidptr, len u64) ?
	pub fn munlock(addr voidptr, len u64) ? 
```

Additionally

```v
	// Cast the memory mapped region to a byte array
	pub fn to_byte_array(addr voidptr, len u64) []byte {
```

and
```v
	// Open a file (binary, read-only) and map its content into memory 
	pub fn mmap_file(file string) ?MmapInfo {

	// Release the memory mapped region and close the file
	pub fn (mut this MmapInfo) close() {
```

## Example

```v
import mmap

fn main() {
	big_file_path := '../../MY_BIG_FILE.20180119104659.A901'
	mut minfo := mmap.mmap_file(big_file_path)?
	defer { minfo.close() }

	b := minfo.bytes
	eprintln('src: $minfo.src')
	eprintln('b.len after: $b.len')
	eprintln('b starts with:')
	eprintln(b[0..64].hex())

	defer { eprintln('finished') }
}

/*
home: $ ./v run ./mmap_example.v
src: 0000000000B30000
b.len before: 0
b.len after: 2096582968
b starts with:
20202020203130303031324b64697077696d6c79676f716a6d712038205720202020202020202020202020202020202020202020202020202020202020202020
finished
*/
```
