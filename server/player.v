module server

struct Player {
	name string
mut:
	displayname string
	conn &Connection
}