extends Area2D

class_name FinalBoss

signal health_changed(new_health)

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var config:Resource

@export var max_health: int = 20
var health: int = max_health
@onready var fire_timer: Timer =Timer.new()
var shot_scene =preload("res://Scenes/invader_shot.tscn")

func _ready() -> void:
	add_child(fire_timer)
	fire_timer.wait_time = 1.2
	fire_timer.timeout.connect(_on_fire_timeout)
	fire_timer.start()
	health = max_health
	health_changed.emit(health)
	

func _on_fire_timeout():
	spawn_shot(Vector2(-1, 0))
	spawn_shot(Vector2(-1, -0.3))
	spawn_shot(Vector2(-1, 0.3))

func spawn_shot(dir: Vector2):
	var shot = shot_scene.instantiate()
	shot.scale = Vector2(5,5)
	if "speed" in shot:
		shot.speed = 800
	get_tree().root.add_child(shot)
	shot.global_position = global_position + Vector2(-60, 0)
	
	if "direction" in shot:
		shot.direction = dir
	shot.modulate = Color.RED
	shot.z_index = 10


func _on_area_entered(area: Area2D) -> void:
	if area is Laser:
		take_damage(1)
		if area.has_method("queue_free"):
			area.queue_free()

func take_damage(amount: int):
	fire_timer.wait_time = clamp(fire_timer.wait_time - 0.05, 0.4, 1.2)
	health -= amount
	health_changed.emit(health)
	# Visual feedback: Flash red
	modulate = Color.RED
	await get_tree().create_timer(0.05).timeout
	modulate = Color.WHITE
	
	$HitSoundEffect.pitch_scale = randf_range(0.8, 1.2) 
	$HitSoundEffect.play()
	
	if health <= 0:
		queue_free()
