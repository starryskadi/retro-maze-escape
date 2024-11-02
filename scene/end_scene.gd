extends Control

@onready var exit_btn: Button = $Exit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	exit_btn.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scene/start_scene.tscn")	
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
