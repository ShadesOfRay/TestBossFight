extends Camera2D

class_name WorldCamera

onready var timer_shake_length = $timer_shake_length
onready var tween_shake = $tween_camera_shake

var reset_speed = 0
var strength = 0
var max_strength = 0
var default_offset = offset

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	timer_shake_length.connect("timeout", self, "timeout_shake_length")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	offset = Vector2(rand_range(-strength, strength), rand_range(-strength, strength)) * delta + default_offset
	#print(offset)


func start_shake(time_of_shake = 1.0, speed_of_shake = 0.1, strength_of_shake = 5):
	strength += strength_of_shake
	max_strength = max(2*strength_of_shake, max_strength)
	if strength > max_strength:
		strength = max_strength
		
	reset_speed = speed_of_shake
	timer_shake_length.wait_time = time_of_shake
	
	tween_shake.stop_all()
	set_process(true)
	timer_shake_length.start(time_of_shake)
	#timer_wait_times.start(speed_of_shake)
	#print("made it here too")

	
func timeout_shake_length():
	strength = 0
	set_process(false)
	
	tween_shake.interpolate_property(self, "offset", offset, default_offset,
	0.2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween_shake.start()

