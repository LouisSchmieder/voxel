module packet

enum PacketType {
	error
	// IN
	in_handshake
	in_legacy_server_list_ping
	in_status_request
	in_status_ping
	in_login_start
	in_encryption_response
	in_login_plugin_response

	// OUT
	out_status_response
	out_status_pong
	out_login_success
	out_play_join_game
}