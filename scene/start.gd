extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.current_game_mode == Global.GAME_MODE.GAME:
		var player = load("res://scene/player.tscn").instantiate()
		add_child(player)
