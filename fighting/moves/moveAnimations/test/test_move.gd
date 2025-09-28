extends MoveAnimation

func performMove(actorsToHit:Array[BattleActor],attacker:BattleActor,tiles:Array[Vector2i]):
 	# needs to wait at least one frame
	
	$AnimationPlayer.play("chargeBlast")
	
	await $AnimationPlayer.animation_finished
	emit_signal("finishedWithMove") # end turn
	queue_free()

@export var blastSize :float = 0.0
@export var urpSiize :float = 0.0
func _process(delta: float) -> void:
	$chargeBall.scale = Vector2(blastSize,blastSize) + Vector2(randf_range(-0.25,0.25),randf_range(-0.25,0.25))
	$Kame.scale = Vector2(urpSiize,urpSiize) + Vector2(randf_range(-0.05,0.05),randf_range(-0.05,0.05))
