extends Node2D
@onready var maze: TileMapLayer = %Maze
@onready var pointer: Node2D = %Pointer
@onready var camera_2d: Camera2D = %Camera2D
@onready var mouse_indicator: TileMapLayer = %MouseIndicator
@onready var camera_viewport = camera_2d.get_viewport_rect().size
@onready var canvas_layer: CanvasLayer = %CanvasLayer

var prev_viewport_with_zoom: Vector2
@onready var prev_camera_position = camera_2d.get_screen_center_position()
var camera_max_zoom_limit = Vector2(2, 2)
var camera_min_zoom_limit = Vector2(1, 1)

@onready var path_btn: Button = %Path
@onready var erase_btn: Button = %Erase
@onready var start_btn: Button = %Start
@onready var end_btn: Button = %End
@onready var move_btn: Button = %Move
@onready var check_btn: Button = %Check
@onready var play_btn: Button = %Play

enum MAP_EDITOR_ACTION {
	MOVE,
	DRAW_PATH,
	ADD_START,
	ADD_END,
	ERASE_CELL
}

var current_map_editor_action = MAP_EDITOR_ACTION.DRAW_PATH
var any_button_pressed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.current_game_mode = Global.GAME_MODE.EDITOR
	
	move_btn.pressed.connect(func() -> void:
		current_map_editor_action = MAP_EDITOR_ACTION.MOVE
		any_button_pressed = true
	)
	
	move_btn.button_up.connect(func() -> void:
		any_button_pressed = false
	)
	
	path_btn.pressed.connect(func() -> void:
		current_map_editor_action = MAP_EDITOR_ACTION.DRAW_PATH		
		any_button_pressed = true
	)
	
	path_btn.button_up.connect(func() -> void:
		any_button_pressed = false
	)
	
	erase_btn.pressed.connect(func() -> void:
		current_map_editor_action = MAP_EDITOR_ACTION.ERASE_CELL
		any_button_pressed = true
	)
	
	erase_btn.button_up.connect(func() -> void:
		any_button_pressed = false
	)
	
	start_btn.pressed.connect(func() -> void:
		current_map_editor_action = MAP_EDITOR_ACTION.ADD_START
		any_button_pressed = true
	)
	
	start_btn.button_up.connect(func() -> void:
		any_button_pressed = false
	)
	
	end_btn.pressed.connect(func() -> void:
		current_map_editor_action = MAP_EDITOR_ACTION.ADD_END
		any_button_pressed = true
	)
	
	end_btn.button_up.connect(func() -> void:
		any_button_pressed = false
	)
	
	play_btn.pressed.connect(_on_play_btn)
	
	play_btn.button_up.connect(func() -> void:
		any_button_pressed = false
	)
	
	check_btn.pressed.connect(_on_check_path)
	
	SharedSignals.exit_preview.connect(_on_exit_preview)
	
	emit_camera_view_port_changed()

func _process(delta: float) -> void:
	if Input.is_action_pressed('mouse_left'):
		if any_button_pressed or visible == false:
			return
		var selected_tile = maze.local_to_map(get_global_mouse_position())
		match current_map_editor_action:
			MAP_EDITOR_ACTION.MOVE:
				_move_pointer(delta)
			MAP_EDITOR_ACTION.DRAW_PATH:				
				maze.set_cells_terrain_connect([selected_tile], 0, 0 , false)
			MAP_EDITOR_ACTION.ERASE_CELL:				
				maze.erase_cell(selected_tile)	
			MAP_EDITOR_ACTION.ADD_START:					
				var start_cells = maze.get_used_cells_by_id(1, Vector2.ZERO, 2)
				for cell in start_cells:
					maze.erase_cell(cell)		
								
				maze.set_cell(selected_tile, 1, Vector2.ZERO, 2)	
			MAP_EDITOR_ACTION.ADD_END:	
				var end_cells = maze.get_used_cells_by_id(1, Vector2.ZERO, 1)
				for cell in end_cells:
					maze.erase_cell(cell)
									
				maze.set_cell(selected_tile, 1, Vector2.ZERO, 1)	
				
	elif Input.is_action_pressed('mouse_right'):
		_move_pointer(delta)

	elif Input.is_action_just_pressed("mouse_up"):		
		if camera_2d.zoom < camera_max_zoom_limit:
			camera_2d.zoom = camera_2d.zoom + camera_2d.zoom * 0.1
			emit_camera_view_port_changed()
			
	elif Input.is_action_just_pressed("mouse_down"):
		if camera_2d.zoom > camera_min_zoom_limit:			
			camera_2d.zoom = camera_2d.zoom - camera_2d.zoom * 0.1
			emit_camera_view_port_changed()

func _move_pointer(delta: float) -> void:
	pointer.position = pointer.position.lerp(get_global_mouse_position(), 2.0 * delta)
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

func _on_check_path() -> void:
	var navigation_map = maze.get_navigation_map()
	
func _on_play_btn() -> void:
	any_button_pressed = true
	
	var game_scene = load("res://game.tscn").instantiate()
	game_scene.initial_tilemap_data = maze.get_tile_map_data_as_array()
	game_scene.from_editor_mode = true
	
	add_sibling(game_scene)
	
	_toggle_visiblity()

func _toggle_visiblity() -> void:
	visible = !visible
	canvas_layer.visible = !canvas_layer.visible
	camera_2d.enabled = !camera_2d.enabled

func _on_exit_preview() -> void:
	Global.current_game_mode = Global.GAME_MODE.EDITOR
	_toggle_visiblity()
