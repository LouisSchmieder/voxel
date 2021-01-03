module nbt

import encoding.binary
import math

const (
	tag_types = [
		TagType.tag_invalid,
		TagType.tag_byte,
		TagType.tag_short,
		TagType.tag_int,
		TagType.tag_long,
		TagType.tag_float,
		TagType.tag_double,
		TagType.tag_byte_array,
		TagType.tag_string,
		TagType.tag_list,
		TagType.tag_compound,
		TagType.tag_int_array,
		TagType.tag_long_array,
	]
)

type NodePayload = []Node | NodeList | Node | []byte | []i64 | []int | i16 | i64 | i8 | int | string | f32 | f64

pub enum TagType {
	tag_invalid
	tag_byte
	tag_short
	tag_int
	tag_long
	tag_float
	tag_double
	tag_byte_array
	tag_string
	tag_list
	tag_compound
	tag_int_array
	tag_long_array
}

fn (typ TagType) to_byte() byte {
	for i, t in tag_types {
		if typ == t {
			return byte(i)
		}
	}
	return 0
}

fn to_typ(i byte) TagType {
	return if i > 12 { tag_types[0] } else { tag_types[i] }
}

pub struct Node {
pub:
	typ     TagType
	name    string
	payload NodePayload
}

pub struct NodeList {
pub:
	typ TagType
	list []NodePayload
}

pub fn (node Node) dump_to_bytes() []byte {
	if node.typ == .tag_invalid {
		return [byte(0x00)]
	}

	mut bytes := []byte{}

	mut name_len := []byte{len: 2}
	name_len[0] = byte(node.name.len & 0xFF)
	name_len[1] = byte(node.name.len >> 8)

	mut name_buf := node.name.bytes()

	bytes << node.typ.to_byte()
	bytes << name_len
	bytes << name_buf
	bytes << node.dump()

	return bytes
}

fn (node Node) dump() []byte {
	mut bytes := []byte{}
	match node.typ {
		.tag_invalid {
			bytes = [byte(0x00)]
		}
		.tag_byte {
			bytes << byte(i8(node.payload))
		}
		.tag_short {
			mut buf := []byte{}
			binary.big_endian_put_u16(mut buf, u16(node.payload))
			bytes << buf
		}
		.tag_int {
			mut buf := []byte{}
			binary.big_endian_put_u32(mut buf, u32(node.payload))
			bytes << buf
		}
		.tag_long {
			mut buf := []byte{}
			binary.big_endian_put_u32(mut buf, u32(node.payload))
			bytes << buf
		}
		.tag_float {
			bytes << f32_to_buf(f32(node.payload))
		}
		.tag_double {
			bytes << f64_to_buf(f64(node.payload))
		}
		.tag_byte_array {
			mut buf := []byte{}
			ba := node.payload as []byte
			binary.big_endian_put_u32(mut buf, u32(ba.len))
			bytes << buf
			bytes << ba
		}
		.tag_string {
			mut len := []byte{}
			str := string(node.payload)
			binary.big_endian_put_u16(mut len, u16(str.len))
			bytes << len
			bytes << str.bytes()
		}
		.tag_list {
			list := node.payload as NodeList
			bytes << list.typ.to_byte()
			mut buf := []byte{}
			binary.big_endian_put_u32(mut buf, u32(list.list.len))
			bytes << buf
			for item in list.list {
				n := Node{typ: list.typ, payload: item}
				bytes << n.dump()
			}
		}
		.tag_compound {
			list := node.payload as []Node
			for n in list {
				bytes << n.dump_to_bytes()
			}
		}
		.tag_int_array {
			mut buf := []byte{}
			ia := node.payload as []int
			binary.big_endian_put_u32(mut buf, u32(ia.len))
			bytes << buf
			for i in ia {
				mut tmp_buf := []byte{}
				binary.big_endian_put_u32(mut tmp_buf, u32(i))
				bytes << tmp_buf
			}
		}
		.tag_long_array {
			mut buf := []byte{}
			la := node.payload as []i64
			binary.big_endian_put_u32(mut buf, u32(la.len))
			bytes << buf
			for l in la {
				mut tmp_buf := []byte{}
				binary.big_endian_put_u64(mut tmp_buf, u64(l))
				bytes << tmp_buf
			}
		}
	}
	return bytes
}

fn f32_to_buf(f f32) []byte {
	mut fl := f
	mut byte_num := []byte{len: 8}

	mut sign := u32(0)
	mut mantessa := f32(0)
	mut exp := int(0)

	mut res := u32(0)
	if fl != 0 {
		if fl < 0 {
			sign = 0x80000000
			fl *= -1.0
		}
		mut watchdog := 0
		for {
			watchdog++
			if watchdog > 512 {
				break
			}
			mantessa = fl / math.powf(2, exp)
			if mantessa >= 1 && mantessa < 2 {
				break
			} else if mantessa >= 2.0 {
				exp++
			} else if mantessa < 1 {
				exp--
			}
			fixed_exponent := u32((exp+127)<<23)
			fixed_mantessa := u32(f32((mantessa - 1) * math.pow(2, 23)))
			res = sign + fixed_exponent + fixed_mantessa
		}
	}
	binary.big_endian_put_u32(mut byte_num, res)
	return byte_num
}

fn f64_to_buf(f f64) []byte {
	mut fl := f
	mut byte_num := []byte{len: 16}

	mut sign := u64(0)
	mut mantessa := f64(0)
	mut exp := int(0)

	mut res := u64(0)
	if fl != 0 {
		if fl < 0 {
			sign = 0x8000000000000000
			fl *= -1.0
		}
		mut watchdog := 0
		for {
			watchdog++
			if watchdog > 512 {
				break
			}
			mantessa = fl / math.powf(2, exp)
			if mantessa >= 1 && mantessa < 2 {
				break
			} else if mantessa >= 2.0 {
				exp++
			} else if mantessa < 1 {
				exp--
			}
			fixed_exponent := u64((exp+1023)<<52)
			fixed_mantessa := u64(f64((mantessa - 1) * math.pow(2, 52)))
			res = sign + fixed_exponent + fixed_mantessa
		}
	}
	binary.big_endian_put_u64(mut byte_num, res)
	return byte_num
}