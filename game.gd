extends Node2D
@onready var maze_tilemap: TileMapLayer = %Maze
@onready var player: CharacterBody2D = %Player
@onready var breadcrumbs_tilemap: TileMapLayer = %Breadcrumbs

signal breadcrumb_changed(breadcrumbs_locations: Vector2i, total_breadcrumbs: int)

var total_breadcrumbs := 3
var breadcrumbs_locations: Array[Vector2i] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	breadcrumb_changed.connect(_on_breadcrumbs_changed)

func add_breadcrumbs(grid: Vector2i) -> void:
	var is_already_breadcrumbs = breadcrumbs_locations.find(grid)
	
	if breadcrumbs_locations.size() >= total_breadcrumbs:
		breadcrumbs_locations.pop_front()
	
	if is_already_breadcrumbs != -1:
		breadcrumbs_locations.pop_at(is_already_breadcrumbs)
	else: 
		breadcrumbs_locations.append(grid)	

	breadcrumb_changed.emit(breadcrumbs_locations, total_breadcrumbs)

func _unhandled_input(event: InputEvent) -> void:		
	if event.is_action('put_breadcrumb') and event.is_action_pressed("put_breadcrumb"):
		var current_grid_of_player = breadcrumbs_tilemap.local_to_map(player.position)	
		add_breadcrumbs(current_grid_of_player)

func _on_breadcrumbs_changed(breadcrumbs_locations: Array[Vector2i], total_breadcrumbs: int) -> void:
	breadcrumbs_tilemap.clear()
	for location in breadcrumbs_locations:
		breadcrumbs_tilemap.set_cell(location, 2, Vector2i(0, 0))
