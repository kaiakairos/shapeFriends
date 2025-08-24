extends Node

@onready var parent = get_parent()
@onready var dialogue = $"../dialogueBox"

enum moveRange {SINGLE_ENEMY,ALL_ENEMY,SINGLE_FRIEND,ALL_FRIEND}

func playerMoves(playerID:int,move:String,actingOn:int):
	# this function determines what the player's move actually does
	match move:
		"bash":
			var enemy :BattleEnemy= parent.enemyContainer.get_child(actingOn)
			enemy = parent.findEnemyThatIsntDead(enemy)
			enemy.onHit(playerID,move)
			enemy.hurt(BattleData.getPlayerBashDamage(playerID-1))
			
			await get_tree().create_timer(0.4).timeout
			await parent.checkIfEnemyDead(enemy)
		"check":
			var enemy :BattleEnemy= parent.enemyContainer.get_child(actingOn)
			var defense :int = 100 - int(enemy.defense * 100)
			dialogue.displayDialogue(enemy.enemyName + "\nHP:  " + str(enemy.health) + "/" + str(enemy.maxHealth)+"\nDefense: " + str(defense))
			await dialogue.finishedDialogue
			dialogue.displayDialogue(enemy.enemyDescription)
			await dialogue.finishedDialogue
			dialogue.clearbox()
			
			await get_tree().create_timer(0.5).timeout
		"fire":
			var enemies :Array= parent.enemyContainer.get_children()
			dialogue.displayDialogue(BattleData.getPlayerName(playerID-1) + " used flame attack!")
			await dialogue.finishedAnimation
			$attackSounds/flameBuild.play()
			await get_tree().create_timer(1.0).timeout
			for enemy in enemies:
				if enemy.dead:
					continue
				enemy.onHit(playerID,move)
				enemy.hurt(12)
				$attackSounds/flameAttack.play()
				parent.checkIfEnemyDead(enemy)
				await get_tree().create_timer(0.5).timeout
			dialogue.clearbox()
		"heal":
			dialogue.displayDialogue(BattleData.getPlayerName(playerID-1) + " cast healing on "+BattleData.getPlayerName(actingOn)+"!")
			await dialogue.finishedAnimation
			BattleData.changePlayerHealth(actingOn,30)
			await get_tree().create_timer(0.5).timeout
		"food 0":
			dialogue.displayDialogue(BattleData.getPlayerName(actingOn)+" at the test food 0!")
			await dialogue.finishedAnimation
			BattleData.changePlayerHealth(actingOn,3000)
			await get_tree().create_timer(0.5).timeout
		
	await get_tree().create_timer(0.1).timeout
	parent.emit_signal("playerMoveFinished")

func getMoveHitRange(move:String) -> int:
	match move:
		"bash":
			return moveRange.SINGLE_ENEMY
		"check":
			return moveRange.SINGLE_ENEMY
		"fire":
			return moveRange.ALL_ENEMY
		"heal":
			return moveRange.SINGLE_FRIEND
	
	return moveRange.ALL_ENEMY

func getMoveSpeed(move:String) -> int:
	match move:
		"bash":
			return 10
		"check":
			return 40
		"heal":
			return 300
	
	return 9999 # return uber fast if move isnt in here (for items)

func getMoveManaCost(move:String) -> int:
	match move:
		"fire": return 10
		"light": return 100
		"poop blast": return 999
		"heal": return 5
	
	return 0

func getMoveDescription(move:String) -> String:
	match move:
		"check": return "check an enemy's stats"
		"fire": return "rahh!! fire blast !!"
		"heal": return "heal one friend"
	
	return "no description"
