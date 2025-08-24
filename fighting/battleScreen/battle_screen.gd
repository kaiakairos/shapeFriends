extends Node2D

@onready var hudobj = preload("res://fighting/battleScreen/playerHealthDisplay/player_hud.tscn")
@onready var enemyContainer = $enemyContainer
@onready var playerAttackHandler = $playerAttackHandler
@onready var manabar = $manaBarBig
@onready var dialogue = $dialogueBox

@export var enemies :Array[PackedScene]
@export var messages :Array[String]
var turn :int = 0

# determines which player is being used to select stuff
var makingDecisionOnPlayer :int = 1 # 1,2,3,4
var currentMoveSelection :int = 0

var tempMoveHolder :String= "bash"

var playersDefending :Array[int] = []

var enemySelected :int = 0
var playerSelected :int = 0

var player1Decision :Dictionary[String,Variant]= {}
var player2Decision :Dictionary[String,Variant]= {}
var player3Decision :Dictionary[String,Variant]= {}
var player4Decision :Dictionary[String,Variant]= {}
signal playerMoveFinished
var playerCostContainer :Array[int] = [0,0,0,0,0,0] # for refunding players if u cancel a spell
var playerItemContainer :Array[Array] = [[],[],[],[]] # for refunding players if u cancel an item use


var performingTurn :bool = false
var battleWinState :int = 0 #0-normal, 1-won, -1-lost

var selectedItem :Vector2i = Vector2i.ZERO
var itemMenuType :int = 0

func _ready() -> void:
	# create player HUD objects
	for i in range(BattleData.getNumberOfPlayers()):
		var ins = hudobj.instantiate()
		ins.position = Vector2(i * 94,0)
		ins.playerID = i
		$PlayerHUDContainer.add_child(ins)
	$PlayerHUDContainer.position.x = 200 + (BattleData.getNumberOfPlayers() * 94.0 * -0.5)
	
	# update mana bar
	$manaBarBig.updateMana()
	
	# create enemies
	var i :int= 0
	for enemy in enemies: # get packed scenes
		var ins = enemy.instantiate() # create enemy obj
		ins.position = Vector2(i * 120,0)
		ins.enemyPosition = i
		enemyContainer.add_child(ins)
		i += 1
	
	enemyContainer.position.x = 200.0 - ( (i-1)* 60.0 )
	BattleData.connect("playerHealthUpdate",playerHealthUpdate)
	
func getSelectionInput() -> int:

	if Input.is_action_just_pressed("cancel"):
		playMenuSelect(true)
		return -1
	
	if Input.is_action_just_pressed("interact"):
		playMenuSelect()
		return 1
	
	return 0

func selectItemIdle() -> void:
	var move :int = 0
	if Input.is_action_just_pressed("move_right"):
		move = 1
		playMenu()
	if Input.is_action_just_pressed("move_left"):
		playMenu(true)
		move = -1
	
	# bash, 'special', item, defend
	if move == 0:
		return
	currentMoveSelection += move
	currentMoveSelection = (currentMoveSelection+4) % 4
	updateIdleSelection()

func updateIdleSelection() -> void:
	
	var playerHUDobj = $PlayerHUDContainer.get_child(makingDecisionOnPlayer-1)
	if !is_instance_valid(playerHUDobj):
		return
	playerHUDobj.selectItem(currentMoveSelection)
	
	


func selectEnemy() -> void:
	
	var count :int= enemyContainer.get_child_count()
	var um :int = 0
	
	if Input.is_action_just_pressed("move_right"):
		enemySelected += 1
		um = 1
		resetEnemySelect()
		playMenu()
	if Input.is_action_just_pressed("move_left"):
		enemySelected -= 1
		um = -1
		resetEnemySelect()
		playMenu(true)
	
	if um != 0:
	
		enemySelected = enemySelected % count
		
		for i in range(3): #skips to the next enemy if this enemy is dead
			if enemyContainer.get_child(enemySelected).dead:
				enemySelected += um
				enemySelected = enemySelected % count
		
		toggleEnemySelect(true)

func selectParty() -> void:
	
	var count :int= BattleData.getNumberOfPlayers()
	var um :int = 0
	
	if Input.is_action_just_pressed("move_right"):
		playerSelected += 1
		um = 1
		#resetEnemySelect()
		playMenu()
	if Input.is_action_just_pressed("move_left"):
		playerSelected -= 1
		um = -1
		#resetEnemySelect()
		playMenu(true)
	
	if um != 0:
	
		playerSelected = abs(playerSelected % count)
		#print(playerSelected)
		
		for i in range(BattleData.getNumberOfPlayers()):
			$PlayerHUDContainer.get_child(i).selectedByMenu = i == playerSelected

func selectPlayer(playerID:int):
	var i :int= 1
	for child in $PlayerHUDContainer.get_children():
		if i == playerID:
			child.enableSelected()
		else:
			child.disableSelected()
		
		i += 1


func resetEnemySelect() -> void:
	for enemy in enemyContainer.get_children():
		enemy.resetFlash()

func fillPlayerDecision(playerID:int=1,move:String="bash",actingOn:int=0,speed:int=10) -> void:
	match playerID:
		1:
			player1Decision = {"move":move,"actingOn":actingOn,"speed":speed}
		2:
			player2Decision = {"move":move,"actingOn":actingOn,"speed":speed}
		3:
			player3Decision = {"move":move,"actingOn":actingOn,"speed":speed}
		4:
			player4Decision = {"move":move,"actingOn":actingOn,"speed":speed}

func getTurnOrder() -> Array[String]:
	var speedDictionary :Dictionary[int,Array]= {}
	
	for i in range(BattleData.getNumberOfPlayers()): # collect speed data for players
		if BattleData.getHealthCurrent(i) <= 0: # skip dead players
			continue
		var info :Dictionary= get("player" +str(i+1)+ "Decision")
		var speed :int= 6
		if info.has("speed"):
			speed = info["speed"]
		
		if speedDictionary.has(speed):
			speedDictionary[speed].append( "player" + str(i+1) )
		else:
			speedDictionary[speed] = []
			speedDictionary[speed].append( "player" + str(i+1) )
	
	var enemyI :int =0
	for enemy in enemyContainer.get_children(): # collect speed data for enemies
		
		var speed :int= enemy.speed
		
		if speedDictionary.has(speed):
			speedDictionary[speed].append( "enemy" + str(enemyI) )
		else:
			speedDictionary[speed] = []
			speedDictionary[speed  ].append( "enemy" + str(enemyI) )
		enemyI += 1
	
	
	speedDictionary.sort()
	
	var finalArray :Array[String] = []
	for a in speedDictionary:
		speedDictionary[a].shuffle() # randomize order of turns if speed the same
		finalArray.append_array( speedDictionary[a] ) # add to large array
	
	finalArray.reverse() # so high speeds go first!
	
	
	return finalArray
	

func performMoves() -> void: ## TURN ORDER SHIT
	
	var turnOrder :Array[String]= getTurnOrder()
	var enemies = enemyContainer.get_children()
	
	for turn in turnOrder:
		# perform turn for each character
		match turn:
			"enemy0":
				if enemies[0].dead:
					continue
				enemies[0].onPerformAttack()
				await enemies[0].finishedWithAttack
			"enemy1":
				if enemies[1].dead:
					continue
				enemies[1].onPerformAttack()
				await enemies[1].finishedWithAttack
			"enemy2":
				if enemies[2].dead:
					continue
				enemies[2].onPerformAttack()
				await enemies[2].finishedWithAttack
			# player turns after this
			
			"player1":
				if BattleData.getHealthCurrent(0) <= 0:
					continue
				playerAttackHandler.playerMoves(1,player1Decision["move"],player1Decision["actingOn"])
				await playerMoveFinished
			"player2":
				if BattleData.getHealthCurrent(1) <= 0:
					continue
				playerAttackHandler.playerMoves(2,player2Decision["move"],player2Decision["actingOn"])
				await playerMoveFinished
			"player3":
				if BattleData.getHealthCurrent(2) <= 0:
					continue
				playerAttackHandler.playerMoves(3,player3Decision["move"],player3Decision["actingOn"])
				await playerMoveFinished
			"player4":
				if BattleData.getHealthCurrent(3) <= 0:
					continue
				playerAttackHandler.playerMoves(4,player4Decision["move"],player4Decision["actingOn"])
				await playerMoveFinished
		# after each move, check if we're dead or won
		
		if areAllPlayersDead():
			performingTurn = false
			battleWinState = -1
			return
		
		if areAllEnemiesDead():
			performingTurn = false
			battleWinState = 1
			return
	
	await get_tree().create_timer(0.5).timeout # just a lil delay
	performingTurn = false

func checkIfEnemyDead(enemy:BattleEnemy) -> void:
	if enemy.health <= 0:
		enemy.onDeath()
		await enemy.finishedWithDead

func toggleEnemySelect(enable:bool) -> void:
	$enemyInfo.visible = enable
	var e :BattleEnemy= enemyContainer.get_child(enemySelected)
	$enemyInfo/enemyName.text = e.enemyName
	$enemyInfo/enemyHealthbar.max_value = e.maxHealth
	$enemyInfo/enemyHealthbar.value = e.health

func runTurnEnded() -> void:
	for enemy in enemyContainer.get_children():
		enemy.onTurnEnded()

func findEnemyThatIsntDead(OGenemy:BattleEnemy) -> BattleEnemy:
	# This function is for redirecting attacks towards living enemies
	# in the event that the enemies you targetted are now dead
	
	if !OGenemy.dead: 
		return OGenemy
	for enemy in enemyContainer.get_children():
		if !enemy.dead:
			return enemy
	return OGenemy

func findEnemyThatIsntDeadID(enemyID:int) -> int:
	# This function is for redirecting selection
	if !enemyContainer.get_child(enemyID).dead: 
		return enemyID
	
	var i :int = 0
	for enemy in enemyContainer.get_children():
		if !enemy.dead:
			return i
		i += 1
	return -1

func playerHealthUpdate(playerID:int,amount:int):
	# the actual player tag is already done so just shake the screen n shit
	if amount < 0:
		$screenshake.setShake(10.0)

func areAllPlayersDead() -> bool:
	for i in range(BattleData.getNumberOfPlayers()):
		if BattleData.getHealthCurrent(i) > 0:
			return false
	return true

func areAllEnemiesDead() -> bool:
	for enemy in enemyContainer.get_children():
		if enemy.health > 0:
			return false
	return true

func updateDefenders() -> void:
	for child in $PlayerHUDContainer.get_children():
		if playersDefending.has(child.playerID):
			child.modulate = Color.BLUE
		else:
			child.resetCOLOR()

func toggleItemHolder(enable:bool,menuType:int=0) -> void:
	if !enable:
		$itemcontainer.hide()
		$itemcontainer/desc.text = ""
		$itemcontainer/cost.text = ""
		return
	
	itemMenuType = menuType
	
	for i in $itemcontainer/container.get_children():
		i.queue_free() # clear items
		
	
	if menuType == 0: # spell menu
		var p :Array= BattleData.getAllMoves(makingDecisionOnPlayer-1)
		var m :int = 0
		for i in p:
			var ins = Label.new()
			ins.text = "* " + i
			ins.custom_minimum_size.x = 100
			ins.label_settings = $itemcontainer/Label.label_settings
			#if m == 0:
			#	ins.modulate = Color.GREEN_YELLOW
			$itemcontainer/container.add_child(ins)
			m += 1
		$itemcontainer/Arrow.hide()
		$itemcontainer/Arrow2.hide()
	elif menuType == 1: # item menu 1
		var m :int = 0
		for i in Item.inventory:
			var ins = Label.new()
			ins.text = "* " + i
			ins.custom_minimum_size.x = 100
			ins.label_settings = $itemcontainer/Label.label_settings
			#if m == 0:
			#	ins.modulate = Color.GREEN_YELLOW
			$itemcontainer/container.add_child(ins)
			m += 1
			
			if m == 6:
				break
		
		$itemcontainer/Arrow.visible = Item.inventory.size() > 6
		$itemcontainer/Arrow2.hide()
		
		
	elif menuType == 2:  # item menu 2
		var m :int = 0
		for i in Item.inventory:
			if m < 6:
				m += 1
				continue
			var ins = Label.new()
			ins.text = "* " + i
			ins.custom_minimum_size.x = 100
			ins.label_settings = $itemcontainer/Label.label_settings
			#if m == 0:
			#	ins.modulate = Color.GREEN_YELLOW
			$itemcontainer/container.add_child(ins)
			m += 1
		
		$itemcontainer/Arrow.hide()
		$itemcontainer/Arrow2.show()
		
	$itemcontainer.show()

func selectItem(reset:bool=false,resettheselectiontoo:bool=true):
	var keep :Vector2i= selectedItem
	if Input.is_action_just_pressed("move_right"):
		selectedItem.x += 1
		playMenu()
	if Input.is_action_just_pressed("move_left"):
		selectedItem.x -= 1
		playMenu()
	if Input.is_action_just_pressed("move_down"):
		selectedItem.y += 1
		playMenu(true)
	if Input.is_action_just_pressed("move_up"):
		selectedItem.y -= 1
		playMenu(true)
	
	if reset:
		keep = Vector2i(-2,-2)
		if resettheselectiontoo:
			selectedItem = Vector2i(0,0)
	
	if keep == selectedItem:
		return # didnt change selection
	if selectedItem.x != clamp(selectedItem.x,0,1):
		selectedItem = keep
		return
	if selectedItem.y != clamp(selectedItem.y,0,2):
		# item menu scroll
		if itemMenuType == 0: # is spell menu
			selectedItem = keep
			return
		if Item.inventory.size() <= 6: # inventory isn't long enough to bother
			selectedItem = keep
			return
		if itemMenuType == 1 and selectedItem.y > 0:
			toggleItemHolder(true,2)
			selectedItem = Vector2i(selectedItem.x,0)
		elif itemMenuType == 2 and selectedItem.y < 0:
			toggleItemHolder(true,1)
			selectedItem = Vector2i(selectedItem.x,2)
		else:
			selectedItem = keep
			return
		await get_tree().process_frame
		selectItem(true,false)
		return
	
	var bigArray = $itemcontainer/container.get_children()
	var size :int = bigArray.size()
	
	var truePosition :int = selectedItem.x + (selectedItem.y * 2)
	
	if truePosition >= size:
		selectedItem = keep
		return

	var i :int= 0
	for label in bigArray:
		if truePosition == i:
			label.modulate = Color.GREEN_YELLOW
			var move :String= label.text.trim_prefix("* ")
			var cost :int = playerAttackHandler.getMoveManaCost(move)
			$itemcontainer/desc.text = move.to_upper() +"\n" + playerAttackHandler.getMoveDescription(move)
			$itemcontainer/cost.text = str(cost) + " sp"
			if itemMenuType != 0:
				$itemcontainer/cost.text = ""
				$itemcontainer/desc.text = move.to_upper() + "\n" + Item.getItemDescription(move)
			
			$itemcontainer/desc.modulate = BattleData.getPlayerColor(makingDecisionOnPlayer-1)
			if BattleData.teamMana >= cost:
				$itemcontainer/cost.modulate = Color.WHITE
			else:
				$itemcontainer/cost.modulate = Color.RED
			
			$manaBarBig.updatePreview(cost)
			
		else:
			label.modulate = Color.WHITE

		i += 1

func playMenu(back:bool=false) -> void:
	if back:
		$MenuClickSound.pitch_scale = 1.0
	else:
		$MenuClickSound.pitch_scale = 1.2
	$MenuClickSound.play()

func playMenuSelect(back:bool=false)->void:
	if back:
		$MenuClickSound.pitch_scale = 0.9
		$MenuClickSound.play()
	else:
		$MenuSelectSound.pitch_scale = 1.2
		$MenuSelectSound.play()
