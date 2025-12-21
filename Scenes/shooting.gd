extends Node2D

@export var laser_scene: PackedScene

var can_player_shoot = true
func _input(event):
	if Input.is_action_just_pressed("shoot") && can_player_shoot:
		can_player_shoot = false
		var laser = laser_scene.instantiate() as Laser
		laser.global_position = get_parent().global_position + Vector2(20, 0)
		if get_parent().has_method("play_shoot_sound"):
			get_parent().play_shoot_sound()
		get_tree().root.get_node("main").add_child(laser)
		laser.tree_exited.connect(on_laser_destroyed)

func on_laser_destroyed():
	can_player_shoot = true
