module server

import net
import settings

struct Server {
	server net.TcpListener
	settings settings.Settings
mut:
	players []&Player
	running bool = true
}

pub fn open(settings settings.Settings) {
	sock := net.listen_tcp(settings.port) or { panic(err) }
	mut server := Server{
		server: sock
		settings: settings
		players: []&Player{}
	}
	server.listen()
}

fn (mut server Server) listen() {
	for server.running {
		client := server.server.accept() or {
			error(err)
			continue
		}
		go handle_connection(client, server)
	}
}

fn (server Server) get_player_names() []string {
	return server.players.map(fn (player &Player) string {
		return player.name
	})
}