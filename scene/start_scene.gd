extends Control

@onready var play_btn: Button = %Play
@onready var map_editor_btn: Button = %"Map Editor"
@onready var setting_btn: Button = %Setting

@onready var bg_animation: AnimationPlayer = %BGAnimation
@onready var label_animation: AnimationPlayer = %LabelAnimation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_btn.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://levels/level_1.tscn")			
	)
	
	map_editor_btn.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scene/map_editor/map_editor.tscn")	
	)
	
	setting_btn.pressed.connect(func() -> void:
		var settings_page = load("res://scene/setting.tscn")	
		settings_page = settings_page.instantiate()
		add_sibling(settings_page)
	)
	
	bg_animation.play("bg_animation")
	label_animation.play('label_animation')
