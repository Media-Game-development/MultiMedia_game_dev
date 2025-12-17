extends CanvasLayer
@onready var invader_1_texture: TextureRect = %Invader1Texture
@onready var invader_1_label: Label = %Invader1Label
@onready var invader_2_texture: TextureRect = %Invader2Texture
@onready var invader_2_label: Label = %Invader2Label
@onready var invader_3_texture: TextureRect = %Invader3Texture
@onready var invader_3_label: Label = %Invader3Label

@onready var timer: Timer = $Timer


var control_array = []
func _ready() -> void:
	control_array.append_array([invader_1_texture, invader_1_label, invader_2_texture, invader_2_label, 
	invader_3_texture,invader_3_label])

	for control in control_array:
		(control as Control).modulate = Color.TRANSPARENT

func load_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func show_next_control() -> void:
	var control = control_array.pop_front() as Control
	if control != null:
		control.modulate = Color.WHITE
	else:
		timer.stop()
		timer.queue_free()
