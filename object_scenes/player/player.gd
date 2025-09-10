extends CharacterBody2D
class_name PlayerWorld

var mcSprite :Sprite2D
var dir :Vector2i = Vector2i.ZERO
var dirLastFrame :Vector2i = Vector2i.ZERO
var walkAnimationTick :float = 0.0
var walkState :int = 0
@export var walkAnimInterval :float = 0.1

# friends
@export var friendContainer :Node2D
var friendPosArray :Array[Vector4i]
var positionLastFrame :Vector2i
const FRIENDDISTANCE :int = 20

func _ready() -> void:
	positionLastFrame = global_position
	friendPosArray.resize( BattleData.players.size() * FRIENDDISTANCE )
	friendPosArray.fill( Vector4i(global_position.x,global_position.y,0,0))
	
	for i in range(BattleData.players.size()):
		var newSprite = Sprite2D.new()
		newSprite.texture = BattleData.players[i].worldSprite
		newSprite.hframes = 5
		newSprite.vframes = 3
		newSprite.offset.y = -7
		
		friendContainer.add_child(newSprite)
		
		if i == 0:
			mcSprite = newSprite

func _process(delta: float) -> void:
	move(delta)
	animateCharacter(delta)
	
	appendFriendArray()
	moveFriends()

func move(delta: float) -> void:
	dirLastFrame = dir
	positionLastFrame = global_position
	
	dir = Vector2i.ZERO
	dir.x = int(Input.get_axis("move_left","move_right"))
	dir.y = int(Input.get_axis("move_up","move_down"))
	
	velocity = Vector2(dir).normalized() * 120 
	move_and_slide()

func animateCharacter(delta:float) -> void:
	if dir.x != 0:
		mcSprite.flip_h = dir.x == -1
	# now that flip is determined, there are 5 possible input states
	
	if dir != Vector2i.ZERO: # dont run any of this when standing still
		var inputStates :Array = [ Vector2i(0,1), Vector2i(1,0),
			Vector2i(0,-1), Vector2i(1,1),Vector2i(1,-1) ]
		
		var scanDir :Vector2i = dir
		if mcSprite.flip_h:
			scanDir.x *= -1
		
		mcSprite.frame_coords.x = inputStates.find(scanDir)
	
	if dir != Vector2i.ZERO and positionLastFrame != Vector2i(global_position):
		
		walkAnimationTick += delta
		if walkAnimationTick > walkAnimInterval:
			walkState += 1
			if walkState == 4:
				walkState = 0
			walkAnimationTick -= walkAnimInterval
		
		walkCycle(mcSprite,delta)
		
		for friend in friendContainer.get_children():
			walkCycle(friend,delta)
	elif positionLastFrame == Vector2i(global_position):
		restWalkCycle(mcSprite,delta)
		
		for friend in friendContainer.get_children():
			restWalkCycle(friend,delta)
			

func walkCycle(sprite:Sprite2D,delta:float) -> void:
	# this function will be able to run on other party members as well
	sprite.frame_coords.y = (walkState % 2) * (1 + int(walkState == 3))

func restWalkCycle(sprite:Sprite2D,delta:float) -> void:
	sprite.frame_coords.y = 0
	walkAnimationTick = walkAnimInterval
	walkState = 0

func appendFriendArray():
	if positionLastFrame == Vector2i(global_position):
		return # we haven't moved, do nothing
	
	friendPosArray.insert(0, Vector4i(global_position.x,global_position.y,mcSprite.frame_coords.x,float(mcSprite.flip_h)))
	friendPosArray.resize( BattleData.players.size() * FRIENDDISTANCE )

func moveFriends():
	var i :int= 0
	for friend in friendContainer.get_children():
		
		var vec :Vector4i= friendPosArray[i * FRIENDDISTANCE]
		
		friend.global_position = Vector2(vec.x,vec.y)
		friend.frame_coords.x = vec.z
		friend.flip_h = vec.w == 1
		i += 1
