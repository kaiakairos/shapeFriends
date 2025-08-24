extends Node2D

var amount :int = 587
var ticks :float = 0.0
@onready var label = $axis/Label
@onready var anim = $AnimationPlayer

var alphaBase :float = 1.0

func _ready() -> void:
	if amount == 0:
		queue_free()
		return
	
	if amount > 0: # heal
		label.text = "+" + str(amount)
		modulate = Color.GREEN_YELLOW
		anim.play("heal")
	else:
		label.text = str(amount)
		modulate = Color.RED
		anim.play("damage")

func _process(delta: float) -> void:
	ticks += delta
	modulate.a = (0.8 * alphaBase) + ( sin(ticks*40.0) * 0.2 * alphaBase )
	
	if ticks > 1.5:
		alphaBase = lerp(alphaBase,0.0,0.12)
