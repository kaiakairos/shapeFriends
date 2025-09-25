extends Resource
class_name BattleActor

@export var name:String = "actor"

@export_group("Stats")
@export var maxHealth :int = 30 # hit points
var health :int = 30

@export var defense :int = 0 # flat damage resist

@export_group("Moves")
@export var availableMoves :Array= [] # fill later when we have move systemm

@export_group("Movement")
@export_enum("ANYTHING","KNIGHT","ROOK","BISHOP","QUEEN") var movementType :int = 0
@export var movementRange :int = 5

@export_group("Animation")

@export_subgroup("idle")
@export var idleAnim :Texture2D
@export var idleAnimFPS :int = 0
@export var idleAnimFrameCount :int = 0

@export_subgroup("walking")
@export var walkFrontAnim :Texture2D
@export var walkBackAnim :Texture2D
@export var walkAnimFPS :int = 0
@export var walkFrameCount :int = 0

@export_subgroup("attacking")
@export_subgroup("other")


func applyIdleAnimation(sprite:Sprite2D):
	sprite.texture = idleAnim
	sprite.hframes = idleAnimFrameCount
