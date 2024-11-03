extends Node2D
@onready var maze: TileMapLayer = %Maze
@onready var pointer: Node2D = %Pointer
@onready var camera_2d: Camera2D = %Camera2D
@onready var mouse_indicator: TileMapLayer = %MouseIndicator
@onready var camera_viewport = camera_2d.get_viewport_rect().size
@onready var canvas_layer: CanvasLayer = %ButtonsLayer
@onready var popup_layer: CanvasLayer = $PopupLayer

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
@onready var save_btn: Button = %Save
@onready var load_btn: Button = %Load
@onready var upload_btn: Button = %Upload
@onready var slot_1_btn: Button = %"Slot 1"
@onready var slot_2_btn: Button = %"Slot 2"
@onready var slot_3_btn: Button = %"Slot 3"
@onready var popup_exit_btn: Button = %PopupExit
@onready var exit_btn: Button = %Exit

enum POPUP_MODE {
	SAVE,
	LOAD
}

enum MAP_EDITOR_ACTION {
	MOVE,
	DRAW_PATH,
	ADD_START,
	ADD_END,
	ERASE_CELL
}

var current_map_editor_action = MAP_EDITOR_ACTION.DRAW_PATH
var any_button_pressed := false

var curent_popup_mode = POPUP_MODE.SAVE
var show_popup := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.current_game_mode = Global.GAME_MODE.EDITOR
	
	connect_btn_and_event_without_propagation(
		move_btn, 
		func() -> void:
			current_map_editor_action = MAP_EDITOR_ACTION.MOVE
		
	)
	
	connect_btn_and_event_without_propagation(
		path_btn, 
		func() -> void:
			current_map_editor_action = MAP_EDITOR_ACTION.DRAW_PATH		
	)
	
	connect_btn_and_event_without_propagation(erase_btn, 
		func() -> void:
			current_map_editor_action = MAP_EDITOR_ACTION.ERASE_CELL		
	)
	
	connect_btn_and_event_without_propagation(
		start_btn, 
		func() -> void:
			current_map_editor_action = MAP_EDITOR_ACTION.ADD_START		
	)
	
	connect_btn_and_event_without_propagation(
		end_btn, 
		func() -> void:
			current_map_editor_action = MAP_EDITOR_ACTION.ADD_END			
	)
	
	
	connect_btn_and_event_without_propagation(
		play_btn,
		_on_play_btn
	)
	
	connect_btn_and_event_without_propagation(
		save_btn, 
		_on_save_btn
	)
	
	connect_btn_and_event_without_propagation(
		load_btn,
		_on_load_btn
	)
	connect_btn_and_event_without_propagation(check_btn, _on_check_path)
	
	popup_exit_btn.pressed.connect(func() -> void:
		set_popup_visible(false)
	)
	
	var slot_1_file_path = get_file_path_from_mapname('one')
	slot_1_btn.text = get_modified_date_from_file(slot_1_file_path)
	
	var slot_2_file_path = get_file_path_from_mapname('two')
	slot_2_btn.text = get_modified_date_from_file(slot_2_file_path)
	
	var slot_3_file_path = get_file_path_from_mapname('three')
	slot_3_btn.text = get_modified_date_from_file(slot_2_file_path)	
	
	slot_1_btn.pressed.connect(func() -> void:		
		_on_slot_item_click("one", slot_1_btn)
	)
	
	slot_2_btn.pressed.connect(func() -> void:
		_on_slot_item_click("two", slot_2_btn)
	)
	
	slot_3_btn.pressed.connect(func() -> void:
		_on_slot_item_click("three", slot_3_btn)
	)
	
	connect_btn_and_event_without_propagation(exit_btn, func() -> void:
		get_tree().change_scene_to_file("res://scene/start_scene.tscn")	
	)
	
	SharedSignals.exit_preview.connect(_on_exit_preview)	
	
	emit_camera_view_port_changed()

func _process(delta: float) -> void:
	if Input.is_action_pressed('mouse_left'):
		if show_popup or any_button_pressed or visible == false:
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
		if show_popup:
			return
		mouse_indicator.clear()
		var selected_tile = mouse_indicator.local_to_map(get_global_mouse_position())
		mouse_indicator.set_cell(selected_tile, 0 , Vector2i(0,0))		
		emit_camera_view_port_changed()

	if event is InputEventGesture and event is InputEventPanGesture:		
		pointer.position += event.delta * 2.5
		
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
	
	_set_visiblity(false)

func _set_visiblity(visiblity: bool) -> void:
	visible = visiblity
	canvas_layer.visible = visiblity
	camera_2d.enabled = visiblity

func _on_exit_preview() -> void:
	Global.current_game_mode = Global.GAME_MODE.EDITOR
	_set_visiblity(true)

func connect_btn_and_event_without_propagation(btn: Button, callback: Callable) -> void:
	btn.pressed.connect(func() -> void:
		any_button_pressed = true
		callback.call()	
	)
	
	btn.button_up.connect(func() -> void:
		any_button_pressed = false
	)

func set_popup_visible(visible: bool) -> void:
	show_popup = visible
	popup_layer.visible = visible

func _on_save_btn() -> void:
	curent_popup_mode = POPUP_MODE.SAVE
	set_popup_visible(true)

func save_slot(map_name: String) -> String:
	var directory = DirAccess.open('user://')
	
	if !directory.dir_exists("user://maps"):
		directory.make_dir_recursive("user://maps")
	
	var file_path = get_file_path_from_mapname(map_name)
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	file.store_buffer(maze.get_tile_map_data_as_array())		
	
	return get_modified_date_from_file(file_path)

func get_file_path_from_mapname(map_name: String) -> String:
	return "user://maps/map-%s.dat" % map_name

func get_modified_date_from_file(file_path: String) -> String:
	var modified_time = FileAccess.get_modified_time(file_path)
	
	modified_time = Time.get_datetime_dict_from_unix_time(modified_time)	
	
	var modified_time_string = "%s-%s-%s %s:%s:%s" % [modified_time.year, modified_time.month, modified_time.day, modified_time.hour, modified_time.minute, modified_time.second]
	
	return modified_time_string

func _on_load_btn() -> void:
	curent_popup_mode = POPUP_MODE.LOAD
	set_popup_visible(true)	

func _on_slot_item_click(map_name: String, slot_btn: Button) -> void:
	if curent_popup_mode == POPUP_MODE.SAVE:		
		slot_btn.text = save_slot(map_name)
		return 
		
	var file_path = get_file_path_from_mapname(map_name)
	var file := FileAccess.get_file_as_bytes(file_path)
	
	maze.set_tile_map_data_from_array(file)
	
