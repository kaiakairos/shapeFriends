extends Camera2D
class_name GameCamera

@export var path :Path2D
var pathFollow :PathFollow2D

@export var rotationCurve :Curve

var targetOffset :Vector2

# previos holder
var previousRotation :float = 1234.56
var previousOffset :Vector2i = Vector2i(-999,-999)

func _ready() -> void:
	
	Global.camera = self
	
	pathFollow = PathFollow2D.new()
	path.add_child(pathFollow)
	path.top_level = true
	
	global_position = Vector2.ZERO
	setCamera(1.0)
	sendUpdates()

func _process(delta: float) -> void:
	setCamera(0.1)
	sendUpdates()
	

func setCamera(lerpStrength:float):
	var curve = path.curve
	var balls :float = curve.get_closest_offset(path.to_local(Global.player.global_position))
	
	pathFollow.progress = balls
	targetOffset = lerp(targetOffset,pathFollow.global_position,lerpStrength)
	offset = Vector2i( targetOffset )
	getRotation(pathFollow.progress_ratio,lerpStrength)

func getRotation(progress:float,lerpStrength:float):
	var urgh = rotationCurve.sample(progress)
	rotation = lerp_angle(rotation,urgh * PI * 2,lerpStrength)

func sendUpdates():
	if previousOffset != Vector2i(offset):
		Global.emit_signal("updateCamPosition",Vector2i(offset),rotation)
	
	if previousRotation != snapped(rotation,0.001):
		Global.emit_signal("updateCamRotation",Vector2i(offset),rotation)
	
	previousOffset = Vector2i(offset)
	previousRotation = snapped(rotation,0.001)

func getZ(objGlobal:Vector2) -> int:
	
	return (objGlobal - global_position).rotated(-rotation).y + 1000
