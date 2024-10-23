extends Node2D

var mazes = []
var dirs: Array[Vector2] = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
var rng := RandomNumberGenerator.new()

var width := 50
var height := 50

func _is_cell_valid(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < width  and y < height and mazes[y][x] == 'wall'

func _crave_path(x, y) -> void:
	mazes[y][x] = 'path'
	
	rng.randomize()
	dirs.shuffle()
	
	for direction: Vector2 in dirs:
		var dx = direction.x
		var dy = direction.y
		
		var nx = x + dx * 2
		var ny = y + dy * 2
		
		if _is_cell_valid(nx, ny):
			mazes[y + dy][x + dx] = "path"
			_crave_path(nx, ny)
		
func _generate_maze() -> void:
	for i in height:
		var row = []
		
		for j in width: 
			row.append("wall")
			
		mazes.append(row)
		
	_crave_path(1 ,1)
	
func _ready() -> void:
	_generate_maze()	
	
	for row in mazes.size():
		for col in mazes[row].size():
			var color_rect = ColorRect.new()
			color_rect.size.x = 16.0
			color_rect.size.y = 16.0
			
			color_rect.position.x = col * 16.0
			color_rect.position.y = row * 16.0
			
			var cell = mazes[row][col]
			if cell == "wall":
				color_rect.color = Color.BLACK
			
			add_child(color_rect)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
