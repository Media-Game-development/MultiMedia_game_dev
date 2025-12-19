extends Area2D

class_name FinalBoss

@export var health: int = 20
@onready var fire_timer: Timer =Timer.new()
var shot_scene =preload("res://Scenes/invader_shot.tscn")

func _ready() -> void:
	add_child(fire_timer)
	fire_timer.wait_time = 1.2
	fire_timer.timeout.connect(_on_fire_timeout)
	fire_timer.start()

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
	# This assumes your player's laser is named "Laser" or has a script
	if area is Laser:
		take_damage(1)
		if area.has_method("queue_free"):
			area.queue_free() # Destroy the laser that hit us

func take_damage(amount: int):
	health -= amount
	# Visual feedback: Flash red
	fire_timer.wait_time = clamp(fire_timer.wait_time - 0.05, 0.4, 1.2)
	modulate = Color.RED
	await get_tree().create_timer(0.05).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		queue_free() # This triggers the 'tree_exited' signal in the spawner
