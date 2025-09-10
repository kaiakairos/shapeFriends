extends Node

########################################################
#################### PLAYER DATA #######################
########################################################

#var playersInCrew :int = 4 # 1 - 4
var players :Array[PlayerData]= [
	load("res://fighting/playerResources/SquareData.tres"),
	load("res://fighting/playerResources/TriangleData.tres"),
	load("res://fighting/playerResources/RhombusData.tres"),
	load("res://fighting/playerResources/OvalData.tres"),
]

signal changePlayerCount

signal playerHealthUpdate(player:int,amount:int)

var teamMana :int = 50
var teamManaMax :int = 100
signal manaUpdate(amount)

var teamLevel :int = 1
var teamExperience :int = 0
signal levelUpdate
signal experienceUpdate(amount:int)

@onready var damageIndicator = preload("res://fighting/damageIndicator/damage_indicator.tscn")

@onready var battleScene = preload("res://fighting/battleScreen/battle_screen.tscn")
var canvasLayer :CanvasLayer = CanvasLayer.new()

var scene

signal finishedWithBattle

func _ready() -> void:
	resetPlayerHealths()
	add_child(canvasLayer)
	
	
func startBattle(enemies:Array[PackedScene],messages:Array[String]):
	
	var rect = ColorRect.new()
	rect.color = Color.BLACK
	rect.color.a = 0.0
	rect.size = Vector2(400,300)
	rect.z_index = 4096
	canvasLayer.add_child(rect)
	var tween = get_tree().create_tween()
	tween.tween_property(rect,"color:a",1.0,0.2)
	await tween.finished
	
	scene = battleScene.instantiate()
	scene.enemies = enemies
	scene.messages = messages
	
	canvasLayer.add_child(scene)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(rect,"color:a",0.0,0.2)
	await tween2.finished
	rect.queue_free()

func endBattle(lost:bool=false):
	var rect = ColorRect.new()
	rect.color = Color.BLACK
	rect.color.a = 0.0
	rect.size = Vector2(400,300)
	rect.z_index = 4096
	canvasLayer.add_child(rect)
	var tween = get_tree().create_tween()
	tween.tween_property(rect,"color:a",1.0,0.2)
	await tween.finished
	
	scene.queue_free()
	if lost:
		await get_tree().process_frame
		Global.inCutscene = false
		Global.loadGame() # ideally switch to game over screen
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(rect,"color:a",0.0,0.2)
	await tween2.finished
	rect.queue_free()
	emit_signal("finishedWithBattle")

func getHealthCurrent(playerID:int) -> int:
	return players[playerID].health

func getHealthMax(playerID:int) -> int:
	# this function determines how level effects health
	var defaultHealth :int = players[playerID].baseHealthMax
	var baseMaxHealth :int = ( (defaultHealth * (teamLevel-1.0) )/10.0 + 2.0) * 15.0
	return baseMaxHealth

func getCurrentMana() -> int:
	return teamMana

func getManaMax() -> int:
	return teamManaMax

func changePlayerHealth(playerID:int,amount:int):
	var oldHealth :int = players[playerID].health
	var newHealth = oldHealth + amount
	
	newHealth = min(newHealth,getHealthMax(playerID)) # caps health at max
	
	players[playerID].health = newHealth
	
	emit_signal("playerHealthUpdate",playerID,amount)

func resetPlayerHealths() -> void:
	for i in range(getNumberOfPlayers()):
		players[i].health = getHealthMax(i)
		emit_signal("playerHealthUpdate",i,9999)

func giveHealthToAllPlayers(amount:int):
	for i in range(getNumberOfPlayers()):
		players[i].health = min(players[i].health + amount,getHealthMax(i))
		emit_signal("playerHealthUpdate",i,amount)

func getAllMoves(playerID:int) -> Array:
	return players[playerID].moves

func getSpecialMove(playerID:int,selectID:int) -> String:
	return players[playerID].moves[selectID]

func summonDamageIndicator(globalpos:Vector2,amount:int):
	var ins = damageIndicator.instantiate()
	ins.amount = amount
	ins.position = globalpos
	canvasLayer.add_child(ins)

func healDownedPlayers() -> void:
	for i in range(getNumberOfPlayers()):
		if players[i].health > 0:
			continue
		if players[i].health <= -9:
			changePlayerHealth(i,10)
		else:
			changePlayerHealth(i,abs(players[i].health) + 1)

func getNumberOfPlayers() -> int:
	return players.size()

func getPlayerName(id:int) -> String:
	return players[id].name

func getPlayerColor(id:int) -> Color:
	return players[id].color
	
func getPlayerBattleBorder(id:int) -> Texture2D:
	return players[id].battleBorder
	
func getPlayerWorldSprite(id:int) -> Texture2D:
	return players[id].worldSprite

func addExperience(amount:int) -> bool: # returns if levelled up
	teamExperience += amount
	var levelUps :Array[int] = [
		3,14,50,104,230,450,764,1202,1929,2652,3509,4830,6302,7852,8921,
	]
	
	if teamLevel-1 > levelUps.size():
		return false
	
	var currentXPRequired :int = levelUps[teamLevel-1] # equals '3' at level 1
	if teamExperience >= currentXPRequired:
		# level up!
		teamExperience -= currentXPRequired
		teamLevel += 1
		return true
	
	return false

func getPlayerBashDamage(playerID:int) -> int:
	return 5 + (players[playerID].baseAttack  * teamLevel)

########################################################
#################### ENEMY DATA ########################
########################################################
