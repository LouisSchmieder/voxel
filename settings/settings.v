module settings

import json

struct Settings {
pub:
	port int
	max_players int
	motd string
	view_distance int
	online_mode bool [json: 'online-mode']
}

pub fn load_settings(settings_str string) Settings {
	settings := json.decode(Settings, settings_str) or { panic(err) }
	return settings
}