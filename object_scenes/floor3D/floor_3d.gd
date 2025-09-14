extends Polygon2D

@export var height : int = 0
@export var onTop : bool = false

@export var zIndexForce :int = 0

func _ready() -> void:
	Global.connect("updateCamRotation",updatecam)
	if onTop:
		z_index = 2000
	if zIndexForce != 0:
		z_index = zIndexForce

func _process(delta: float) -> void:
	pass

func updatecam(camPos:Vector2i,camAngle:float):
	offset = Vector2(0,-height).rotated(camAngle)
	texture_offset = offset * -1
	if onTop:
		if Geometry2D.is_point_in_polygon(to_local(Global.player.global_position) - offset,polygon):
			modulate.a = 0.6
		else:
			modulate.a = 1.0
