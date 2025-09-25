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

# actors

var actors :Array[BattleActor] = []

func _ready() -> void:
	#RenderingServer.viewport_set_update_mode(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_ONCE)
	pass



##################################################
################ STATE STUFF #####################

func setState(newState:int) -> void:
	var oldState :int= state
	state = newState
	if oldState != -1:
		exitState(oldState,newState)
	enterState(newState,oldState)
	
	print("new state: " + states.keys()[newState])

func enterState(newState,oldState) -> void:
	pass

func exitState(oldState,newState) -> void:
	pass

##################################################
##################################################
