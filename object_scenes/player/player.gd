extends CharacterBody2D

@onready var sprite = $sprite
@onready var camera = $Camera2D

var animTicks :float = 0.0
var animMax :float = 0.12

var step :int = 0

var savedPositions :Array[Vector4] = []
var maxsavedpos :int = 20 * (BattleData.getNumberOfPlayers() - 1)

@export var cameraLimitX :Vector2 = Vector2(-10000.0,10000.0)
@export var cameraLimitY :Vector2 = Vector2(-10000.0,10000.0)



func _ready() -> void:
	
	Global.player = self
	Global.camera = camera
	
	if Global.playerLoadPosition != null:
		position = Global.playerLoadPosition
		Global.playerLoadPosition = null
	
	camera.limit_left = cameraLimitX.x
	camera.limit_right = cameraLimitX.y
	camera.limit_top = cameraLimitY.x
	camera.limit_bottom = cameraLimitY.y
	
	for i in range(maxsavedpos):
		savedPositions.append( Vector4(position.x,position.y,0,1.0) )
	
	updatePlayers()
	
	
	

func updatePlayers():
	sprite.texture = BattleData.getPlayerWorldSprite(0)
	
	for i in range(BattleData.getNumberOfPlayers()-1):
		var ins = Sprite2D.new()
		var tex :Texture2D = BattleData.getPlayerWorldSprite(i+1)
		ins.texture = tex
		ins.hframes = 3
		ins.vframes = 3
		ins.offset.y = -18
		$friends.add_child(ins)
	
func _process(delta: float) -> void:
	var dir :Vector2 = Vector2.ZERO
	dir.x = int( Input.is_action_pressed("move_right") ) - int( Input.is_action_pressed("move_left") )
	dir.y = int( Input.is_action_pressed("move_down") ) - int( Input.is_action_pressed("move_up") )
	
	if Global.inCutscene:
		dir = Vector2.ZERO
	
	velocity = dir.normalized().rotated(camera.rotation) * 110.0
	if Input.is_action_pressed("cancel"):
		velocity = dir.normalized().rotated(camera.rotation) * 160.0
		animMax = 0.08
	else:
		animMax = 0.16
	
	if $stairSlower.is_colliding():
		velocity.y *= 0.75
	
	var b :Vector2= camera.global_position
	move_and_slide()
	
	animation(dir,delta)
	
	var c = camera.rotation
	if Input.is_action_pressed("testRotateLeft"):
		$Camera2D.rotate(-2.0*delta)
	if Input.is_action_pressed("testRotateRight"):
		$Camera2D.rotate(2.0*delta)
	if c != $Camera2D.rotation:
		Global.emit_signal("updateCamRotation",$Camera2D.global_position,$Camera2D.rotation)
	elif b != camera.global_position:
		Global.emit_signal("updateCamPosition",$Camera2D.global_position,$Camera2D.rotation)
	
	print($sprite.z_index)
	
func animation(dir:Vector2,delta):
	
	animTicks += delta
	
	if dir.y != 0:
		sprite.frame_coords.x = 2 - int(dir.y + 1.0)
		sprite.flip_h = false
	elif dir.x != 0:
		sprite.frame_coords.x = 1
		sprite.flip_h = dir.x == -1
	
	if dir != Vector2.ZERO:
		if animTicks > animMax:
			step += 1
			sprite.frame_coords.y = [1,0,2,0][step%4]
			animTicks -= animMax
		
		savedPositions.append( Vector4(position.x,position.y,sprite.frame_coords.x,float(sprite.flip_h)) )
		if savedPositions.size() > maxsavedpos:
			savedPositions.remove_at(0)
		
		var i :int = 0
		var players :int= $friends.get_child_count() - 1
		for friend in $friends.get_children():
			var target :int = (players-i) * 20
			friend.position = Vector2( savedPositions[target].x,savedPositions[target].y ) - position
			friend.frame_coords.x = int(savedPositions[target].z)
			friend.flip_h = savedPositions[target].w > 0.5
	
			i += 1
		$interact.target_position = dir.normalized() * 16.0
		
	else:
		sprite.frame_coords.y = 0
		animTicks = animMax
		step = -1
	
	for friend in $friends.get_children():
		friend.frame_coords.y = sprite.frame_coords.y

func _input(event: InputEvent) -> void:
	
	if Global.inCutscene:
		return
	
	if Input.is_action_just_pressed("interact"):
		if $interact.is_colliding():
			var area = $interact.get_collider()
			area.runInteractionTrigger()
