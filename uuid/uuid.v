module uuid

import crypto.rand
import encoding.binary

pub struct UUID {
	most_significant_bits u64
	least_significant_bits u64
}

pub fn random_uuid() UUID {
	msb := rand.int_u64(0xFFFFFFFFFFFFFFFF) or { panic(err) }
	lsb := rand.int_u64(0xFFFFFFFFFFFFFFFF) or { panic(err) }
	return UUID{
		msb, lsb
	}
}

pub fn (uuid UUID) buffer() []byte {
	mut bytes := []byte{}
	mut buf := []byte{len: int(sizeof(i64))}
	binary.big_endian_put_u64(mut buf, uuid.most_significant_bits)
	bytes << buf
	binary.big_endian_put_u64(mut buf, uuid.least_significant_bits)
	bytes << buf
	return bytes
}