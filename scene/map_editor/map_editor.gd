extends Node2D
@onready var maze: TileMapLayer = %Maze
@onready var pointer: Node2D = %Pointer
@onready var camera_2d: Camera2D = %Camera2D
@onready var mouse_indicator: TileMapLayer = %MouseIndicator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_pressed('mouse_left'):
		var selected_tile = maze.local_to_map(get_global_mouse_position())
		maze.set_cells_terrain_connect([selected_tile], 0, 0 , false)
	elif Input.is_action_pressed('mouse_right'):
		pointer.position = pointer.position.lerp(get_global_mouse_position(), 2.0 * delta)
		#var selected_tile = maze.local_to_map(get_global_mouse_position())
		#maze.erase_cell(selected_tile)	
	elif Input.is_action_just_pressed("mouse_up"):		
		camera_2d.zoom = camera_2d.zoom + camera_2d.zoom * 0.1
	elif Input.is_action_just_pressed("mouse_down"):
		camera_2d.zoom = camera_2d.zoom - camera_2d.zoom * 0.1

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_indicator.clear()
		var selected_tile = mouse_indicator.local_to_map(get_global_mouse_position())
		mouse_indicator.set_cell(selected_tile, 0 , Vector2i(0,0))
