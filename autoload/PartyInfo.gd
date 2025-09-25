extends Node

## AUTOLOAD ##
# Handles anything to do with the party specifically

var allPartyMembers :Dictionary[String,PartyMember] = { # Not edited in game
	"square" : load("res://fighting/partyMemberResources/Square.tres"),
	"triangle" : load("res://fighting/partyMemberResources/Triangle.tres"),
	"rhombus" : load("res://fighting/partyMemberResources/Rhombus.tres"),
	"oval" : load("res://fighting/partyMemberResources/Oval.tres"),
}

var currentPartyMembers :Array[String] = [ # can be edited and should be saved
	"square",
	"triangle",
	"rhombus",
	"oval"
]

func getPartyMemberWalkSprite(memberName:String) -> Texture2D:
	return allPartyMembers[memberName].worldMovementSprite

func checkForPartyMember(member:String) -> bool:
	return currentPartyMembers.has(member)
