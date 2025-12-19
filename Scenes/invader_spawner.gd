extends Node2D

class_name InvaderSpawner
@onready var boss_hp_bar = get_tree().root.find_child("BossHPBar", true, false)
@export var boss_scene: PackedScene

signal invader_destroyed(points: int)
signal game_won
signal game_lost


#SpawnerConfiguration
const ROWS = 1
const COLUMNS = 1
const HORIZONTAL_SPACING = 45
const VERTICAL_SPACING = 45
const INVADER_WIDTH = 30
const START_X_POSITION = 1000
const INVADER_MOVE_Y_INCREMENT = 10
const INVADER_STEP_LEFT_INCREMENT = 20

#Difficulty Settings
var current_wave = 1
var movement_speed_y = 20
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
	start_wave()
	
func start_wave():
	invader_destroyed_count = 0
	position = Vector2.ZERO
	movement_direction = 1
	
	if current_wave == 1:
		spawn_grid(ROWS, COLUMNS)
	elif current_wave == 2:
		spawn_grid(ROWS, COLUMNS + 1)
	elif current_wave == 3:
		spawn_boss_wave()

func spawn_grid(rows: int, cols :int):
	invader_total_count = rows * cols
	var invader_1_res = preload("res://Resources/invader_1.tres")
	var invader_2_res = preload("res://Resources/invader_2.tres")
	var invader_3_res = preload("res://Resources/invader_3.tres")
	
	var screen_width = get_viewport_rect().size.x
	var invader_config
	
	for col in cols:
		if col == 0:
			invader_config = invader_3_res
		elif col == 1 || col == 2:
			invader_config = invader_2_res
		else:
			invader_config = invader_1_res
		
		for row in rows:
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
	if current_wave == 3: 
		position.y += (INVADER_MOVE_Y_INCREMENT * 2.0) * movement_direction
	else:
		position.y += INVADER_MOVE_Y_INCREMENT * movement_direction

func _on_left_wall_area_entered(area: Area2D) -> void:
	if current_wave == 3:
		movement_direction = 1
	elif movement_direction == -1: 
		position.x -= INVADER_STEP_LEFT_INCREMENT
		movement_direction = 1


func _on_right_wall_area_entered(area: Area2D) -> void:
	if current_wave == 3:
		movement_direction = -1
	if movement_direction == 1:
		position.x -= INVADER_STEP_LEFT_INCREMENT
		movement_direction = -1

func _on_bottom_wall_area_entered(area: Area2D) -> void:
	game_lost.emit()
	movement_timer.stop()
	movement_direction = 0


func on_invader_shot ():
	var invaders = get_children().filter(func (child): return child is Invader)
	if invaders.size() > 0:
		var random_invader = invaders.pick_random()
		var invader_shot = invader_shot_scene.instantiate() as InvaderShot
		invader_shot.global_position = random_invader.global_position
		get_tree().root.add_child(invader_shot)

func on_invader_destroyed(points: int):
	invader_destroyed.emit(points)
	invader_destroyed_count += 1
	
	if invader_destroyed_count >= invader_total_count:
		if current_wave <3:
			current_wave += 1
			await get_tree().create_timer(1.5).timeout
			start_wave()

func  _on_boss_killed ():
		game_won.emit()
		shot_timer.stop()
		movement_timer.stop()
		movement_direction = 0
		


	
func spawn_boss_wave():
	current_wave = 3
	invader_total_count = 1
	# 1. Reset spawner position to the top-right start area
	position = Vector2.ZERO 
	movement_timer.start()
	shot_timer.wait_time = 0.8
	shot_timer.stop()
	
	print("WAVE 3 STARTING: Spawning Boss...")
	await get_tree().create_timer(2.0).timeout
	
	
	if boss_scene:
		var boss = boss_scene.instantiate()
		add_child(boss)
		
		if boss_hp_bar:
			boss_hp_bar.max_value = boss.max_health
			boss_hp_bar.value = boss.max_health
			boss_hp_bar.show()
			boss.health_changed.connect(func(new_hp): boss_hp_bar.value = new_hp)
			
			boss.tree_exited.connect(func(): boss_hp_bar.hide())
		# Position him where your invaders usually start
		var screen_width = get_viewport_rect().size.x
		boss.position = Vector2(screen_width - 850, 200)
		
		boss.tree_exited.connect(_on_boss_killed)
	else:
		print("ERROR: Boss Scene is not assigned!")
