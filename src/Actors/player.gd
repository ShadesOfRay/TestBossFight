extends KinematicBody2D
class_name Player

export var speed = 500
var screen_size
var motion := Vector2.ZERO
var invulnerable = false
var health = 10

signal hit
signal player_death

func _ready():
	yield(get_tree(), "idle_frame")
	#add_to_group("player")
	screen_size = get_viewport_rect().size
	get_tree().call_group("enemies", "set_player", self)

func _physics_process(delta):
	var axis = get_movement_direction()
	motion = move_and_slide(axis * speed)


func get_movement_direction() -> Vector2:
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	return axis.normalized()

func damage(amount):
	if not invulnerable:
		var old_health = health
		health -= amount
		emit_signal("hit", old_health, health)
		if health <= 0:
			emit_signal("player_death")
			queue_free()
			return
		#print("ouch")
		invulnerable = true
		#$CollisionShape2D.set_deferred("disabled", true)
		for i in range(3):
			hide()
			yield(get_tree().create_timer(0.2),"timeout") 
			show()
			yield(get_tree().create_timer(0.2),"timeout")
			
		invulnerable = false
		#set_collision_mask_bit(8, true)
		#$CollisionShape2D.set_deferred("disabled", false)
	
	
