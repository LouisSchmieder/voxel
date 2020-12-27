module server

import net
import packet
import uuid
import level
import settings

struct Connection {
	sock net.TcpConn
	server &Server
mut:
	state packet.State
}

pub fn create_connection(sock net.TcpConn, server &Server) &Connection {
	return &Connection{sock, server, .handshake}
}

pub fn handle_connection(sock net.TcpConn, server &Server) {
	mut conn := create_connection(sock, server)
	p := packet.read_packet(conn.sock, conn.state) or {
		error(err)
		return
	}
	data := p.data as packet.PacketInHandshake
	conn.state = data.next_state
	match data.next_state {
		.status {
			conn.send_server_status(data)
		}
		.login {
			conn.handle_login()
		}
		else {
			error('Something went wrong')
			return
		}
	}

}

fn (mut conn Connection) send_server_status(handshake_packet packet.PacketInHandshake) {
	json_server_status := packet.status_request_string(conn.server.settings.max_players, conn.server.players.len, conn.server.get_player_names(), conn.server.settings.motd)
	mut p := packet.read_packet(conn.sock, conn.state) or {
		error(err)
		return
	}
	if p.packet_type != .in_status_request {
		error('Wrong packet')
		return
	}
	packet.write_packet(conn.sock, packet.Packet{
		id: 0x00
		data: packet.PacketData(packet.PacketOutStatusResponse{
			json_response: json_server_status
		})
		packet_type: .out_status_response
	}, conn.state)

	p = packet.read_packet(conn.sock, conn.state) or {
		error(err)
		return
	}
	if p.packet_type != .in_status_ping {
		error('Wrong packet')
		return
	}

	data := p.data as packet.PacketInStatusPing
	packet.write_packet(conn.sock, packet.Packet{
		id: 0x01
		data: packet.PacketData(packet.PacketOutStatusPong{
			payload: data.payload
		})
	}, conn.state)
	conn.sock.close()
	return
}

fn (mut conn Connection) handle_login() {
	mut p := packet.read_packet(conn.sock, conn.state) or {
		error(err)
		return
	}
	if p.packet_type != .in_login_start {
		error('Wrong packet')
		return
	}
	data := p.data as packet.PacketInLoginStart
	// if conn.server.settings.online_mode {}
	packet.write_packet(conn.sock, packet.Packet{
		id: 0x02
		data: packet.PacketOutLoginSuccess{
			uuid: uuid.random_uuid()
			username: data.username 
		}
		packet_type: .out_login_success
	}, conn.state)
	conn.state = .play
	conn.send_start_chunks()
}

fn (mut conn Connection) send_start_chunks() {
	packet.write_packet(conn.sock, packet.Packet{
		id: 0x24
		data: packet.PacketPlayOutJoinGame{
			entity_id: 0
			hardcore: false
			gamemode: 1
			world_identifier: ['minecraft:world']
			dimension: level.overworld
			spawned_world: 'minecraft:world'
			hashed_seed: 0
			max_players: conn.server.settings.max_players
			view_distance: conn.server.settings.view_distance
			enable_respawn_screen: true
			is_debug: false
			is_flat: false
		}
		packet_type: .out_play_join_game
	}, conn.state)
}

fn (mut conn Connection) handle_play() {

}