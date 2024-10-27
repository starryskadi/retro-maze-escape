extends Node2D
@onready var maze: TileMapLayer = %Maze
@onready var pointer: Node2D = %Pointer
@onready var camera_2d: Camera2D = %Camera2D
@onready var mouse_indicator: TileMapLayer = %MouseIndicator
@onready var camera_viewport = camera_2d.get_viewport_rect().size

var prev_viewport_with_zoom: Vector2
@onready var prev_camera_position = camera_2d.get_screen_center_position()
var camera_max_zoom_limit = Vector2(2, 2)
var camera_min_zoom_limit = Vector2(1, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emit_camera_view_port_changed()

func _process(delta: float) -> void:
	if Input.is_action_pressed('mouse_left'):
		var selected_tile = maze.local_to_map(get_global_mouse_position())
		maze.set_cells_terrain_connect([selected_tile], 0, 0 , false)
	elif Input.is_action_pressed('mouse_right'):
		pointer.position = pointer.position.lerp(get_global_mouse_position(), 2.0 * delta)
		emit_camera_view_port_changed()
		#var selected_tile = maze.local_to_map(get_global_mouse_position())
		#maze.erase_cell(selected_tile)	
	elif Input.is_action_just_pressed("mouse_up"):		
		if camera_2d.zoom < camera_max_zoom_limit:
			camera_2d.zoom = camera_2d.zoom + camera_2d.zoom * 0.1
			emit_camera_view_port_changed()
			
	elif Input.is_action_just_pressed("mouse_down"):
		if camera_2d.zoom > camera_min_zoom_limit:			
			camera_2d.zoom = camera_2d.zoom - camera_2d.zoom * 0.1
			emit_camera_view_port_changed()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_indicator.clear()
		var selected_tile = mouse_indicator.local_to_map(get_global_mouse_position())
		mouse_indicator.set_cell(selected_tile, 0 , Vector2i(0,0))		
		emit_camera_view_port_changed()

func emit_camera_view_port_changed():
	var current_viewport_with_zoom = (Vector2(1, 1) / camera_2d.zoom) * camera_viewport
	var current_camera_position = camera_2d.get_screen_center_position()
	
	if current_viewport_with_zoom != prev_viewport_with_zoom:
		prev_viewport_with_zoom = current_viewport_with_zoom
		SharedSignals.camera_viewport_changed.emit(current_viewport_with_zoom, current_camera_position)

	if current_camera_position != prev_camera_position:
		prev_camera_position = current_camera_position
		SharedSignals.camera_viewport_changed.emit(current_viewport_with_zoom, current_camera_position)
