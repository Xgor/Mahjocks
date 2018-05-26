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
export var fallSpeed = 20

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	OS.set_window_title("Mah")
	OS.window_position = OS.get_screen_size()/2-OS.window_size/2
#	OS.set_window_position(OS.get_screen_size()) 
	
	blockField=[]
	for x in range(0,playfieldSize.x):
		blockField.append([])
		blockField[x]=[]
		for y in range(0,playfieldSize.y):
			blockField[x].append([])
			blockField[x][y]=-1
	#		blockField[x][y]=int(rand_range(-2,0)) #rand_range(0,8)'
	

func _input(event):
#	if event.is_action_pressed("play_left"):
	pass


func _process(delta):
#	print(Input.is_action_pressed("ui_right"))
	if Input.is_action_just_pressed("play_left"):
		move_left()
	if Input.is_action_just_pressed("ui_right"):
		move_right()
	elif Input.is_action_just_pressed("play_rotate_cw"):
		rotate_clockwise()
	elif Input.is_action_just_pressed("play_rotate_ccw"):
		rotate_counterClockwise()
	if Input.is_action_pressed("play_drop"):
		move_drop()
	update()
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
	pass

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
	pass

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

func tileCollision(x,y):
	if x >= playfieldSize.x:
		return true
	if x < 0:
		return true
	if y >= playfieldSize.y:
		return true
	if y < 0:
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
	playerBlockPos.y = 0
	playerBlockPos.x = 4
	playerPieceDir = dir.right

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
	if tile < 0:
		return
	
	var xPos= (x*PIECE_WIDTH)*scale.x
	var yPos= (y*PIECE_HEIGHT)*scale.y
	var xScale=PIECE_WIDTH*scale.x
	var yScale=PIECE_HEIGHT*scale.y
	var posRect =Rect2(xPos,yPos,xScale,yScale)
	draw_texture_rect_region(majhongTexture,posRect,getTileRect(tile))
	pass

func getTileRect(tile):
	var x = PIECE_WIDTH*(tile%PIECE_HFRAMES)
	var y = PIECE_HEIGHT*floor(tile/PIECE_HFRAMES)
	return Rect2(x,y,PIECE_WIDTH,PIECE_HEIGHT)