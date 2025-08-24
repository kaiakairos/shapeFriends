extends Node

var state = null : set = set_state
var previous_state = null
var states = {}

@onready var parent = get_parent()
@onready var attackHandler = $"../playerAttackHandler"

func _ready() -> void:
	add_state("idle") # select player action
	add_state("special") # selecting from special
	add_state("item") # selecting from item
	add_state("enemySelect") # select enemy
	add_state("partySelect") # select party member
	add_state("turnAction") # carry out each turn and animation and such
	add_state("win")
	add_state("lost")
	
	await get_tree().process_frame
	set_state(states.idle)

func _state_logic(delta):
	match state:
		states.idle:
			parent.selectItemIdle()
		states.enemySelect:
			parent.enemyContainer.get_children()[parent.enemySelected].flash()
			parent.selectEnemy()
		states.special:
			parent.selectItem()
		states.item:
			parent.selectItem()
		states.partySelect:
			parent.selectParty()

func _get_transition(delta):
	match state:
		states.idle:
			# we need to select what the player is doing
			var input = parent.getSelectionInput()
			if input == 0:
				return # return if player has made no action
			
			if input == -1: # back
				if parent.makingDecisionOnPlayer > 1:
					parent.makingDecisionOnPlayer -= 1
					parent.playersDefending.erase(parent.makingDecisionOnPlayer-1)
					parent.updateDefenders()
					return states.idle
			
			if input == 1: # option selected
				if parent.currentMoveSelection == 0: # bash
					parent.tempMoveHolder = "bash"
					return states.enemySelect
				
				if parent.currentMoveSelection == 1: # special
					return states.special
				
				if parent.currentMoveSelection == 2: # item
					return states.item
				
				if parent.currentMoveSelection == 3: # defend
					
					parent.playersDefending.append(parent.makingDecisionOnPlayer-1)
					parent.fillPlayerDecision(parent.makingDecisionOnPlayer,"defend",0,999)
					
					# additional animation in here probably
					parent.updateDefenders()
					
					BattleData.teamMana += 20 # defense mana, will probably change
					$"../manaBarBig".updateMana()
					parent.playerCostContainer[parent.makingDecisionOnPlayer-1] = -20
					
					parent.makingDecisionOnPlayer += 1
					
					if parent.makingDecisionOnPlayer > BattleData.getNumberOfPlayers():
						parent.makingDecisionOnPlayer = 1
						return states.turnAction
					
					return states.idle
					
		states.enemySelect:
			var input = parent.getSelectionInput()
			if input == -1:
				return states.idle
			
			if input == 1:
				
				var m :String= parent.tempMoveHolder # held move
				parent.fillPlayerDecision(parent.makingDecisionOnPlayer,m,parent.enemySelected,parent.playerAttackHandler.getMoveSpeed(m))
				parent.makingDecisionOnPlayer += 1
				
				if parent.makingDecisionOnPlayer > BattleData.getNumberOfPlayers():
					parent.makingDecisionOnPlayer = 1
					return states.turnAction
				return states.idle # return to original state to select next enemy
		states.partySelect:
			var input = parent.getSelectionInput()
			if input == -1:
				return states.idle
			if input == 1:
				var m :String= parent.tempMoveHolder # held move
				parent.fillPlayerDecision(parent.makingDecisionOnPlayer,m,parent.playerSelected,parent.playerAttackHandler.getMoveSpeed(m))
				parent.makingDecisionOnPlayer += 1
				
				if parent.makingDecisionOnPlayer > BattleData.getNumberOfPlayers():
					parent.makingDecisionOnPlayer = 1
					return states.turnAction
				return states.idle # return to original state to select next enemy
			
			
		states.turnAction:
			if !parent.performingTurn:
				match parent.battleWinState:
					-1:
						return states.lost
					0:
						parent.turn += 1
						return states.idle
					1:
						return states.win
		states.special:
			var input = parent.getSelectionInput()
			if input == 0:
				return # return if player has made no action
			if input == -1:
				return states.idle
			
			if input == 1: # option selected
				var truePosition :int = parent.selectedItem.x + (parent.selectedItem.y * 2)
				var move:String = BattleData.getSpecialMove(parent.makingDecisionOnPlayer-1,truePosition)
				parent.tempMoveHolder = move
				print(move)
				var range = attackHandler.getMoveHitRange(move)
				var cost = attackHandler.getMoveManaCost(move)
				
				if cost > BattleData.teamMana:
					return # maybe make error sound in here
				
				# discardMana
				BattleData.teamMana -= cost
				parent.playerCostContainer[parent.makingDecisionOnPlayer-1] = cost # remember the cost so we can refund if player changes mind
				$"../manaBarBig".updateMana()
				if range == 0: # single enemy
					return states.enemySelect
				if range == 1 or range == 3: # all enemies or all friends
					parent.fillPlayerDecision(parent.makingDecisionOnPlayer,move,0,parent.playerAttackHandler.getMoveSpeed(move))
					parent.makingDecisionOnPlayer += 1
					return states.idle
				if range == 2: # single friend
					return states.partySelect
		
		states.item:
			var input = parent.getSelectionInput()
			if input == 0:
				return # return if player has made no action
			if input == -1:
				return states.idle
			
			if input == 1: # option selected
				var truePosition :int = parent.selectedItem.x + (parent.selectedItem.y * 2)
				if parent.itemMenuType == 2:
					truePosition += 6
				var itemToUse:String = Item.inventory[truePosition]
				print(itemToUse)
				var useCase = Item.getItemUseCase(itemToUse)
				if useCase == 2 or useCase == -1: # ban world only items
					# play error sound or something
					return
				var range = Item.getItemRange(itemToUse)
				
				parent.playerItemContainer[parent.makingDecisionOnPlayer-1] = Item.inventory.duplicate() # save entire inventory
				parent.tempMoveHolder = itemToUse
				Item.consumeItemFromInventory(itemToUse)
				if range == 0: # single enemy
					return states.enemySelect
				if range == 1 or range == 3: # all enemy or all friend
					parent.fillPlayerDecision(parent.makingDecisionOnPlayer,itemToUse,0,999999)
					parent.makingDecisionOnPlayer += 1
					return states.idle
				if range == 2: # single friend
					return states.partySelect
	
	return null

func _enter_state(new_state,old_state):
	
	$"../tempStateLabel".text = "state: " + states.keys()[new_state]
	
	match new_state:
		states.idle:
			
			if parent.makingDecisionOnPlayer > BattleData.getNumberOfPlayers():
				set_state(states.turnAction)
				return
			
			if BattleData.getHealthCurrent(parent.makingDecisionOnPlayer-1) <= 0:
				# this player is dead
				parent.makingDecisionOnPlayer += 1
				set_state(states.idle)
				return
			
			if parent.turn < parent.messages.size():
				parent.dialogue.displayDialogue(parent.messages[parent.turn])
			else:
				parent.dialogue.displayDialogue(parent.messages[parent.messages.size()-1])
			
			if parent.playerCostContainer[parent.makingDecisionOnPlayer-1] != 0: # refund mana
				BattleData.teamMana += parent.playerCostContainer[parent.makingDecisionOnPlayer-1]
				$"../manaBarBig".updateMana()
				parent.playerCostContainer[parent.makingDecisionOnPlayer-1] = 0
			
			if parent.playerItemContainer[parent.makingDecisionOnPlayer-1].size() > 0: # refund item
				Item.inventory = parent.playerItemContainer[parent.makingDecisionOnPlayer-1].duplicate()
				parent.playerItemContainer[parent.makingDecisionOnPlayer-1] = []
			
			#$"../manaBarBig".setBaseColor( $"../PlayerHUDContainer".get_child(0).getColor(parent.makingDecisionOnPlayer-1) )
			
			$"../tempSelectionLabel".show()
			if parent.getSelectionInput() != -1 or old_state == states.idle:
				parent.currentMoveSelection = 0
			parent.updateIdleSelection()
			#while BattleData.getHealthCurrent(parent.makingDecisionOnPlayer-1)<=0:
				#parent.makingDecisionOnPlayer += 1
			
			parent.selectPlayer(parent.makingDecisionOnPlayer)
		states.enemySelect:
			parent.enemySelected = parent.findEnemyThatIsntDeadID(parent.enemySelected)
			parent.resetEnemySelect()
			parent.toggleEnemySelect(true)
		states.turnAction:
			var fuckyoustupidgayerror :Array[int] = [0,0,0,0,0,0]
			parent.playerCostContainer = fuckyoustupidgayerror
			
			var itemerrortoo :Array[Array] = [[],[],[],[]]
			parent.playerItemContainer = itemerrortoo
			
			parent.selectPlayer(-1)
			parent.performingTurn = true
			parent.performMoves()
		states.special:
			parent.toggleItemHolder(true,0)
			await get_tree().process_frame
			parent.selectItem(true)
		states.item:
			parent.toggleItemHolder(true,1)
			await get_tree().process_frame
			parent.selectItem(true)
		states.lost:
			parent.dialogue.displayDialogue("you've been defeated!")
			await parent.dialogue.finishedDialogue # temporary, load save here instead
			BattleData.endBattle(true)
		states.win:
			parent.dialogue.displayDialogue("You won!")
			await parent.dialogue.finishedDialogue
			
			var xp :int =0
			for enemy in parent.enemyContainer.get_children():
				xp += enemy.xpDrop
			var levelledUp = BattleData.addExperience(xp)
			
			parent.dialogue.displayDialogue("You recieved " + str(xp) + " xp!" )
			await parent.dialogue.finishedDialogue
			if levelledUp:
				BattleData.giveHealthToAllPlayers(0)
				parent.dialogue.displayDialogue("Level up!\nNew Level: " + str(BattleData.teamLevel))
				await parent.dialogue.finishedDialogue
			
			BattleData.endBattle()
			# stats, unload back into world here
		states.partySelect:
			$"../PlayerHUDContainer".get_child(0).selectedByMenu=true
			parent.playerSelected = 0
			$"../PlayerHUDContainer".get_child(parent.makingDecisionOnPlayer-1).selected = false
		
func _exit_state(old_state, new_state):
	match old_state:
		states.idle:
			$"../tempSelectionLabel".hide()
			parent.dialogue.clearbox()
		states.enemySelect:
			parent.enemySelected = parent.findEnemyThatIsntDeadID(parent.enemySelected)
			parent.resetEnemySelect()
			parent.toggleEnemySelect(false)
		states.turnAction:
			if new_state == states.idle:
				parent.runTurnEnded()
				BattleData.healDownedPlayers()
			parent.makingDecisionOnPlayer = 1
			parent.playersDefending.clear()
			parent.updateDefenders()
		states.special:
			parent.toggleItemHolder(false)
			$"../manaBarBig".updatePreview()
		states.item:
			parent.toggleItemHolder(false)
		states.partySelect:
			for i in $"../PlayerHUDContainer".get_children():
				i.selectedByMenu = false
		
#### dont edit things below ####

func _process(delta):
	if state != null:
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null:
			set_state(transition)

func set_state(new_state):
	previous_state = state
	state = new_state
	
	if previous_state != null:
		_exit_state(previous_state,new_state)
	
	if new_state != null:
		_enter_state(new_state,previous_state)

func add_state(state_name):
	states[state_name] = states.size()
