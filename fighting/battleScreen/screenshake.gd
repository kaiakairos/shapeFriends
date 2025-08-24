extends Node

var amountOfShake :float = 0.0
@onready var parent = get_parent()

func _process(delta: float) -> void:
	parent.position.y = sin(Time.get_ticks_msec() * 0.06) * amountOfShake
	
	amountOfShake = lerp(amountOfShake,0.0,0.1)
	
	if amountOfShake < 0.2:
		amountOfShake = 0.0
		parent.position.y = 0
		set_process(false)

func setShake(shakeAmount:float):
	amountOfShake = shakeAmount
	set_process(true)
