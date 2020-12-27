module sio

import net
import encoding.binary

struct NetOutputStream {
mut:
	sock &net.TcpConn
	bytes []byte
}

pub fn new_net_output_stream(sock &net.TcpConn) &NetOutputStream {
	return &NetOutputStream{
		sock: sock
		bytes: []byte{}
	}
}

pub fn (mut nos NetOutputStream) empty_buffer() {
	nos.bytes = []byte{}
}

pub fn (mut nos NetOutputStream) write_var_int(val int) {
	mut data := val
	
	for {
		mut tmp := (data & 0b01111111)
		data >>= 7

		if data != 0 {
			tmp |= 0b10000000
		}
		nos.bytes << byte(tmp)
		if data == 0 {
			break
		}
	}
	
}

pub fn (mut nos NetOutputStream) write_var_long(val i64) ? {
	mut data := val
	
	for {
		mut tmp := (data & 0b01111111)
		data >>= 7

		if data != 0 {
			tmp |= 0b10000000
		}
		nos.bytes << byte(tmp)
		if data == 0 {
			break
		}
	}
}

pub fn (mut nos NetOutputStream) write_var_string(str string) {
	bytes := str.bytes()
	nos.write_var_int(bytes.len)
	nos.bytes << bytes
}

pub fn (mut nos NetOutputStream) write_int(d int) ? {
	mut bytes := []byte{len: int(sizeof(int))}
	binary.big_endian_put_u32(mut bytes, u32(d))
	nos.bytes << bytes
}

pub fn (mut nos NetOutputStream) write_ints(d []int) ? {
	for u in d {
		mut tmp := []byte{len: int(sizeof(int))}
		binary.big_endian_put_u32(mut tmp, u32(u))
		nos.bytes << tmp
	}
}

pub fn (mut nos NetOutputStream) write_i8(d i8) ? {
	nos.bytes << byte(d)
}

pub fn (mut nos NetOutputStream) write_i8s(d []i8) ? {
	for a in d {
		nos.bytes << byte(a)
	}
}

pub fn (mut nos NetOutputStream) write_i16(d i16) ? {
	mut bytes := []byte{len: int(sizeof(i16))}
	binary.big_endian_put_u16(mut bytes, u16(d))
	nos.bytes << bytes
}

pub fn (mut nos NetOutputStream) write_i16s(d []i16) ? {
	for u in d {
		mut tmp := []byte{len: int(sizeof(i16))}
		binary.big_endian_put_u16(mut tmp, u16(u))
		nos.bytes << tmp
	}
}

pub fn (mut nos NetOutputStream) write_i64(d i64) ? {
	mut bytes := []byte{len: int(sizeof(i64))}
	binary.big_endian_put_u64(mut bytes, u64(d))
	nos.bytes << bytes
}

pub fn (mut nos NetOutputStream) write_i64s(d []i64) ? {
	for u in d {
		mut tmp := []byte{len: int(sizeof(i64))}
		binary.big_endian_put_u64(mut tmp, u64(u))
		nos.bytes << tmp
	}	
}

pub fn (mut nos NetOutputStream) write_byte(d byte) ? {
	nos.bytes << d
}

pub fn (mut nos NetOutputStream) write_bytes(d []byte) ? {
	nos.bytes << d
}

pub fn (mut nos NetOutputStream) write_u16(d u16) ? {
	mut bytes := []byte{len: int(sizeof(u16))}
	binary.big_endian_put_u16(mut bytes, d)
	nos.bytes << bytes
}

pub fn (mut nos NetOutputStream) write_u16s(d []u16) ? {
	for u in d {
		mut tmp := []byte{len: int(sizeof(u16))}
		binary.big_endian_put_u16(mut tmp, u)
		nos.bytes << tmp
	}
	
}

pub fn (mut nos NetOutputStream) write_u32(d u32) ? {
	mut bytes := []byte{len: int(sizeof(u32))}
	binary.big_endian_put_u32(mut bytes, d)
	nos.bytes << bytes
}

pub fn (mut nos NetOutputStream) write_u32s(d []u32) ? {
	
	for u in d {
		mut tmp := []byte{len: int(sizeof(u32))}
		binary.big_endian_put_u32(mut tmp, u)
		nos.bytes << tmp
	}
	
}

pub fn (mut nos NetOutputStream) write_u64(d u64) ? {
	mut bytes := []byte{len: int(sizeof(u64))}
	binary.big_endian_put_u64(mut bytes, d)
	nos.bytes << bytes
}

pub fn (mut nos NetOutputStream) write_u64s(d []u64) ? {
	
	for u in d {
		mut tmp := []byte{len: int(sizeof(u64))}
		binary.big_endian_put_u64(mut tmp, u)
		nos.bytes << tmp
	}
	
}

pub fn (mut nos NetOutputStream) write_f32(d f32) ? {
	pb := &byte(&d)
	mut bytes := []byte{len: int(sizeof(f32))}
	unsafe {
		for i in 0..bytes.len {
			bytes[i] = pb[i]
		}
	}
	nos.bytes << bytes
}

pub fn (mut nos NetOutputStream) write_f32s(d []f32) ? {
	
	for f in d {
		pb := &byte(&f)
		unsafe {
			for i in 0..int(sizeof(f32)) {
				nos.bytes << pb[i]
			}
		}
	}
	
}

pub fn (mut nos NetOutputStream) write_f64(d f64) ? {
	pb := &byte(&d)
	mut bytes := []byte{len: int(sizeof(f64))}
	unsafe {
		for i in 0..bytes.len {
			bytes[i] = pb[i]
		}
	}
	nos.bytes << bytes
	
}

pub fn (mut nos NetOutputStream) write_f64s(d []f64) ? {
	
	for f in d {
		pb := &byte(&f)
		unsafe {
			for i in 0..int(sizeof(f64)) {
				nos.bytes << pb[i]
			}
		}
	}
	
}

pub fn (mut nos NetOutputStream) write_string(d string) ? {
	nos.write_bytes(d.bytes())?
}

pub fn (mut nos NetOutputStream) write_bool(b bool) {
	nos.write_byte(byte(if b { 0x01 } else { 0x00 }))
}

pub fn (mut nos NetOutputStream) flush(id int) {
	mut buf := nos.bytes.clone()
	nos.empty_buffer()

	mut id_buf := [byte(0x00)]
	if id > 0 {
		nos.write_var_int(id)
		id_buf = nos.bytes.clone()
		nos.empty_buffer()
	}

	nos.write_var_int(buf.len + id_buf.len)
	nos.write_bytes(id_buf)
	nos.write_bytes(buf)
}

pub fn (mut nos NetOutputStream) write_packet() {
	nos.sock.write(nos.bytes)
}
