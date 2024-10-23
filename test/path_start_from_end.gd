extends Node2D
@onready var trees: TileMapLayer = %Trees





const GRID_SIZE = 16

var maze_matrix = []
var visited_cells = []
var directions = [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]
var last_direcion = Vector2i(0 , 1)

var viewport = Vector2(320, 240)
var maze_size = Vector2(viewport.x / GRID_SIZE, viewport.y / GRID_SIZE)

var rng = RandomNumberGenerator.new()
var start = Vector2(1, 1)
var end = Vector2(maze_size.x - 2, maze_size.y - 2)

enum MAZE_TILE_TYPE {
	WALL,
	PATH,
	EMPTY,
	START,
	END
}

var temp_iter_count := 0
var temp_max_iter_count := 10

func _crave_path(walk_position: Vector2i, dir: Vector2i) -> void: 
#	# don't walk the previous path
	maze_matrix[walk_position.y][walk_position.x] = MAZE_TILE_TYPE.PATH
	
	#if dir.x != 0 and dir.y == 0:
		#var prev_cell = walk_position.y - 1
		#var next_cell = walk_position.y + 1
		#if prev_cell > -1 and prev_cell < maze_size.y:
			#maze_matrix[prev_cell][walk_position.x] = MAZE_TILE_TYPE.WALL
		#
		#if next_cell > -1 and next_cell < maze_size.y:
			#maze_matrix[next_cell][walk_position.x] = MAZE_TILE_TYPE.WALL
	#elif dir.x == 0 and dir.y != 0:
		#var prev_cell = walk_position.x - 1
		#var next_cell = walk_position.x + 1
		#
		#if prev_cell > -1 and prev_cell < maze_size.x:
			#maze_matrix[walk_position.y][prev_cell] = MAZE_TILE_TYPE.WALL
		#
		#if next_cell > -1 and next_cell < maze_size.x:
			#maze_matrix[walk_position.y][next_cell] = MAZE_TILE_TYPE.WALL
		#
	visited_cells.append(Vector2i(walk_position.x, walk_position.y))
	# Don't stop walking unless it reach to end
	rng.randomize()
	directions.shuffle()
	
	for direction in directions:
		var nx = walk_position.x + direction.x 
		var ny = walk_position.y + direction.y 
		
		var nx_twice = walk_position.x + direction.x * 2
		var ny_twice  = walk_position.y + direction.y * 2
		
		#var is_wall_ahead_x = (
			#dir.x != 0 and 
			#dir.y == 0 and 
			#nx_twice > -1 and 
			#nx_twice < maze_size.x 
			#and maze_matrix[ny][nx_twice] == MAZE_TILE_TYPE.WALL			
		#)
		
		var is_cell_valid = (
			nx >= 0 and 
			ny >= 0 and 
			nx < maze_size.x and 
			ny < maze_size.y and	
			maze_matrix[ny][nx] != MAZE_TILE_TYPE.END and
			!visited_cells.has(Vector2i(nx, ny)) and
			temp_iter_count < temp_max_iter_count
		)
		
		if is_cell_valid:
			temp_iter_count += 1	
			_crave_path(Vector2i(nx, ny), direction)				
		
func _generate_maze_matrix() -> Array:
	for i in maze_size.y:
		var row = []
		for x in range(maze_size.x):
			row.append(MAZE_TILE_TYPE.EMPTY)
		maze_matrix.append(row) 
	
	_crave_path(Vector2i(2, 1), Vector2i(1, 0))
	
	return maze_matrix
	
func _ready() -> void:
	_generate_maze_matrix()
	
	maze_matrix[start.y][start.x] = MAZE_TILE_TYPE.START
	visited_cells.append(Vector2i(start.x, start.y))
	maze_matrix[end.y][end.x] = MAZE_TILE_TYPE.END
	
	for rows in maze_matrix.size():
		for col in maze_matrix[rows].size(): 
			var cell = maze_matrix[rows][col]
			if cell == MAZE_TILE_TYPE.START:
				trees.set_cell(Vector2i(col, rows), 0, Vector2i(0, 1))
			elif cell == MAZE_TILE_TYPE.END:	
				trees.set_cell(Vector2i(col, rows), 0, Vector2i(0, 1))
			elif cell == MAZE_TILE_TYPE.PATH:
				trees.set_cell(Vector2i(col, rows), 0, Vector2i(1, 1))
			elif cell == MAZE_TILE_TYPE.WALL:
				pass
				#trees.set_cell(Vector2i(col, rows), 0, Vector2i(0, 2))
			
func _process(delta: float) -> void:
	pass
