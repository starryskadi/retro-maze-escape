extends Node2D
const PLAYER = preload("res://scene/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = PLAYER.instantiate()
	add_child(player)
