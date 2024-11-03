extends Node

enum GAME_MODE {
	GAME,
	EDITOR
}

var current_game_mode = GAME_MODE.GAME

func update_save_paste_bin_key(key: String) -> void:	
	var file := FileAccess.open("user://pastebin_key.dat", FileAccess.WRITE)
	file.store_string(key)
