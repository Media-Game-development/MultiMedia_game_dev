extends Area2D

class_name Player

signal player_destroyed

@export var speed = 200
var direction = Vector2.ZERO

@onready var collistion_rect: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var bounding_size_y
var start_bound
var end_bound


func _ready() -> void:
	bounding_size_y = collistion_rect.shape.get_rect().size.y
	
	var rect = get_viewport().get_visible_rect()
	var camera = get_viewport().get_camera_2d()
	var camera_position = camera.position
	start_bound = (camera_position.y - rect.size.y) / 2
	end_bound = (camera.position.y + rect.size.y) /2
	
	
	
	
func _process(delta: float) -> void:
	var input = Input.get_axis("move_up", "move_down")
	
	if input > 0:
		direction = Vector2.UP
	elif input < 0:
		direction = Vector2.DOWN
	else:
		direction = Vector2.ZERO
	var delta_movement = speed * delta * input
	
	#are we going out of screen bounds?
	if (position.y + delta_movement < start_bound + bounding_size_y * transform.get_scale().y ||
		position.y + delta_movement > end_bound - bounding_size_y * transform.get_scale().y):
		return
	
	position.y += delta_movement

func on_player_destroyed():
	speed = 0
	animation_player.play("destroy")
	if has_node("DeathSound"):
		$DeathSound.play()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "destroy":
		await get_tree().create_timer(1).timeout
		player_destroyed.emit()
		queue_free()

func play_shoot_sound():
	if has_node("LaserFiring"):
		$LaserFiring.play()
