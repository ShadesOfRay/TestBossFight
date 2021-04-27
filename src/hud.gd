extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hearts = []
var current_hp = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_node("Player").connect("hit", self, "_change_hearts")
	for i in range(1, 11):
		hearts.append(get_node("Heart%d" % i))


func _change_hearts(old_health, new_health):
	var step
	if old_health > new_health:
		step = -1
	else:
		step = 1
	current_hp = new_health
	for i in range(new_health, old_health, 1):
		hearts[i].set_frame(1)
