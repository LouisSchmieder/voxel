module packet

pub fn parse_next_state(state int) State {
	match state {
		1 {
			return State.status
		}
		2 {
			return State.login
		}
		3 {
			return State.play
		} else {
			return State.handshake
		}
	}
}

pub fn status_request_string(max_player int, online_player int, players []string, motd string) string {
	players_joined := players.join(', ')
	return '{"version":{"name":"Voxel 1.16.4","protocol":754},"players":{"max":$max_player,"online":$online_player,"sample":[$players_joined]},"description":{"text":"$motd"}}'
}