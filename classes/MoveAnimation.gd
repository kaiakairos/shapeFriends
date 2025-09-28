extends Node2D
class_name MoveAnimation

# Every move will have an animation that inherits this class
# The animation will handle WHEN actors are damaged, if statuses are applied
# to the world, move specific actions, etc.
# However, it does not handle the STATS of the damage. That is up to the MOVE resource.
# This script APPLIES the damage/status though, and it can easily overwrite them if needed

signal finishedWithMove # emitted when its time for the manager to proceed to the next move.
# if this is never emitted, the game will softlock

var moveResource :Move # Not hardcoded to each animation, in case we want to reuse animation
# for multiple different moves (like basic food heals)

######### COPY BELOW ONLY ######################

func performMove(actorsToHit:Array[BattleActor],attacker:BattleActor,tiles:Array[Vector2i]):
	print("WAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHHHHHHH !!!!!!!!!!!!!!!!!!!!!!")
	await get_tree().process_frame # needs to wait at least one frame
	emit_signal("finishedWithMove") # end turn

#################################################

func dealDamageToAll(actorsToHit:Array[BattleActor]):
	pass

func dealDamageToOne(actor:BattleActor):
	pass
