module sio

import net
import encoding.binary

struct NetInputStream {
mut:
	sock &net.TcpConn
pub mut:
	len int
}

pub fn new_net_input_stream(sock &net.TcpConn) &NetInputStream {
	return &NetInputStream{
		sock: sock
		len: 0
	}
}

pub fn (mut nis NetInputStream) clear_len() {
	nis.len = 0
}

pub fn (mut nis NetInputStream) read_var(max int) ?(i64, int) {
	mut size := 0
	mut result := i64(0)
	for {
		b := nis.read_byte()
		result |= (b & 0b01111111) << (7 * size)
		size++
		if size > max {
			return error('Var is too long')
		}
		if (b & 0b10000000) == 0 {
			break
		}
	}
	return result, size
}

pub fn (mut nis NetInputStream) read_var_int() ?(int, int) {
	a, b := nis.read_var(10) or { return error(err) }
	return int(a), b
}

pub fn (mut nis NetInputStream) read_var_long() ?(i64, int) {
	a, b := nis.read_var(10) or { return error(err) }
	return a, b
}

pub fn (mut nis NetInputStream) read_pure_var(max int) i64 {
	i, _ := nis.read_var(max) or { return 0 }
	return i
}

pub fn (mut nis NetInputStream) read_pure_var_int() int {
	return int(nis.read_pure_var(5))
}

pub fn (mut nis NetInputStream) read_pure_var_long() i64 {
	return nis.read_pure_var(10)
}

pub fn (mut nis NetInputStream) read_mc_string() string {
	len := nis.read_pure_var_int()
	return nis.read_string(u32(len))
}

pub fn (mut nis NetInputStream) read_int() int {
	return int(binary.big_endian_u32(nis.read_bytes(sizeof(int))))
}

pub fn (mut nis NetInputStream) read_ints(l u32) []int {
	bytes := nis.read_bytes(sizeof(int) * l)
	mut ints := []int{}
	for i in 0 .. l {
		offs := int(u32(i) * sizeof(int))
		b := bytes[offs..int(u32(offs) + sizeof(int))]
		ints << int(binary.big_endian_u32(b))
	}
	return ints
}

pub fn (mut nis NetInputStream) read_i8() i8 {
	return i8(nis.read_byte())
}

pub fn (mut nis NetInputStream) read_i8s(l u32) []i8 {
	bytes := nis.read_bytes(sizeof(i8) * l)
	mut i8s := []i8{}
	for i in 0 .. l {
		i8s << i8(bytes[i])
	}
	return i8s
}

pub fn (mut nis NetInputStream) read_i16() i16 {
	return i16(binary.big_endian_u16(nis.read_bytes(sizeof(i16))))
}

pub fn (mut nis NetInputStream) read_i16s(l u32) []i16 {
	bytes := nis.read_bytes(sizeof(i16) * l)
	mut i16s := []i16{}
	for i in 0 .. l {
		offs := int(u32(i) * sizeof(i16))
		b := bytes[offs..int(u32(offs) + sizeof(i16))]
		i16s << i16(binary.big_endian_u16(b))
	}
	return i16s
}

pub fn (mut nis NetInputStream) read_i64() i64 {
	return i64(binary.big_endian_u64(nis.read_bytes(sizeof(i64))))

}

pub fn (mut nis NetInputStream) read_i64s(l u32) []i64 {
	bytes := nis.read_bytes(sizeof(i64) * l)
	mut i64s := []i64{}
	for i in 0 .. l {
		offs := int(u32(i) * sizeof(i64))
		b := bytes[offs..int(u32(offs) + sizeof(i64))]
		i64s << i64(binary.big_endian_u64(b))
	}
	return i64s
}

pub fn (mut nis NetInputStream) read_byte() byte {
	mut buf := []byte{len: 1}
	nis.sock.read(mut buf)
	nis.len++
	return buf[0]
}

pub fn (mut nis NetInputStream) read_bytes(l u32) []byte {
	mut bytes := []byte{len: int(l), cap: int(l)}
	for i in 0..l {
		bytes[i] = nis.read_byte()
	}
	return bytes
}

pub fn (mut nis NetInputStream) read_u16() u16 {
	return binary.big_endian_u16(nis.read_bytes(sizeof(u16)))
}

pub fn (mut nis NetInputStream) read_u16s(l u32) []u16 {
	bytes := nis.read_bytes(sizeof(u16) * l)
	mut u16s := []u16{}
	for i in 0 .. l {
		offs := int(u32(i) * sizeof(u16))
		b := bytes[offs..int(u32(offs) + sizeof(u16))]
		u16s << binary.big_endian_u16(b)

	}
	return u16s
}

pub fn (mut nis NetInputStream) read_u32() u32 {
	return binary.big_endian_u32(nis.read_bytes(sizeof(u32)))
}

pub fn (mut nis NetInputStream) read_u32s(l u32) []u32 {
	bytes := nis.read_bytes(sizeof(u32) * l)
	mut u32s := []u32{}
	for i in 0 .. l {
		offs := int(u32(i) * sizeof(u32))
		b := bytes[offs..int(u32(offs) + sizeof(u32))]
		u32s <<  binary.big_endian_u32(b)
	}
	return u32s
}

pub fn (mut nis NetInputStream) read_u64() u64 {
	return binary.big_endian_u64(nis.read_bytes(sizeof(u64)))
}

pub fn (mut nis NetInputStream) read_u64s(l u32) []u64 {
	bytes := nis.read_bytes(sizeof(u64) * l)
	mut u64s := []u64{}
	for i in 0 .. l {
		offs := int(u32(i) * sizeof(u64))
		b := bytes[offs..int(u32(offs) + sizeof(u64))]
		u64s <<  binary.big_endian_u64(b)
	}
	return u64s
}
pub fn (mut nis NetInputStream) read_f32() f32 {
	bytes := nis.read_bytes(sizeof(f32))
	f := &f32(bytes.data)
	return *f
}

pub fn (mut nis NetInputStream) read_f32s(l u32) []f32 {
	bytes := nis.read_bytes(sizeof(f32) * l)
	mut f32s := []f32{}
	for i in 0 .. l {
		offs := int(u32(i) * sizeof(f32))
		b := bytes[offs..int(u32(offs) + sizeof(f32))]
		f := &f32(b.data)
		unsafe {
			f32s << *f
		}
	}
	return f32s
}

pub fn (mut nis NetInputStream) read_f64() f64 {
	bytes := nis.read_bytes(sizeof(f64))
	f := &f64(bytes.data)
	return *f
}

pub fn (mut nis NetInputStream) read_f64s(l u32) []f64 {
	bytes := nis.read_bytes(sizeof(f64) * l)
	mut f64s := []f64{}
	for i in 0 .. l {
		offs := int(u32(i) * sizeof(f64))
		b := bytes[offs..int(u32(offs) + sizeof(f64))]
		f := &f64(b.data)
		unsafe {
			f64s << *f
		}
	}
	return f64s
}

pub fn (mut nis NetInputStream) read_string(l u32) string {
	bytes := nis.read_bytes(l)
	return tos(bytes.data, bytes.len)
}

pub fn (mut nis NetInputStream) skip(l u32) {
	nis.read_bytes(l)
}
