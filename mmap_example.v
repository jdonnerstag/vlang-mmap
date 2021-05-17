import mmap

fn main() {
	big_file_path := '../../COMSAFE/pil-data-2/11_input_crlf_fixed/ANO_DWH..DWH_TO_PIL_CENT_PARTY_VTAG.20180119104659.A901'
	mut minfo := mmap.mmap_file(big_file_path)?
	defer { minfo.close() }

	b := minfo.bytes
	eprintln('src: $minfo.src')
	eprintln('b.len after: $b.len')
	eprintln('b starts with:')
	eprintln(b[0..64].hex())

	// ////////////////////////////////////////////////////////////////////
	defer { eprintln('finished') }
}

/*
0[07:56:20]delian@nemesis: /v/nv $ ./v run /v/misc/mmap_example.v
src: 0000000000B30000
b.len before: 0
b.len after: 2096582968
b starts with:
20202020203130303031324b64697077696d6c79676f716a6d712038205720202020202020202020202020202020202020202020202020202020202020202020
finished
*/
