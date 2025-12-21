extends Node

class_name LifeManager

signal life_lost(lifes_left: int)


@export var lifes = 3
@onready var player:Player =$"../Player"
var player_scene = preload("res://Scenes/player.tscn")
@onready var music_player: AudioStreamPlayer = get_tree().root.find_child("BackgroundMusic", true, false)

func _ready():
	(player as Player).player_destroyed.connect(on_player_destroyed)

func on_player_destroyed():
	lifes -= 1
	life_lost.emit(lifes)
	if lifes != 0:
		player = player_scene.instantiate() as Player
		player.global_position = Vector2(-540,0)
		player.player_destroyed.connect(on_player_destroyed)
		get_tree().root.get_node("main").add_child(player)
	else:
		trigger_game_over()

func trigger_game_over ():
	var music = get_parent().get_node_or_null("BackgroundMusic")
	if music:
		music.stop()
	var lose_sound = get_tree().root.find_child("GameOverSound", true, false)
	if lose_sound:
		lose_sound.play()
	var spawner = get_tree().root.find_child("InvaderSpawner", true, false)
	if spawner:
		spawner.movement_timer.stop()
		spawner.shot_timer.stop()
