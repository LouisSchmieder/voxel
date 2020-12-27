module packet

import net
import sio
import uuid
import level

type PacketData = NoPacketData | PacketInHandshake | PacketInStatusRequest | PacketInStatusPing | PacketOutStatusResponse |PacketOutStatusPong | PacketInLoginStart | PacketInEncryptionResponse | PacketInLoginPluginResponse | PacketOutLoginSuccess |
					PacketInLegacyServerListPing | PacketPlayOutJoinGame
type InPacketData = PacketInHandshake

pub struct Packet {
pub:
	len int
	id int
	data PacketData
	packet_type PacketType
}

pub fn read_packet(sock net.TcpConn, state State) ?(Packet) {
	mut nio := sio.new_net_input_stream(sock)
	len := nio.read_pure_var_int()
	if len <= 0 {
		return error('Packet lenght is $len')
	}
	nio.clear_len()
	pkt_id := nio.read_pure_var_int()
	data, typ := read_packet_data(pkt_id, mut nio, state, len)
	return Packet{
		len: len
		id: pkt_id
		data: data
		packet_type: typ
	}	
}

pub fn write_packet(sock net.TcpConn, packet Packet, state State) {
	mut nos := sio.new_net_output_stream(sock)
	write_packet_data(mut nos, packet, state)
}

fn read_packet_data(pkt_id int, mut nio &sio.NetInputStream, state State, len int) (PacketData, PacketType) {
	mut packet_data := PacketData(NoPacketData{})
	mut packet_type := PacketType.error
	match state {
		.handshake {
			match pkt_id {
				0x00 {
					packet_data = PacketData(read_handshake(mut nio))
					packet_type = PacketType.in_handshake
				}
				else {
					return packet_data, packet_type
				}
			}
		}
		.status {
			match pkt_id {
				0x00 {
					packet_data = PacketData(read_status_request(mut nio))
					packet_type = PacketType.in_status_request
				}
				0x01 {
					packet_data = PacketData(read_status_ping(mut nio))
					packet_type = PacketType.in_status_ping
				}
				else {
					return packet_data, packet_type
				}
			}
		}
		.login {
			match pkt_id {
				0x00 {
					packet_data = PacketData(read_login_start(mut nio))
					packet_type = PacketType.in_login_start
				}
				0x01 {
					packet_data = PacketData(read_encryption_response(mut nio))
					packet_type = PacketType.in_encryption_response
				}
				0x02 {
					packet_data = PacketData(read_login_plugin_response(mut nio, len))
					packet_type = PacketType.in_login_plugin_response
				}
				else {
				}
			}
		}
		else {
		}
	}
	return packet_data, packet_type
	
}

fn write_packet_data(mut nos &sio.NetOutputStream, packet Packet, state State) {
	match state {
		.status {
			match packet.packet_type {
				.out_status_response {
					write_status_response(mut nos, packet.data as PacketOutStatusResponse)
				}
				.out_status_pong {
					write_status_pong(mut nos, packet.data as PacketOutStatusPong)
				}
				else {
					error('Something went wrong: Unknown packet')
					return
				}
			}
		}
		.login {
			match packet.packet_type {
				.out_login_success {
					write_login_success(mut nos, packet.data as PacketOutLoginSuccess)
				}
				else {
					error('Something went wrong: Unknown packet')
					return
				}
			}
		}
		.play {
			match packet.packet_type {
				.out_play_join_game {
					write_play_join_game(mut nos, packet.data as PacketPlayOutJoinGame)
				}
				else {
					error('Something went wrong: Unknown packet')
					return
				}
			}
		}
		else {
			error('Something went wrong')
			return
		}
	}
	nos.flush(packet.id)
	nos.write_packet()
}

struct NoPacketData {}


// In packets
pub struct PacketInHandshake {
pub:
	protocol_ver int
	host string
	port i16
	next_state State
}

pub struct PacketInLegacyServerListPing {
pub:
	payload byte
}

pub struct PacketInStatusRequest {}

pub struct PacketInStatusPing {
pub:
	payload i64
}

pub struct PacketInLoginStart {
pub:
	username string
}

pub struct PacketInEncryptionResponse {
pub:
	shared_secret string
	verify_token string
}

pub struct PacketInLoginPluginResponse {
pub:
	message_id int
	succ bool
	data []byte
}

// Out packets
pub struct PacketOutStatusResponse {
pub:
	json_response string
}

pub struct PacketOutStatusPong {
pub:
	payload i64
}

pub struct PacketOutLoginSuccess {
pub:
	uuid uuid.UUID
	username string
}

pub struct PacketPlayOutJoinGame {
pub:
	entity_id int
	hardcore bool
	gamemode byte
	previous_gamemode i8 = -1
	world_identifier []string
	dimension_codec byte = 0x00
	dimension level.Dimension 
	spawned_world string
	hashed_seed i64
	max_players int
	view_distance int
	debug_info bool = true
	enable_respawn_screen bool
	is_debug bool
	is_flat bool
}