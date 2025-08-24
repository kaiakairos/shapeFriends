extends Node2D

var boilTick :float = 0.0
var wiggle :float = 0.0

var ugh :bool = false

@export var speed:float= 5

func _process(delta: float) -> void:
	boilTick += delta
	if boilTick > 0.5:
		$Base.frame = ($Base.frame + 1) % 3
		$Mask.frame = $Base.frame
		boilTick = 0.0
	
	$Mask/juice/liquidSlide.position.x -= speed
	if $Mask/juice/liquidSlide.position.x < -150.0:
		$Mask/juice/liquidSlide.position.x += 100.0
	
	$Mask/juice/liquidSlide2.position.x += speed
	if $Mask/juice/liquidSlide2.position.x > -50.0:
		$Mask/juice/liquidSlide2.position.x -= 100.0
		
	
	$Mask/juice2/liquidSlide.position.x -= speed
	if $Mask/juice2/liquidSlide.position.x < -150.0:
		$Mask/juice2/liquidSlide.position.x += 100.0
	
	$Mask/juice2/liquidSlide2.position.x += speed
	if $Mask/juice2/liquidSlide2.position.x > -50.0:
		$Mask/juice2/liquidSlide2.position.x -= 100.0
	
	position = lerp(position,Vector2.ZERO,0.1)
	
	if ugh:
		$Mask/juice2.position.y = lerp($Mask/juice2.position.y,$Mask/juice.position.y,0.05)

func updateMana() -> void:
	var max_value :int= BattleData.getManaMax()
	var value :int= BattleData.teamMana
	
	var ratio :float = float(value) / float(max_value) # value between 0 - 1
	$Label.text = str(value)
	# -60.0 = maximum, 32.0 = minimum, 92 total
	position.x = -8.0
	var targetPos :float = clamp(( 92.0 * (1.0 - ratio) ) - 60.0,-60.0,32.0)
	$Mask/juice.position.y = targetPos
	
	

func updatePreview(amount:int=0):
	if amount == 0:
		$Mask.move_child($Mask/juice2,0)
		$Mask/juice2/ColorRect.size.y = 500
		ugh = true
		return
	
	ugh = false
	
	$Mask.move_child($Mask/juice2,1)
	var max_value :int= BattleData.getManaMax()
	var value :int= BattleData.teamMana
	var ratio :float = float(amount) / float(max_value)
	
	$Mask/juice2/ColorRect.size.y = (92.0 * ratio) - 10.0
	$Mask/juice2.position.y = $Mask/juice.position.y
	
	if amount <= value:
		$Mask/juice2.modulate = Color.WHITE
	else:
		$Mask/juice2.modulate = Color.RED

func setBaseColor(color:Color) -> void:
	$Mask/juice.modulate = color
