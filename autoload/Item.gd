extends Node

enum moveRange {SINGLE_ENEMY,ALL_ENEMY,SINGLE_FRIEND,ALL_FRIEND}
enum useCase {ANYWHERE,IN_BATTLE_ONLY,IN_WORLD_ONLY,NEVER}

var inventory :Array[String] = []
var items :Dictionary[String,Dictionary]= {
	"poop food": {
		"description":"yummy poop food...",
		"useCase":useCase.ANYWHERE,
		"range":moveRange.SINGLE_FRIEND,
	}
}


func _ready() -> void:
	for i in range(4):
		inventory.append("poop food")
	for i in range(2):
		inventory.append("bad food")

func addItemToInventory(item:String) -> bool: # returns whether or not adding item was successful
	if inventory.size() >= 12:
		return false # inventory full !
	inventory.append(item)
	return true

func consumeItemFromInventory(item:String) -> bool: # returns a bool if item is owned
	var i :int= 0
	for g in inventory:
		if g == item:
			inventory.remove_at(i)
			return true
		i += 1
	return false

func getItemDescription(item:String) -> String:
	if !items.has(item):
		return "no description"
	return items[item]["description"]

func getItemUseCase(item:String) -> int:
	if !items.has(item):
		return useCase.NEVER
	return items[item]["useCase"]

func getItemRange(item:String) -> int:
	if !items.has(item):
		return moveRange.ALL_FRIEND
	return items[item]["range"]
