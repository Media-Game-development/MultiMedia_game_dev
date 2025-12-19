extends Timer

class_name SpawnTimer
@export var min_time = 5
@export var max_timer = 10

func _ready() -> void:
	setup_timer()

func setup_timer ():
	var random_time = randi_range(min_time, max_timer)
	self.wait_time = random_time
	self.stop()
	self.start()
	
