extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var playfield
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	playfield = get_node("../Playfield")
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if Input.is_action_just_pressed("pause"):
		pause()
	pass
func pause():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused 
	playfield.visible = !visible