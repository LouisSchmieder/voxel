module main

import server
import settings
import os

const (
	settings_path = './assets/settings/settings.json'
)

fn main() {
	settings_str := os.read_file(settings_path) or { '' }
	server.open(settings.load_settings(settings_str))
}
