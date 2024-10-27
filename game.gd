extends Node2D
@onready var maze_tilemap: TileMapLayer = %Maze
@onready var breadcrumbs_tilemap: TileMapLayer = %Breadcrumbs
@onready var label: Label = %Label

var total_breadcrumbs := 10
var breadcrumbs_locations: Array[Vector2i] = []

var initial_tilemap_data: PackedByteArray = []
var from_editor_mode = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.current_game_mode = Global.GAME_MODE.GAME	
	
	if initial_tilemap_data.size():
		maze_tilemap.set_tile_map_data_from_array(initial_tilemap_data)
		
	SharedSignals.breadcrumbs_added.connect(_on_breadcrumbs_added)

func add_breadcrumbs(grid: Vector2i) -> void:
	var is_already_breadcrumbs = breadcrumbs_locations.find(grid)
	
	if breadcrumbs_locations.size() >= total_breadcrumbs:
		breadcrumbs_locations.pop_front()
	
	if is_already_breadcrumbs != -1:
		breadcrumbs_locations.pop_at(is_already_breadcrumbs)
	else: 
		breadcrumbs_locations.append(grid)	
	
	breadcrumbs_tilemap.clear()
	label.text = 'x ' + str(breadcrumbs_locations.size())
	for location in breadcrumbs_locations:
		breadcrumbs_tilemap.set_cell(location, 2, Vector2i(0, 0))

func _on_breadcrumbs_added(player_position) -> void:
	var current_grid_of_player = breadcrumbs_tilemap.local_to_map(player_position)	
	add_breadcrumbs(current_grid_of_player)

func _unhandled_input(event: InputEvent) -> void:	
	if from_editor_mode:
		if event.is_action('ui_cancel') and event.is_action_pressed("ui_cancel"):
			queue_free()
			SharedSignals.exit_preview.emit()
