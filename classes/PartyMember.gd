extends Resource
class_name PartyMember

# These values should never be changed in game.

@export var name :String = "friend"
@export var worldMovementSprite :Texture2D

## Health at level 1
@export var baseHealth :int = 30

## How fast this character moves during a battle
@export var battleMovementSpeed :int = 50

@export var battleActorFile :String = ""
