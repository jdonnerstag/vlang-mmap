import os
import mmap

fn test_mmap_file() ? {
	file_path := @FILE
	mut minfo := mmap.mmap_file(file_path) ?
	defer {
		minfo.close()
	}

	assert minfo.fd.fd != 0
	assert minfo.addr != 0
	assert minfo.fsize == os.file_size(file_path)
	assert minfo.data.data == minfo.addr
	assert minfo.data.len == minfo.fsize

	data := os.read_file(file_path) ?
	assert minfo.data == data.bytes()
}
