extends Node2D
class_name BattleActor

@export var actorName:String = "actor"
@export_enum("ENEMY","FRIEND","NEUTRAL") var alliance :int = 0

@export_group("Stats")
@export var maxHealth :int = 30 # hit points
var health :int = 30

@export var defense :int = 0 # flat damage resist

@export_group("Moves")
@export var availableMoves :Array[String]= [] # fill later when we have move systemm

@export_group("Movement")
@export_enum("ANYTHING","KNIGHT","ROOK","BISHOP","QUEEN") var movementType :int = 0
@export var movementRange :int = 5

@export_group("AI")
@export var intelligence :int = 5 # how well will this enemy avoid making stupid moves?
@export_subgroup("Scoring")
@export var damageGivenMultiplier :float = 1.0 # how neutral is this enemy about hitting players?
@export var damageTakenMultiplier :float = 1.0 # how neutral is this enemy about recieving damage?
@export var playerKillScore :int = -10 # should this enemy avoid killing players?

### game data ###
var mapPos :Vector2i = Vector2i.ZERO
var battleScene :BattleScene

var moveToPerform :String = ""
var moveIndex :int = 0

func _ready() -> void:
	setRealPosition()
	scale = Vector2(1.0,2.0)

func setRealPosition() -> void:
	position = (mapPos * 20) + Vector2i(10,10)

func setRotation(angle:float,zindex:int) -> void:
	rotation = angle
	z_index = zindex

func AIDecide():
	pass


## Copied Functions ##
# These can handle both animations and enemy specific behaviors

func onMakingDecision(): # can be over ridden
	AIDecide()

func onPerformingMove():
	pass

func onBattleStart():
	pass

func onTurnEnd():
	pass

func onDeath():
	pass

func onWin():
	pass
