extends Node

@onready var parent :Node2D= get_parent()
@export var scaleYOverride :float = 2.0

func _ready() -> void:
	Global.connect("updateCamRotation",updateCamRotation)
	Global.connect("updateCamPosition",updateZIndex)

func updateCamRotation(pos,angle):
	parent.rotation = angle
	parent.scale.y = scaleYOverride
	updateZIndex(pos,angle)

func updateZIndex(pos,angle):
	parent.z_index =  (parent.global_position - pos).rotated(-angle).y + 150
