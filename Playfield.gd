extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export(Texture) var majhongTexture

enum dir{left,right,up,down}

const PIECE_WIDTH   = 16
const PIECE_HEIGHT  = 24
const PIECE_HFRAMES =  9
export(Vector2) var playfieldSize
var blockField
var playerBlockPos = Vector2(0,0)
var playerPieceDir = dir.right
var centerPieceTile = 0
var sidePieceTile = 0
var tilesToUse = 8
var comboCount = 0
export var fallSpeed = 20

var tilesPool = PoolByteArray()


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	randomize()
	OS.set_window_title("Mahjocks")
	OS.window_position = OS.get_screen_size()/2-OS.window_size/2
#	OS.set_window_position(OS.get_screen_size()) 
	
	blockField=[]
	for x in range(0,playfieldSize.x):
		blockField.append([])
		blockField[x]=[]
		for y in range(0,playfieldSize.y):
			blockField[x].append([])
			blockField[x][y]=-1
	
	for i in range(0,tilesToUse):
		tilesPool.append(2)
	
	newPiece()
	#		blockField[x][y]=int(rand_range(-2,0)) #rand_range(0,8)'

func _input(event):
#	if event.is_action_pressed("play_left"):
	pass

func _process(delta):
#	print(Input.is_action_pressed("ui_right"))
	
	#if not fall():
	if Input.is_action_just_pressed("play_left"):
		move_left()
	if Input.is_action_just_pressed("ui_right"):
		move_right()
	elif Input.is_action_just_pressed("play_rotate_cw"):
		rotate_clockwise()
	elif Input.is_action_just_pressed("play_rotate_ccw"):
		rotate_counterClockwise()
	if Input.is_action_pressed("play_drop"):
		if $FallTimer.time_left > 0.05:
			var currWaitTime = $FallTimer.wait_time
			$FallTimer.wait_time = 0.05
			$FallTimer.start()
			$FallTimer.wait_time = currWaitTime
			#move_drop()
	update()
	pass

func addTilesInUse():
	if tilesToUse < 32:
		tilesToUse += 1
		tilesPool.append(2)
	pass

func fall():
	var somethingFell = false
	for x in range(0,playfieldSize.x):
		for y in range(playfieldSize.y-2,0,-1):
			if blockField[x][y] > -1 and blockField[x][y+1] == -1:
				blockField[x][y+1] = blockField[x][y]
				blockField[x][y] = -1
				somethingFell =true
				
#	if somethingFell:
#		matchPieces()
	return somethingFell

func matchPieces():
	var fieldCopy = []
	for x in range(0,playfieldSize.x):
		fieldCopy.append([])
		fieldCopy[x]=[]
		for y in range(0,playfieldSize.y):
			fieldCopy[x].append([])
			fieldCopy[x][y]=blockField[x][y]
	
	var matches = 0
	var scoreToAdd = 0
	for x in range(0,playfieldSize.x):
		for y in range(0,playfieldSize.y):
			if checkMatch(x,y):
				matches += 1
				fieldCopy[x][y] = -3
				scoreToAdd += matches
	if matches > 0:
		comboCount += 1
		$Scoreboard.addScore(scoreToAdd*comboCount)
		blockField = fieldCopy
		return true
	return false

func checkMatch(x,y):
	if (blockField[x][y] != -1 and
	   (isSpecificTile(blockField[x][y],x+1,y) or
	    isSpecificTile(blockField[x][y],x-1,y) or
	    isSpecificTile(blockField[x][y],x,y+1) or
	    isSpecificTile(blockField[x][y],x,y-1))):
		return true
	return false

func isSpecificTile(tile,x,y):
	return insideBoundary(x,y) and blockField[x][y] == tile
	pass

func move_left():
	if tileCollision(playerBlockPos.x-1,playerBlockPos.y):
		return false
	if playerPieceDir == dir.left and tileCollision(playerBlockPos.x-2,playerBlockPos.y):
		return false
	if playerPieceDir == dir.down and tileCollision(playerBlockPos.x-1,playerBlockPos.y+1):
		return false
	if playerPieceDir == dir.up and tileCollision(playerBlockPos.x-1,playerBlockPos.y-1):
		return false
	playerBlockPos.x -= 1
	return true

func move_right():
	if tileCollision(playerBlockPos.x+1,playerBlockPos.y):
		return false
	if playerPieceDir == dir.right and tileCollision(playerBlockPos.x+2,playerBlockPos.y):
		return false
	if playerPieceDir == dir.down and tileCollision(playerBlockPos.x+1,playerBlockPos.y+1):
		return false
	if playerPieceDir == dir.up and tileCollision(playerBlockPos.x+1,playerBlockPos.y-1):
		return false
	playerBlockPos.x += 1
	return true

func move_drop():
	var place = false
	if tileCollision(playerBlockPos.x,playerBlockPos.y+1):
		place = true
	if playerPieceDir == dir.right and tileCollision(playerBlockPos.x+1,playerBlockPos.y+1):
		place = true
	if playerPieceDir == dir.left and tileCollision(playerBlockPos.x-1,playerBlockPos.y+1):
		place = true
	if playerPieceDir == dir.down and tileCollision(playerBlockPos.x,playerBlockPos.y+2):
		place = true
	if place:
		placePiece()
		return false
	
	playerBlockPos.y += 1
	return true

func insideBoundary(x,y):
	if x >= playfieldSize.x:
		return false
	if x < 0:
		return false
	if y >= playfieldSize.y:
		return false
	if y < 0:
		return false
	return true

func tileCollision(x,y):
	if not insideBoundary(x,y):
		return true
	if blockField[x][y] != -1:
		return true
	return false

func placePiece():
	blockField[playerBlockPos.x][playerBlockPos.y] = centerPieceTile
	if playerPieceDir == dir.right:
		blockField[playerBlockPos.x+1][playerBlockPos.y] = sidePieceTile
	if playerPieceDir == dir.left:
		blockField[playerBlockPos.x-1][playerBlockPos.y] = sidePieceTile
	if playerPieceDir == dir.up:
		blockField[playerBlockPos.x][playerBlockPos.y-1] = sidePieceTile
	if playerPieceDir == dir.down:
		blockField[playerBlockPos.x][playerBlockPos.y+1] = sidePieceTile
#	matchPieces()
	newPiece()

func newPiece():
	if blockField[3][0] > -1 or blockField[4][0] > -1:
		failed()
	playerBlockPos.y = 0
	playerBlockPos.x = 3
	centerPieceTile = getRandomTile() + 9
	sidePieceTile   = getRandomTile() + 9
	playerPieceDir = dir.right

func getRandomTile():
	# Check if there is any tiles left
	var noTilesLeft = true
	for tile in tilesPool:
		if tile != 0:
			noTilesLeft = false
			break
	# if no tiles left fill with new ones
	if noTilesLeft:
		for i in tilesPool.size():
			tilesPool[i] = 2
	# search for not depleted tile
	while true:
		var tile = randi()%tilesToUse
		if tilesPool[tile] > 0:
			tilesPool[tile] -= 1
			return tile
	return -1

func rotate_clockwise():
	if playerPieceDir == dir.left:
		tryRotateTo(dir.up)
	elif playerPieceDir == dir.up:
		tryRotateTo(dir.right)
	elif playerPieceDir == dir.right:
		tryRotateTo(dir.down)
	elif playerPieceDir == dir.down:
		tryRotateTo(dir.left)
	pass

func rotate_counterClockwise():
	if playerPieceDir == dir.right:
		tryRotateTo(dir.up)
	elif playerPieceDir == dir.up:
		tryRotateTo(dir.left)
	elif playerPieceDir == dir.left:
		tryRotateTo(dir.down)
	elif playerPieceDir == dir.down:
		tryRotateTo(dir.right)
	pass

func tryRotateTo(direction):
	if direction == dir.up:
		if not tileCollision(playerBlockPos.x,playerBlockPos.y-1):
			playerPieceDir = dir.up
			return true
	elif direction == dir.left:
		if not tileCollision(playerBlockPos.x-1,playerBlockPos.y):
			playerPieceDir = dir.left
			return true
	elif direction == dir.down:
		if not tileCollision(playerBlockPos.x,playerBlockPos.y+1):
			playerPieceDir = dir.down
			return true
	elif direction == dir.right:
		if not tileCollision(playerBlockPos.x+1,playerBlockPos.y):
			playerPieceDir = dir.right
			return true
	return false

func _draw():
	for x in range(0,playfieldSize.x):
		for y in range(0,playfieldSize.y):
			drawTile(blockField[x][y],x,y)
			pass
	
	drawTile(centerPieceTile,playerBlockPos.x,playerBlockPos.y)
	
	if playerPieceDir == dir.right:
		drawTile(sidePieceTile,playerBlockPos.x+1,playerBlockPos.y)
	if playerPieceDir == dir.left:
		drawTile(sidePieceTile,playerBlockPos.x-1,playerBlockPos.y)
	if playerPieceDir == dir.up:
		drawTile(sidePieceTile,playerBlockPos.x,playerBlockPos.y-1)
	if playerPieceDir == dir.down:
		drawTile(sidePieceTile,playerBlockPos.x,playerBlockPos.y+1)
	pass

func drawTile(tile,x,y):
	if tile == -1:
		return
	elif tile < -1:
		tile += 10
	
	var xPos= x*PIECE_WIDTH #*scale.x
	var yPos= y*PIECE_HEIGHT#*scale.y
	var xScale=PIECE_WIDTH #*scale.x
	var yScale=PIECE_HEIGHT#*scale.y
	var posRect =Rect2(xPos,yPos,xScale,yScale)
	draw_texture_rect_region(majhongTexture,posRect,getTileRect(tile))
	pass

func getTileRect(tile):
	var x = PIECE_WIDTH*(tile%PIECE_HFRAMES)
	var y = PIECE_HEIGHT*floor(tile/PIECE_HFRAMES)
	return Rect2(x,y,PIECE_WIDTH,PIECE_HEIGHT)

func flipTiles():
	var somethingFlipped = false
	for x in range(0,playfieldSize.x):
		for y in range(0,playfieldSize.y):
			if blockField[x][y] < -1:
				blockField[x][y] += 1
				somethingFlipped = true
	
	return somethingFlipped

func failed():
	get_tree().reload_current_scene()

func _on_FallTimer_timeout():
	move_drop()
	pass # replace with function body

func _on_UpdateTimer_timeout():
	if not flipTiles():
		if not fall():
			if not matchPieces():
				comboCount = 0
	pass # replace with function body
