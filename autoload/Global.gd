extends Node

## This dic is full of random strings that will get saved.
## determines if certain events have been logged, so dialogue can act accordingly
var arbitraryTagData :Dictionary = {}

# player stuff
var inCutscene :bool = false
var player :CharacterBody2D
var playerLoadPosition :Vector2i= Vector2i(-999,-999)
var playerLoadFacing = 0

# camera stuff
var camera :GameCamera
var canvasLayer :CanvasLayer = CanvasLayer.new()
signal updateCamRotation(pos:Vector2i,angle:float)
signal updateCamPosition(pos:Vector2i,angle:float)

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	add_child(canvasLayer)

func hasTag(tag:String) -> bool:
	return arbitraryTagData.has(tag)

func addTag(tag:String) -> void:
	arbitraryTagData[tag] = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("testQuicksave"):
		saveGame()
	if Input.is_action_just_pressed("testQuickload"):
		loadGame()

func switchLevel(levelFileString:String,position:Vector2,facing:int=0) -> void:
	
	inCutscene = true
	
	playerLoadPosition = position
	playerLoadFacing = facing
	
	var rect = ColorRect.new()
	rect.color = Color.BLACK
	rect.color.a = 0.0
	rect.size = Vector2(400,300)
	rect.z_index = 4096
	canvasLayer.add_child(rect)
	var tween = get_tree().create_tween()
	tween.tween_property(rect,"color:a",1.0,0.2)
	await tween.finished
	
	inCutscene = false
	get_tree().change_scene_to_file(levelFileString)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(rect,"color:a",0.0,0.2)
	await tween2.finished
	rect.queue_free()
	
	


func saveGame():
	
	var data :Dictionary= {}
	
	var loadedScene = get_tree().current_scene
	data["levelFile"] = loadedScene.scene_file_path
	data["party"] = var_to_bytes_with_objects(BattleData.players)
	data["inventory"] = Item.inventory
	data["teamLevel"] = BattleData.teamLevel
	data["teamXP"] = BattleData.teamExperience
	data["arbitraryData"] = arbitraryTagData
	
	if is_instance_valid(player):
		data["playerPos"] = var_to_str(player.position)
	
	print(data)
	#print(var_to_bytes_with_objects(BattleData.players))
	Saving.write_save("save1",data)

func loadGame():
	var data = Saving.read_save("save1")
	print(data)
	#print(bytes_to_var_with_objects(str_to_var(data["party"])))
	BattleData.players = bytes_to_var_with_objects( str_to_var(data["party"])  )
	var a :Array = data["inventory"]
	var newArrayFUCK :Array[String] = []
	for item in a:
		newArrayFUCK.append(item)
	Item.inventory = newArrayFUCK
	BattleData.teamLevel = (data["teamLevel"])
	BattleData.teamExperience = data["teamXP"]
	if data.has("playerPos"):
		playerLoadPosition = str_to_var(data["playerPos"])
		print(str_to_var(data["playerPos"]))
	else:
		playerLoadPosition = Vector2i(-999,-999)
	
	arbitraryTagData = data["arbitraryData"]
	
	BattleData.resetPlayerHealths()
	get_tree().change_scene_to_file(data["levelFile"])
