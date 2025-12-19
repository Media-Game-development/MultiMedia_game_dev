extends Node2D

class_name InvaderSpawner

signal invader_destroyed(points: int)
signal game_won
signal game_lost


#SpawnerConfiguration
const ROWS = 5
const COLUMNS = 5
const HORIZONTAL_SPACING = 45
const VERTICAL_SPACING = 45
const INVADER_WIDTH = 30
const START_X_POSITION = 1000
const INVADER_MOVE_Y_INCREMENT = 10
const INVADER_STEP_LEFT_INCREMENT = 20

var movement_direction = 1
var invader_scene = preload("res://Scenes/invader.tscn")
var invader_shot_scene = preload("res://Scenes/invader_shot.tscn")

var invader_destroyed_count = 0
var invader_total_count = ROWS * COLUMNS

#NODE REFERENCES
@onready var movement_timer: Timer = $MovementTimer
@onready var shot_timer: Timer = $ShotTimer


func _ready() -> void:
	#SETUP TIMERS
	movement_timer.timeout.connect(move_invaders)
	shot_timer.timeout.connect(on_invader_shot)
	
	var invader_1_res = preload("res://Resources/invader_1.tres")
	var invader_2_res = preload("res://Resources/invader_2.tres")
	var invader_3_res = preload("res://Resources/invader_3.tres")
	
	var screen_width = get_viewport_rect().size.x
	var invader_config
	
	for col in COLUMNS:
		if col == 0:
			invader_config = invader_3_res
		elif col == 1 || col == 2:
			invader_config = invader_2_res
		elif col ==3 || col == 4:
			invader_config = invader_1_res
		
		for row in ROWS:
			var x = (screen_width - 850) + (col * (invader_config.width + HORIZONTAL_SPACING))
			var y = 100 + (row * (INVADER_WIDTH + VERTICAL_SPACING))
			var spawn_position = Vector2(x, y)
			
			spawn_invader(invader_config, spawn_position)
	

func spawn_invader(invader_config, spawn_position: Vector2):
	var invader = invader_scene.instantiate() as Invader
	invader.config = invader_config
	invader.global_position = spawn_position
	invader.invader_destroyed.connect(on_invader_destroyed)
	add_child(invader)
	print("Spawning invader at: ", spawn_position)

func move_invaders():
	position.y += INVADER_MOVE_Y_INCREMENT * movement_direction

func _on_left_wall_area_entered(area: Area2D) -> void:
	if movement_direction == -1:
		position.x -= INVADER_STEP_LEFT_INCREMENT
		movement_direction = 1


func _on_right_wall_area_entered(area: Area2D) -> void:
	if movement_direction == 1:
		position.x -= INVADER_STEP_LEFT_INCREMENT
		movement_direction = -1

func on_invader_shot ():
	var random_child_position = get_children().filter(func (child): return child is Invader).map(func (invader): return invader.global_position).pick_random()

	var invader_shot = invader_shot_scene.instantiate() as InvaderShot
	invader_shot.global_position = random_child_position
	get_tree().root.add_child(invader_shot)

func on_invader_destroyed(points: int):
	invader_destroyed.emit(points)
	invader_destroyed_count += 1
	
	if invader_destroyed_count == invader_total_count:
		game_won.emit()
		shot_timer.stop()
		movement_timer.stop()
		movement_direction = 0
		


func _on_bottom_wall_area_entered(area: Area2D) -> void:
	game_lost.emit()
	movement_timer.stop()
	movement_direction = 0
