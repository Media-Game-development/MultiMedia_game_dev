extends Area2D

class_name Laser

@export var speed = 500
@export var direction = -1

func _process(delta):
	position.x -= delta * direction * speed
