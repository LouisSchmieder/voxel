module packet

import sio

fn write_status_response(mut nos &sio.NetOutputStream, data PacketOutStatusResponse) {
	nos.write_var_string(data.json_response)
}

fn write_status_pong(mut nos &sio.NetOutputStream, data PacketOutStatusPong) {
	nos.write_i64(data.payload)
}

fn write_login_success(mut nos &sio.NetOutputStream, data PacketOutLoginSuccess) {
	nos.write_bytes(data.uuid.buffer())
	nos.write_var_string(data.username)
}

fn write_play_join_game(mut nos &sio.NetOutputStream, data PacketPlayOutJoinGame) {
	nos.write_int(data.entity_id)
	nos.write_bool(data.hardcore)
	nos.write_byte(data.gamemode)
	nos.write_i8(data.previous_gamemode)
	nos.write_var_int(data.world_identifier.len)
	for identifier in data.world_identifier {
		nos.write_var_string(identifier)
	}
	nos.write_bytes(data.dimension_codec.dump_to_bytes())
	nos.write_bytes(data.dimension.dump_to_bytes())
	nos.write_var_string(data.spawned_world)
	nos.write_i64(data.hashed_seed)
	nos.write_var_int(data.max_players)
	nos.write_var_int(data.view_distance)
	nos.write_bool(data.debug_info)
	nos.write_bool(data.enable_respawn_screen)
	nos.write_bool(data.is_debug)
	nos.write_bool(data.is_flat)
}