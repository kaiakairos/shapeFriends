extends Node

## MOVE HANDLER ##
var allMoves :Dictionary[String,Move] = {}

func _ready() -> void:
	scanForMoves()

func scanForMoves() -> void:
	var directory = ResourceLoader.list_directory("res://fighting/moves/moveResources")
	for filename in directory:
		if !filename.ends_with(".tres"):
			continue # skip non-resources
		
		var trueString :String = "res://fighting/moves/moveResources/" + filename
		var moveResource :Move = load(trueString)
		allMoves[moveResource.moveID] = moveResource
		
		moveResource.generateHitboxes()

func getHitbox(move:String,index:int=0) -> Array[Vector2i]:
	return allMoves[move].hitboxes[index]

func getHitboxCount(move:String) -> int:
	return allMoves[move].hitboxes.size()

func getMoveSpeed(move:String) -> int:
	return allMoves[move].speed

func getMove(move:String) -> Move:
	return allMoves[move]
