extends KinematicBody2D

class_name Enemy

signal target_reached

export var move_speed = 300
# degrees
export var rotation_speed = 45.0
export var fast_rotation_speed = 90.0
var rotate_rad

var projectile = preload("projectile.tscn")
var laser = preload("laser.tscn")

var player = null
var move_towards_player = false
var move_towards_target = false
var target_location = Vector2.ZERO
var path_target: Node2D

var fast_rotation = true
var tracking_player = true
var locked_on = true
var target_direction = Vector2.ZERO

var phase: int = 2

var attack_weight = [10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0]
var weight_sum = 0
var previous_attack = attack_weight.size() - 1


func _ready():
	add_to_group("enemies")
	#$ShootTimer.start()
	#$LaserTimer.start()
	$AttackTimer.start()

func _physics_process(delta):
	if player == null:
		return
	
	#var pos = player.global_position - global_position
	#print("Player position %f, %f Enemy position %f, %f  Vector: %f, %f" % 
	#		[player.global_position.x, player.global_position.y, 
	#		global_position.x, global_position.y,
	#		pos.x, pos.y])
	# im stupid
	
	if move_towards_player:
		# Moves towards enemy
		var direction = player.global_position - global_position
		var radians = atan2(direction.y, direction.x)
		move_and_slide(direction.normalized() * move_speed)
	elif move_towards_target:
		var direction = target_location - global_position
		var radians = atan2(direction.y, direction.x)
		move_and_slide(direction.normalized() * move_speed)
		#print(target_location)
		#print(global_position)
		if abs(target_location.x - global_position.x) < 5 and abs(target_location.y - global_position.y) < 5:
			move_towards_target = false
			emit_signal("target_reached")
		
	var current_direction = Vector2(cos(global_rotation), sin(global_rotation))
	if tracking_player:
		var player_direction = (player.global_position - global_position).normalized()
		target_direction = player_direction
		
	if fast_rotation and locked_on or not tracking_player and locked_on:
		look_at(global_position + target_direction)
	else:
		if fast_rotation:
			rotate_rad = deg2rad(fast_rotation_speed)
		else:
			rotate_rad = deg2rad(rotation_speed)
		
		
		#print(player_direction.dot(enemy_direction))
		if fast_rotation and tracking_player and target_direction.dot(current_direction) > 0.99:
			locked_on = true
		
		if target_direction.x * current_direction.y < target_direction.y * current_direction.x:
			rotate(rotate_rad * delta)
		else:
			rotate(-rotate_rad * delta)
	

func set_player(player):
	self.player = player



func _on_ShootTimer_timeout():
	#print("shoot!")
	#print(global_position)
	
	var proj1 = projectile.instance()
	proj1._init(global_position, global_rotation)
	var proj2 = projectile.instance()
	proj2._init(global_position, global_rotation + (45.0 * PI /180.0))
	var proj3 = projectile.instance()
	proj3._init(global_position, global_rotation - (45.0 * PI / 180.0))
	
	# Maybe change this later when the boss is no longer sitting right on the world
	get_tree().get_root().get_node("World").add_child(proj1)
	get_parent().add_child(proj2)
	get_parent().add_child(proj3)


func _on_LaserTimer_timeout():
	$ShootTimer.stop()
	var las = laser.instance()
	las._init(Vector2(0,0), deg2rad(270.0))
	add_child(las)
	yield(las, "finished_charging")
	fast_rotation = false
	locked_on = false
	yield(las, "laser_fired")
	fast_rotation = true
	$ShootTimer.start()

# attack 0
func tracking_laser_attack(chain = false):
	rotation_speed = 30.0
	var las = laser.instance()
	las._init(Vector2(0,0), deg2rad(270.0))
	add_child(las)
	yield(las, "finished_charging")
	fast_rotation = false
	locked_on = false
	if not chain and phase == 2:
		#yield(get_tree().create_timer(), "timeout")
		attack(1, true)
	yield(las, "laser_fired")
	fast_rotation = true
	if not chain:
		$AttackTimer.start()
	
# attack 1
func fan_attack(amount = 5, delay = 0.5, chain = false):
	if not chain and phase == 2:
		amount *= 4
		delay /= 4
	for i in range(amount):
		var proj1 = projectile.instance()
		proj1._init(global_position, global_rotation)
		var proj2 = projectile.instance()
		proj2._init(global_position, global_rotation + (45.0 * PI /180.0))
		var proj3 = projectile.instance()
		proj3._init(global_position, global_rotation - (45.0 * PI / 180.0))
		
		# Maybe change this later when the boss is no longer sitting right on the world
		get_tree().get_root().get_node("World").add_child(proj1)
		get_parent().add_child(proj2)
		get_parent().add_child(proj3)
		yield(get_tree().create_timer(delay), "timeout")
	if not chain:
		$AttackTimer.start()
	
# attack 2
func sweep_attack(start_position: Vector2, end_position: Vector2, angle: Vector2, chain = false):
	var orig = global_position
	tracking_player = false
	locked_on = false
	target_direction = angle
	target_location = end_position
	move_towards_target = true
	teleport_to(start_position)
	set_global_rotation(atan2(angle.y,angle.x))
	var las = laser.instance()
	las._init(Vector2(0,0), deg2rad(270.0), 1, 1.0, .5, 2.2)
	add_child(las)
	#yield(get_tree().create_timer(2), "timeout")
	if not chain and phase == 2:
		attack(1, true)
		yield(get_tree().create_timer(1.5), "timeout")
		attack(3, true)
	yield(self, "target_reached")
	teleport_to(orig)
	tracking_player = true
	if not chain:
		$AttackTimer.start()
	
# attack 3
func criss_cross_lasers_horizontal(chain = false):
	var las
	var offset = randi() % 160 
	for i in range(720/160 + 1):
		las = laser.instance()
		las._init(Vector2(64, offset + 160 * i), deg2rad(270), 1, 0.5, 0.5, 2.0)
		get_parent().add_child(las)
	if not chain and phase == 2:
		yield(get_tree().create_timer(1.5), "timeout")
		attack(4, true)
	yield(las, "laser_fired")
	if not chain:
		$AttackTimer.start()

# attack 4
func criss_cross_lasers_vertical(chain = false):
	var las
	var offset = randi() % 160 
	for i in range(1280/160 + 1):
		las = laser.instance()
		las._init(Vector2(offset + 160 * i, 16), deg2rad(0), 1, 0.5, 0.5, 2.0)
		get_parent().add_child(las)
	if not chain and phase == 2:
		yield(get_tree().create_timer(1), "timeout")
		attack(3, true)
	yield(las, "laser_fired")
	if not chain:
		$AttackTimer.start()
	
# attack 5
func x_laser_attack(offset = 0.0, chain = false):
	rotation_speed = 60.0
	var orig = global_position
	tracking_player = false
	fast_rotation = false
	locked_on = false
	target_direction = Vector2(0,1)
	teleport_to(Vector2(1280/2, 720/2))
	set_global_rotation(atan2(1,0))
	var las
	for i in range(4):
		las = laser.instance()
		las._init(Vector2(0, 0), deg2rad(90 * i + offset), 1, 0.5, 0.5, 4.5)
		add_child(las)
		#WAIT FOR LASER TO STOP FIRING
		
	yield(get_tree().create_timer(2.0), "timeout")
	
	if not chain and phase == 2:
		yield(get_tree().create_timer(0.5), "timeout")
		for i in range(4):
			las = laser.instance()
			las._init(Vector2(0, 0), deg2rad(90 * i + offset + 45), 1, 0.5, 0.5, 2.0)
			add_child(las)
			#WAIT FOR LASER TO STOP FIRING
		
	target_direction = Vector2(0,-1)
	
	yield(las, "laser_fired")
	yield(get_tree().create_timer(0.5), "timeout")
	teleport_to(orig)
	tracking_player = true
	fast_rotation = true
	locked_on = true
	if not chain:
		$AttackTimer.start()
	

func teleport_to(position: Vector2):
	# Do some kind of teleport animation to be cool
	set_global_position(position)
	
func attack(attack_num, chain = false):
	match (attack_num):
		0:
			tracking_laser_attack(chain)
		1:
			fan_attack(5, 0.5, chain)
		2:
			sweep_attack(Vector2(64, 64), Vector2(1280-64, 64), Vector2(0, 1), chain)
		3:
			criss_cross_lasers_horizontal(chain)
		4:
			criss_cross_lasers_vertical(chain)
		5:
			x_laser_attack(0.0, chain)
		6:
			x_laser_attack(45, chain)
		7:
			sweep_attack(Vector2(1280-64, 64), Vector2(64, 64), Vector2(0, 1), chain)
		_:
			print("uh oh")

func _on_AttackTimer_timeout():
	#print("attacking!")
	$AttackTimer.stop()
	for i in range(attack_weight.size()):
		if (previous_attack != i):	
			attack_weight[i] += attack_weight[previous_attack]/6
			weight_sum += attack_weight[i]
	
	attack_weight[previous_attack] = 0
	var attack = randi() % int(ceil(weight_sum))
	print(weight_sum)
	weight_sum = 0
	print(attack)
	var temp = 0
	previous_attack = attack_weight.size() - 1
	for i in range(attack_weight.size() - 1):
		if temp <= attack and attack < temp + attack_weight[i]:
			previous_attack = i
			break
		temp += attack_weight[i]
		
	print(attack_weight)
	attack(previous_attack)
	
