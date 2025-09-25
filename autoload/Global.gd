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
	
	var ins = load("res://fighting/battleScene/battle_scene.tscn").instantiate()
	canvasLayer.add_child( ins )

func hasTag(tag:String) -> bool:
	return arbitraryTagData.has(tag)

func addTag(tag:String) -> void:
	arbitraryTagData[tag] = true

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
	
