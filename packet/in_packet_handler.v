module packet

import sio

fn read_handshake(mut nio &sio.NetInputStream) PacketInHandshake {
	protocol_ver := nio.read_pure_var_int()
	server_address := nio.read_mc_string()
	port := nio.read_i16()
	next_state := nio.read_pure_var_int()

	return PacketInHandshake{
		protocol_ver: protocol_ver
		host: server_address
		port: port
		next_state: parse_next_state(next_state)
	}
}

fn read_legacy_server_list_ping(mut nio &sio.NetInputStream) PacketInLegacyServerListPing {
	payload := nio.read_byte()

	return PacketInLegacyServerListPing{
		payload: payload
	}
}

fn read_status_request(mut nio &sio.NetInputStream) PacketInStatusRequest {
	return PacketInStatusRequest{}
}

fn read_status_ping(mut nio &sio.NetInputStream) PacketInStatusPing {
	payload := nio.read_i64()
	return PacketInStatusPing {
		payload: payload
	}	
}

fn read_login_start(mut nio &sio.NetInputStream) PacketInLoginStart {
	username := nio.read_mc_string()
	return PacketInLoginStart {
		username: username
	}
}

fn read_encryption_response(mut nio &sio.NetInputStream) PacketInEncryptionResponse {
	shared_secret_len := nio.read_pure_var_int()
	shared_secret := nio.read_bytes(u32(shared_secret_len))
	verify_token_len := nio.read_pure_var_int()
	verify_token := nio.read_bytes(u32(verify_token_len))
	return PacketInEncryptionResponse {
		shared_secret: string(shared_secret)
		verify_token: string(verify_token)
	}
}

fn read_login_plugin_response(mut nio &sio.NetInputStream, len int) PacketInLoginPluginResponse {
	message_id := nio.read_pure_var_int()
	succ := if nio.read_byte() == 0x01 { true } else { false }
	d_len := len - nio.len
	mut data := []byte{}
	if d_len > 0 {
		data = nio.read_bytes(u32(d_len))
	}
	return PacketInLoginPluginResponse {
		message_id: message_id
		succ: succ
		data: data
	}
}