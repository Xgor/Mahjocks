extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var score = 0
var currentLevel = 1
var playfield

func _ready():
	
#	playfield = get_owner()
	updateLabels()
	pass

func addScore(value):
	score += value
	if score > (currentLevel*3+7) * currentLevel:
		levelUp()
	updateLabels()
	pass

func levelUp():
	currentLevel+=1
	if get_parent().tilesToUse < 32:
		get_parent().tilesToUse += 1
#	owner.
	var fallTimer =get_parent().get_node("FallTimer")
	if fallTimer.wait_time > 0.2:
		fallTimer.wait_time -= 0.025
	updateLabels()
	pass

func updateLabels():
	$Score/Number.text = str(score)
	$Level/Number.text = str(currentLevel)


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
