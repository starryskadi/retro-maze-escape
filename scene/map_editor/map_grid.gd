extends Node2D

@onready var maze: TileMapLayer = %Maze
@onready var maze_cell_size = maze.rendering_quadrant_size 

var COLOR: Color = Color(Color.BLACK, 0.1)
var cell_line_size = 1
var camera_viewport: Vector2
var camera_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	draw.connect(_draw)
	SharedSignals.camera_viewport_changed.connect(_on_viewport_changed)

func _draw() -> void:	
	var half_camera_viewport = camera_viewport / 2
	var camera_start_position = camera_position - half_camera_viewport
	var camera_end_position = camera_position + half_camera_viewport
	
	var cell_start_position = camera_start_position / maze_cell_size
	var cell_end_position = camera_end_position / maze_cell_size
	
	for i in range(cell_start_position.x, cell_end_position.x + 1):
		var x = i * maze_cell_size
		var sy = cell_start_position.y * maze_cell_size
		var ey = cell_end_position.y * maze_cell_size
		draw_line(Vector2(x, sy), Vector2(x, ey), COLOR, cell_line_size, false)

	for i in range(cell_start_position.y, cell_end_position.y + 1):
		var y = i * maze_cell_size
		var sx = cell_start_position.x * maze_cell_size
		var ex = cell_end_position.x * maze_cell_size
		draw_line(Vector2(sx, y), Vector2(ex, y), COLOR, cell_line_size, false)	
	
func _on_viewport_changed(changed_camera_viewport, changed_camera_position) -> void:
	camera_viewport = changed_camera_viewport
	camera_position = changed_camera_position
	queue_redraw()	
