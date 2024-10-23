# It can produce - dead ends

extends Node2D
@onready var trees: TileMapLayer = %Trees

const GRID_SIZE = 16

var maze_matrix = []
var visited_cells = []
var last_direcion = Vector2(0 , 1)

@onready var viewport = get_tree().root.get_viewport().size
@onready var maze_size = Vector2(viewport.x / GRID_SIZE, viewport.y / GRID_SIZE)
#@onready var maze_size = Vector2(5, 5)

enum MAZE_TILE_TYPE {
	WALL,
	PATH,
	START,
	END
}

var rng = RandomNumberGenerator.new()

func _crave_path(path_position: Vector2) -> void: 
	var directions = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
	
	maze_matrix[path_position.y][path_position.x] = MAZE_TILE_TYPE.PATH
	visited_cells.append(path_position)
	rng.randomize()
	
	
	directions.shuffle()
	
	for direction in directions:
		var nx = path_position.x + direction.x * 2
		var ny = path_position.y + direction.y * 2
		
		var isCellValid = (nx >= 0 
		and ny >= 0 
		and nx < maze_size.x 
		and ny < maze_size.y 
		and maze_matrix[ny][nx] == MAZE_TILE_TYPE.WALL		
		)
		
		if isCellValid:
			maze_matrix[direction.y + path_position.y][direction.x + path_position.x] = MAZE_TILE_TYPE.PATH			
			last_direcion = direction
			_crave_path(Vector2(nx, ny))


func _generate_maze_matrix() -> Array:
	# Initialize with all walls
	for i in maze_size.y:
		print(i)
		var row = []
		for x in range(maze_size.x):
			row.append(MAZE_TILE_TYPE.WALL)
		maze_matrix.append(row)
	
	_crave_path(Vector2(1, 1))
	
	return maze_matrix 
	
func _ready() -> void:
	var matrix = _generate_maze_matrix()
	
	#var path: Array[Vector2i] = []
	
	for row in matrix.size():
		for col in matrix[row].size(): 
			var cell = matrix[row][col]
			var coords = Vector2i(col, row)
			if cell == MAZE_TILE_TYPE.PATH:				
				trees.set_cell(coords, 0, Vector2i(1,1))
			elif cell == MAZE_TILE_TYPE.WALL:				
				trees.set_cell(coords, 0, Vector2i(0,0))
				
	#trees.set_cells_terrain_connect(path, 0, 0, true)	
