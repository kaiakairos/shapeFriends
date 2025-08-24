extends Node2D

func _ready() -> void:
	for i in get_children():
		i.position.y = randf_range(-5,5)
	

func _process(delta: float) -> void:
	for i in get_children():
		var b = i.global_position.y * 100.0
		i.offset.y = sin( (Time.get_ticks_msec() + b) * 0.002 ) - 42
		i.offset.x = sin( (Time.get_ticks_msec() + b) * 0.001 )
