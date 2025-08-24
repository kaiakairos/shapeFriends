extends BattleEnemy

var sinoffset :float = 0.0

func _process(delta: float) -> void:
	scale.x = (sin(Time.get_ticks_msec()*0.02 + sinoffset) * 0.1) + 0.5
	scale.y = (sin(Time.get_ticks_msec()*0.01 + sinoffset) * 0.025) + 0.5

func onReady() -> void: 
	sinoffset = enemyPosition

func onHit(playerID:int,move:String) -> void:
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE

func onDeath() -> void:
	set_process(false)
	$Goku.rotate(PI)
	await get_tree().create_timer(1.0).timeout
	#hide()
	finishDeath()

func onTurnEnded() -> void:
	heal(20)

func onPerformAttack() -> void:
	battleHandler.dialogue.displayDialogue("Hmph...\nI hate faggots!!!")
	
	await get_tree().create_timer(1.0).timeout
	
	for i in range(4):
		attackRandomPlayer(50)
		await get_tree().create_timer(0.5).timeout

	await get_tree().create_timer(0.2).timeout
	battleHandler.dialogue.clearbox()
	finishTurn()
