extends CanvasLayer
@onready var exit_btn: Button = %Exit
@onready var text_edit: TextEdit = %TextEdit
@onready var save_btn: Button = %Save

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	exit_btn.pressed.connect(func() -> void:
		queue_free()	
	)
	
	save_btn.pressed.connect(func() -> void:
		Global.update_save_paste_bin_key(text_edit.text)
	)
