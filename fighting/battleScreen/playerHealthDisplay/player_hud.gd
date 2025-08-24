extends Node2D

@export var playerID:int = 0

@onready var nameLabel :Label = $name
@onready var healthLabel :Label = $healthAmountLabel
@onready var healthBar :TextureProgressBar = $healthBar

var selected:bool = false

var yeah :int = 0

@onready var damage

var selectedByMenu :bool = false

func _ready() -> void:
	
	nameLabel.text = BattleData.getPlayerName(playerID)
	$selectionIcons.modulate = BattleData.getPlayerColor(playerID)
	
	
	$bgsprite.texture = BattleData.getPlayerBattleBorder(playerID)
	updateInfo()
	BattleData.connect("playerHealthUpdate",recieveUpdate)
	
	$outline.modulate.a = 0.0
	if playerID != 0:
		disableSelected()
	else:
		enableSelected()

func _process(delta: float) -> void:
	if selected:
		position.y = lerp(position.y,-21.0,0.4)
		
		var g = $selectionIcons.get_child(yeah)
		var o :float = (sin(Time.get_ticks_msec()*0.015) * 0.5) + 0.5 # ranges 0 to 1.0
		o = 1.2 + ( o * 0.8 )
		g.modulate = Color(o,o,o)
		
		var i :int = 0
		for c in $selectionIcons.get_children():
			c.position.y = lerp(c.position.y,0.0,0.2)
			
			if i == yeah:
				c.scale = lerp(c.scale,Vector2(1.1,1.1),0.2)
			else:
				c.scale = lerp(c.scale,Vector2(1.0,1.0),0.2)
			
			i += 1
		
	else:
		position.y = lerp(position.y,0.0,0.4)
	
	if selectedByMenu:
		var o :float = (sin(Time.get_ticks_msec()*0.015) * 0.5) + 0.5 # ranges 0 to 1.0
		$bgsprite/ColorRect.color.a = o * 0.5
	else:
		$bgsprite/ColorRect.color.a = 0.0
	
func recieveUpdate(player:int,amount:int) -> void:
	if player != playerID:
		return # not us, don't update
	var randx = randi() % 6
	var randy = randi() % 6
	BattleData.summonDamageIndicator(global_position + Vector2(64,0) + Vector2(randx,randy),amount)
	if amount < 0:
		$AudioStreamPlayer2D.play()
		$AudioStreamPlayer2D.pitch_scale = randf_range(0.95,1.05)
	elif amount > 0:
		$AudioStreamPlayer2D2.play()
	updateInfo()

func updateInfo() -> void:
	
	
	var health :int = BattleData.getHealthCurrent(playerID)
	var maxHP :int = BattleData.getHealthMax(playerID)
	
	healthBar.max_value = maxHP
	healthBar.value = max(health,0)
	
	healthLabel.text = str(health) + " / " + str(maxHP)
	
	if health <= 0:
		resetCOLOR()

func enableSelected():
	selected = true

func disableSelected():
	selected = false
	for c in $selectionIcons.get_children():
		c.modulate = Color.WHITE
		c.position.y = 0
		c.scale = Vector2(0.2,0.2)

func selectItem(currentMoveSelection:int):
	yeah = currentMoveSelection
	var i = 0
	for c in $selectionIcons.get_children():
		c.modulate = Color.WHITE
		
		if i == currentMoveSelection:
			c.position.y = -6.0
		
		i += 1

func resetCOLOR():
	modulate = Color.WHITE
	if BattleData.getHealthCurrent(playerID) <= 0:
		modulate = Color.RED
