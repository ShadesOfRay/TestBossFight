extends Area2D

class_name Projectile

var direction = Vector2.ZERO
var speed

func _init(position: Vector2 = Vector2.ZERO, direction: float = 0.0, speed: int = 500):
	add_to_group("projectiles")
	self.direction.x = cos(direction)
	self.direction.y = sin(direction)
	self.speed = speed
	set_position(position)
	rotate(direction)
	#print("i exist now!")
	#print(global_position)
	#print(direction)


func _ready():
	pass


func _physics_process(delta):
	global_position += direction * speed * delta


func _on_Projectile_body_entered(body):
	var player := body as Player
	if not player:
		queue_free()
		return
	
	print("HIT!")
	player.damage(1)
	queue_free()

	
