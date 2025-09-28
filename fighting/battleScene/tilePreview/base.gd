extends Node2D

@export var camera :Camera2D


func _process(delta: float) -> void:
	$Hover.position = Vector2(0,-2).rotated(camera.rotation)
	
	$Hover.modulate.a = 0.5 + (sin((Time.get_ticks_msec() * 0.02) + global_position.x + global_position.y) * 0.4 )
	
