extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

const SPEED = 45.0

func _ready() -> void:
	animated_sprite_2d.play('idle')
	animation_player.play('torch_light')


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED	
	
	var direction_discrete = direction.sign()
	
	match direction_discrete:
		Vector2.UP:
			animated_sprite_2d.play('back_walk')
		Vector2.DOWN:
			animated_sprite_2d.play('idle')
		Vector2.LEFT, Vector2.RIGHT:
			animated_sprite_2d.play('side_walk')
	
	if direction.length() > 0:
		if direction.y == 0:
			animated_sprite_2d.flip_h = direction.x < 0.0
	
	move_and_slide()
