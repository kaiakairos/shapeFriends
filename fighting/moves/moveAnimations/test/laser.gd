extends MoveAnimation

func performMove(actorsToHit:Array[BattleActor],attacker:BattleActor,tiles:Array[Vector2i]):
	await get_tree().create_timer(3.0).timeout
	
	emit_signal("finishedWithMove")
	queue_free()
