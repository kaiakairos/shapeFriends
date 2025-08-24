extends Node2D
class_name BattleEnemy

######### INHERIT OFF OF THIS SCRIPT TO CREATE ENEMIES IN COMBAT ########

# EXPORTS #

@export var maxHealth :int = 10
var health :int= 10
var dead:bool = false # used to determine whether or not object is selectable and simulated in battle

@export var defense :float = 1.0 # defense acts as a multiplier
@export var speed :int = 10 # raw speed to determine turn order

@export var enemyName :String = "enemy"
@export_multiline var enemyDescription :String = "this is an enemy"
var enemyPosition :int = 0

@export var xpDrop :int = 5

signal finishedWithAttack
signal finishedWithDead

@onready var battleHandler :Node2D = get_parent().get_parent()

func _ready() -> void: ## DONT OVERRIDE READY
	health = maxHealth
	onReady() # <--- use this instead for ready functions

func flash():
	var w = sin( Time.get_ticks_msec() * 0.01 ) + 1.5
	modulate = Color(w,w,w)

func resetFlash():
	modulate = Color.WHITE

func finishTurn():
	await get_tree().process_frame
	emit_signal("finishedWithAttack")

func finishDeath():
	dead = true
	await get_tree().process_frame
	emit_signal("finishedWithDead")
	

func hurt(damage:int):
	damage = int(damage * defense)
	damage = max(1,damage) # make sure damage is never negative
	
	health -= damage
	health = clamp(health,0,maxHealth)
	
	BattleData.summonDamageIndicator(global_position + Vector2(randi()%6,randi()%6),-damage)
	print("took " + str(damage) + " damage...")

func heal(amount:int):
	
	health += amount
	health = clamp(health,0,maxHealth)
	
	BattleData.summonDamageIndicator(global_position + Vector2(randi()%6,randi()%6),amount)

func attackRandomPlayer(damage:int) -> void:
	var r :int = getRandomLivingPlayer()
	if r == -1:
		return
	if battleHandler.playersDefending.has(r): # player attacked is defending
		damage = int( damage * 0.5  ) # halved damage!
	BattleData.changePlayerHealth(r,-damage)

func getRandomLivingPlayer() -> int:
	var gulp :Array[int]= [] 
	for i in range(BattleData.getNumberOfPlayers()): # collects all living players
		if BattleData.getHealthCurrent(i) > 0:
			gulp.append(i)
	gulp.shuffle()
	if gulp.size() == 0:
		return -1 # return invalid player
	
	return gulp[0]



################# COPY THE FUNCTIONS BELOW TO NEW SCRIPT ###################

func onReady() -> void: 
	pass

func onHit(playerID:int,move:String) -> void:
	pass

func onTurnEnded() -> void: # runs at the end of the turn cycle
	pass

func onDeath() -> void:
	finishDeath()

func onPerformAttack() -> void: # this function should always end with finishTurn
	finishTurn()
