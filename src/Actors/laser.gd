extends Area2D

class_name Laser

signal finished_charging
signal laser_fired
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var laser_size
var windup_time
var warning_time
var laser_duration
var camera = preload("res://src/camera.tscn")
var direction = Vector2.ZERO
var target_rotation

func _init(position: Vector2 = Vector2.ZERO, direction: float = 0.0, size: float = 1, delay: float = 1.0, warning: float = 0.5, duration: float = 1.5):
	self.direction.x = cos(direction)
	self.direction.y = sin(direction)
	set_position(position)
	rotate(direction)
	laser_size = size
	windup_time = delay
	warning_time = warning
	laser_duration = duration

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree(), "idle_frame")
	var scale_vec = Vector2(laser_size,laser_size)
	$LaserHitbox.set_scale(scale_vec)
	$LaserSprite.set_scale(scale_vec)
	#print("charging")
	#$ChargeAnimation.play()
	$LaserSprite.set_position(Vector2(1.301, 28.397))
	$LaserSprite.set_scale(Vector2(0.42 * laser_size, 0.348 * laser_size))
	$LaserSprite.set_frame(0)
	$LaserHitbox.set_disabled(true)
	soft_shake()
	yield(get_tree().create_timer(windup_time), "timeout")
	#$ChargeAnimation.stop()
	#print("warning....")
	emit_signal("finished_charging")
	yield(get_tree().create_timer(warning_time), "timeout")
	#print("shooting...")
	#$ShootAnimation.play()
	$LaserSprite.set_position(Vector2(32, 452))
	$LaserSprite.set_scale(Vector2(1.6 * laser_size, 1.939 * laser_size))
	$LaserSprite.set_frame(1)
	$LaserHitbox.set_disabled(false)
	shake_screen()
	yield(get_tree().create_timer(laser_duration), "timeout")
	#$ShootAnimation.stop()
	
	
	#print("made it here!")
	#yield($ShootAnimation, "animation_finished")
	queue_free()
	emit_signal("laser_fired")
	
func shake_screen():
	var cam = get_tree().root.get_child(0).get_node("Camera2D")
	cam.start_shake(laser_duration, 0.1, 800)
	

func soft_shake():
	var cam = get_tree().root.get_child(0).get_node("Camera2D")
	cam.start_shake(warning_time + windup_time, 0.1, 100)

func _on_Laser_body_entered(body):
	var player := body as Player
	if not player:
		#queue_free()
		return
	
	print("LASER HIT!");
	player.damage(2)
	#queue_free()

func _about_to_fire():
	emit_signal("finished_charging")
	
	
