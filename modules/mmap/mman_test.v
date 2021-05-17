import os
import mmap

fn test_mmap_file() ? {
	file_path := @FILE
	mut minfo := mmap.mmap_file(file_path)?
	defer { minfo.close() }

	assert minfo.fd.fd != 0
	assert minfo.src != 0
	assert minfo.fsize == os.file_size(file_path)
	assert minfo.bytes.data == minfo.src
	assert minfo.bytes.len == minfo.fsize

	data := os.read_file(file_path)?
	assert minfo.bytes == data.bytes()
}

