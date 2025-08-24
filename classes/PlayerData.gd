extends Resource
class_name PlayerData

@export var name :String = "square"
@export var color :Color = Color.WHITE
@export var baseHealthMax :int = 50
var health :int = 50
@export var baseAttack :int = 0

@export var moves :Array[String] = []
@export var battleBorder :Texture2D
@export var worldSprite :Texture2D
