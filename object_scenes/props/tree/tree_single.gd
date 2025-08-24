extends Node2D

func _process(delta: float) -> void:
	var b = global_position.y * 100.0
	$TreeTop.offset.y = sin( (Time.get_ticks_msec() + b) * 0.002 )
	$TreeTop.offset.x = sin( (Time.get_ticks_msec() + b) * 0.001 )
