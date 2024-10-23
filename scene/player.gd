extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

const SPEED = 30.0

func _ready() -> void:
	animated_sprite_2d.play('idle')
	animation_player.play('torch_light')


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED	
	
	move_and_slide()
