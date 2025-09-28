extends Node2D
class_name BattleScene

enum states {
	selectAction,
	selectMelee,
	selectSpell,
	selectItem,
	selectDirection,
	performMoves,
	playerWin,
	playerLose,
}
var state :int = -1

# nodes 
@export var gameWorldRoot :SubViewport
@export var battleCamera :Camera2D
@export var uiRoot :Node2D
@export var actorContainer:Node2D
@export var tilePreviewContainer:Node2D
@export var moveAnimationContainer:Node2D

# scenes 
@onready var hitboxPreview = preload("res://fighting/battleScene/tilePreview/tile_preview.tscn")

# actors
var actors :Array[BattleActor] = []
var playerActors :Array[BattleActor] = [] # contains only the actors of the players

var takenSpots :Array[Vector2i] = []

var actorResourcesToPull :Array[String] = [
	"res://fighting/actors/enemies/test/goku.tscn",
	"res://fighting/actors/enemies/test/cool_tien.tscn",
	"res://fighting/actors/enemies/test/vegeta.tscn",
]

# level                      tile     array of hazards like fire, oil, and such
var worldThings :Dictionary[Vector2i,Array] = {}


func _ready() -> void:
	#RenderingServer.viewport_set_update_mode(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_ONCE)
	for i in range(PartyInfo.getPartyCount()):
		var actorFile :String = PartyInfo.getPartyResourceByIndex(i).battleActorFile
		actorResourcesToPull.append(actorFile)
		pass
	
	
	for actor in actorResourcesToPull:
		var ins :BattleActor = load(actor).instantiate()
		var tile = Vector2i.ZERO
		while(true):
			tile = Vector2i(randi() % 10,randi() % 10)
			if !takenSpots.has(tile):
				break
			
		takenSpots.append(tile)
		ins.mapPos = tile
		ins.battleScene = self
		
		actors.append(ins)
		actorContainer.add_child(ins)
		if ins.alliance == 1: # is friend
			playerActors.append(ins)
	
	for x in range(10):
		for y in range(10):
			worldThings[Vector2i(x,y)] = []
	
	setState(states.selectAction)
	
func _process(delta: float) -> void:
	stateLogic()
	updateActorsRotation()
	
	print("state: "+states.keys()[state])

##################################################
################ STATE STUFF #####################

var playerSelecting :int = 0

var mainMenuSelect :int = 0
var spellMenuSelect :int = 0

var hitboxAmount :int = 1

func stateLogic():
	match state:
		states.selectAction:
			turnWorld()
			if Input.is_action_just_pressed("interact"): # have more options later
				setState(states.selectSpell)
			$UI/selectMain/arrow.position.y = 200 + (mainMenuSelect * 27)
			if Input.is_action_just_pressed("move_up"):
				mainMenuSelect -= 1
			if Input.is_action_just_pressed("move_down"):
				mainMenuSelect += 1
			mainMenuSelect = (mainMenuSelect + 4) % 4
		states.selectSpell:
			selectHitboxIndex()
			
			var save :int= spellMenuSelect
			if Input.is_action_just_pressed("move_up"):
				spellMenuSelect -= 1
			if Input.is_action_just_pressed("move_down"):
				spellMenuSelect += 1
			var availableMoves = playerActors[playerSelecting].availableMoves
			var numOfMoves :int = availableMoves.size()
			spellMenuSelect = (spellMenuSelect + numOfMoves) % numOfMoves
			
			if save != spellMenuSelect: # input pressed
				
				hitboxAmount = MoveHandler.getHitboxCount(availableMoves[spellMenuSelect])
				displayHitbox(availableMoves[spellMenuSelect],playerActors[playerSelecting].mapPos,currentIndex % hitboxAmount)
				
				
			$UI/selectSpell/arrow.position.y = 200 + (spellMenuSelect * 27)
			
			if Input.is_action_just_pressed("interact"):
				playerActors[playerSelecting].moveToPerform = availableMoves[spellMenuSelect]
				playerActors[playerSelecting].moveIndex = currentIndex % hitboxAmount
				selectNextPlayer()
		
		states.performMoves:
			pass

func enterState(newState,oldState) -> void:
	match state:
		states.selectAction:
			clearHitbox()
			$UI/selectMain.show()
		states.selectSpell:
			spellMenuSelect = 0
			currentIndex = camRotationState
			$UI/selectSpell.show()
			var moves :Array[String] = playerActors[playerSelecting].availableMoves
			$UI/selectSpell/Label.text = ""
			for move in moves:
				$UI/selectSpell/Label.text += "<" + move + ">\n"
			hitboxAmount = MoveHandler.getHitboxCount(moves[0])
			displayHitbox(moves[0],playerActors[playerSelecting].mapPos,currentIndex % hitboxAmount)
			print(moves[0])
		states.performMoves:
			
			playerSelecting = 0
			
			clearHitbox()
			
			var actorOrder :Array[BattleActor] = calculateActorOrder()
			for actor in actorOrder:
				var move :Move = MoveHandler.getMove(actor.moveToPerform)
				var moveIndex :int= actor.moveIndex
				var moveScene :PackedScene = move.moveAnimation
				
				if move.hitboxMode == 0: # rotational
					var gayPeople8am :int = moveIndex - 1
					if gayPeople8am == -1:
						gayPeople8am = 3
					if angle == 0 and gayPeople8am == 3:
						angle = -1
					else:
						angle = gayPeople8am
					tweenRotateCamera((angle * (PI/2)) + (PI/4))
				
				await get_tree().create_timer(0.5).timeout # wait for cam turn
				
				var hitbox :Array[Vector2i]= displayHitbox(actor.moveToPerform,actor.mapPos,moveIndex)
				
				var animIns :MoveAnimation= moveScene.instantiate()
				animIns.moveResource = move
				animIns.position = actor.position
				animIns.rotation = battleCamera.rotation
				animIns.scale.y = 2.0
				moveAnimationContainer.add_child(animIns)
				
				var collidingActors :Array[BattleActor] = getCollidingActors(hitbox,actor.mapPos)
				animIns.performMove(collidingActors,actor,hitbox)
				
				await animIns.finishedWithMove
				clearHitbox()
				await get_tree().create_timer(1.0).timeout
			
			await get_tree().process_frame
			setState(states.selectAction)

func exitState(oldState,newState) -> void:
	match oldState:
		states.selectAction:
			$UI/selectMain.hide()
		states.selectSpell:
			$UI/selectSpell.hide()
		states.performMoves:
			clearHitbox()
	
func setState(newState:int) -> void:
	var oldState :int= state
	state = newState
	if oldState != -1:
		exitState(oldState,newState)
	enterState(newState,oldState)
	
	print("new state: " + states.keys()[newState])

func selectNextPlayer() -> void:
	
	if playerSelecting == PartyInfo.getPartyCount() - 1: 
		setState(states.performMoves)
		return
	playerSelecting += 1
	# todo: skip dead players
	
	setState(states.selectAction)
	

##################################################
############ CAMERA ##############################

var prevCamAngle :float = 0.0
var tweening :bool = false
var angle :int = 0
var camRotationState: int = 0

var tweenHold :Tween

func turnWorld() -> void:
	var cur = angle
	if Input.is_action_just_pressed("move_left"):
		angle -= 1
	elif Input.is_action_just_pressed("move_right"):
		angle += 1
	
	camRotationState = (cur + 400000) % 4
	
	if cur != angle:
		tweenRotateCamera( (angle * (PI/2)) + (PI/4) )

func tweenRotateCamera(target:float) -> void:
	if tweening:
		tweenHold.stop()
	
	
	tweenHold = get_tree().create_tween()
	tweenHold.tween_property(battleCamera,"rotation",target,0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tweening = true
	await tweenHold.finished
	
	battleCamera.rotation = fposmod(battleCamera.rotation,PI * 2)
	angle = (angle + 400000) % 4
	
	tweening = false

func updateActorsRotation() -> void:
	if prevCamAngle == battleCamera.rotation:
		return
	
	for actor in actors:
		actor.setRotation(battleCamera.rotation,getZ(actor.global_position))
	
	for wall in $viewportContainer/GameWorld/walls.get_children(): # to do: make real background handler
		wall.setPolygons(Vector2i.ZERO,battleCamera.rotation)
	
	prevCamAngle = battleCamera.rotation

func getZ(objGlobal:Vector2) -> int:
	return (objGlobal - battleCamera.global_position).rotated(-battleCamera.rotation).y 

##########################################################
############### GAME PLAY ################################

func displayHitbox(move:String,origin:Vector2i,index:int = 0) -> Array[Vector2i]: # returns hitbox
	clearHitbox()
	var hitbox :Array[Vector2i] = MoveHandler.getHitbox(move,index)
	var collidingVectors :Array[Vector2i] = getCollidingVectors(hitbox,origin)
	for tile in hitbox:
		
		var trueTile :Vector2i = origin + tile
		if trueTile.x != clamp(trueTile.x,0,9):
			continue
		if trueTile.y != clamp(trueTile.y,0,9):
			continue
		
		var ins = hitboxPreview.instantiate()
		ins.position = trueTile * 20
		ins.camera = battleCamera
		if collidingVectors.has(trueTile):
			ins.modulate = Color.RED
		if state == states.performMoves:
			ins.modulate.a = 0.5
		
		tilePreviewContainer.add_child(ins)
	
	return hitbox

func clearHitbox() -> void:
	for i in tilePreviewContainer.get_children():
		i.queue_free()

var currentIndex :int = 0
func selectHitboxIndex():
	var s :int = currentIndex
	if Input.is_action_just_pressed("move_left"):
		currentIndex -= 1
	elif Input.is_action_just_pressed("move_right"):
		currentIndex += 1
	
	if s != currentIndex:
		var size:int= MoveHandler.getHitboxCount("testMove")
		currentIndex = (currentIndex + size) % size
		
		var moves :Array[String] = playerActors[playerSelecting].availableMoves
		
		displayHitbox(moves[spellMenuSelect],playerActors[playerSelecting].mapPos,currentIndex % hitboxAmount)

## Move Performing
func calculateActorOrder() -> Array[BattleActor]:
	var order :Array[BattleActor] = []
	
	var temporaryDictionary :Dictionary[int,Array] = {}
	
	for actor in actors:
		if actor.moveToPerform == "":
			continue # skip enemies with no move
		var moveSpeed :int = MoveHandler.getMoveSpeed(actor.moveToPerform)
		if temporaryDictionary.has(moveSpeed): # add actor to existing speed array
			temporaryDictionary[moveSpeed].append(actor) # to shuffle actors with same speed
		else:
			temporaryDictionary[moveSpeed] = []
			temporaryDictionary[moveSpeed].append(actor)
	
	temporaryDictionary.sort() # sorts dictionary in order of speeds from lowest to highest
	
	for key in temporaryDictionary.keys():
		temporaryDictionary[key].shuffle() # randomize order of actors with same speed
		order.append_array(temporaryDictionary[key]) # add actors to big list
	
	order.reverse() # reverse order so faster actors are first
	
	return order

func getCollidingActors(hitbox:Array[Vector2i],origin:Vector2i) -> Array[BattleActor]:
	var collidingActors :Array[BattleActor] = []
	
	for actor in actors:
		var pos :Vector2i= actor.mapPos
		pos = pos - origin
		if hitbox.has(pos):
			collidingActors.append(actor)
	return collidingActors

func getCollidingVectors(hitbox:Array[Vector2i],origin:Vector2i) -> Array[Vector2i]:
	var collidingVectors :Array[Vector2i] = []
	
	for actor in actors:
		var pos :Vector2i = actor.mapPos
		pos = pos - origin
		if hitbox.has(pos):
			collidingVectors.append(actor.mapPos)
	return collidingVectors
