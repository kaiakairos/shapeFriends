extends Line2D
class_name Wall3D

@export var wallTexture :Texture2D
@export var wallHeight : int = 128
@export var tileWallTextureHeight : bool = false
@export var generateCollider : bool = true
@export var shadeColor :Color = Color(0.8,0.8,0.8)

@export var wallOffset :int = 0
@export var reversed :bool = false
@export var cullBackface :bool = true
@export var z_index_force :int = 0

@export var defaultXTextureOffset :int = 0
@export var topAngleOffset :Vector2 = Vector2.ZERO

@onready var polygonContainer :Node2D= $polygons


func _ready() -> void:
	createWallPolygons()
	Global.connect("updateCamRotation",setPolygons)
	Global.connect("updateCamPosition",cameraPosOnlyUpdate)
	default_color = Color.TRANSPARENT
	
	if wallTexture != null:
		setUV()
	if generateCollider:
		$StaticBody2D/CollisionPolygon2D.polygon =  createCollider()
	
	setAmbientOcclusion()

func createWallPolygons():
	for i in range(points.size() - 1):
		var newPolygon = Polygon2D.new()
		polygonContainer.add_child(newPolygon)

func setPolygons(camPos:Vector2i,camAngle:float):
	var i :int= 0
	for polygonOBJ in polygonContainer.get_children():
		
		var normal = (points[i] - points[i+1]).rotated(PI/2.0).normalized()
		
		polygonOBJ.visible = !normal.dot( Vector2(0,1).rotated(camAngle) ) > 0.0
		if reversed:
			polygonOBJ.visible = !polygonOBJ.visible # flip if reversed
		if !cullBackface:
			polygonOBJ.visible = true
		if !polygonOBJ.visible and cullBackface:
			i += 1
			continue
		
		var pos1 = Global.camera.getZ(to_global(points[i]))
		var pos2 = Global.camera.getZ(to_global(points[i+1]))
		
		polygonOBJ.z_index = min(pos1,pos2)
		if z_index_force != 0:
			polygonOBJ.z_index = z_index_force
		
		var baseOffset = Vector2(0,-wallOffset).rotated(camAngle)
		
		var newPolygon :PackedVector2Array
		newPolygon.append(points[i] + baseOffset)
		newPolygon.append(points[i + 1] + baseOffset)
		var offset = Vector2(0,-wallHeight).rotated(camAngle)
		newPolygon.append(points[i + 1] + offset + baseOffset + topAngleOffset)
		newPolygon.append(points[i] + offset + baseOffset + topAngleOffset)
		polygonOBJ.polygon = newPolygon
		i += 1

func cameraPosOnlyUpdate(camPos:Vector2i,camAngle:float):
	var i :int =0
	for polygonOBJ in polygonContainer.get_children():
		var pos1 = Global.camera.getZ(to_global(points[i]))
		var pos2 = Global.camera.getZ(to_global(points[i+1]))
		
		polygonOBJ.z_index = min(pos1,pos2)
		i += 1

func setUV():
	var i :int= 0
	var addX = defaultXTextureOffset
	
	for polygon in polygonContainer.get_children():
		polygon.texture = wallTexture
		var size = wallTexture.get_size()
		size.x *= (points[i] - points[i+1]).length() / size.x
		if tileWallTextureHeight:
			size.y *= wallHeight / size.y
		elif wallHeight < 0:
			size.y *= -1
		
		var newUV = PackedVector2Array()
		newUV.append(Vector2(addX,size.y))
		newUV.append(size + Vector2(addX,0))
		newUV.append(Vector2(size.x + addX,0))
		newUV.append(Vector2(addX,0))
		
		polygon.uv = newUV
		addX += (points[i] - points[i+1]).length()
		
		i += 1

func setAmbientOcclusion():
	var newUV = PackedColorArray()
	
	
	
	newUV.append(shadeColor)
	newUV.append(shadeColor)
	newUV.append(Color.WHITE)
	newUV.append(Color.WHITE)
	
	for polygon in polygonContainer.get_children():
		polygon.vertex_colors = newUV

func createCollider() -> PackedVector2Array:
	var polygon : PackedVector2Array = []
	var inverse : PackedVector2Array = []
	
	for i in range(get_point_count()):
		
		var pointPos :Vector2= points[i] # get current point
		var prevPoint :Vector2= points[i]
		var nextPoint :Vector2= points[i]
		if i == 0: # no previous point
			prevPoint = points[i] + (points[i] - points[i + 1])
			nextPoint = points[i + 1]
		elif i == get_point_count() - 1: # no next point
			prevPoint = points[i-1]
			nextPoint = points[i] - (points[i-1] - points[i])
		else: # points? all good...
			prevPoint = points[i-1]
			nextPoint = points[i + 1]
		
		# now we have the positions of all points
		# get vector between points
		var path :Vector2= nextPoint - prevPoint
		var perp :float= path.orthogonal().angle()
		
		polygon.append( pointPos )
		inverse.append( pointPos + Vector2(8,0).rotated( perp ) )
	
	inverse.reverse()
	polygon.append_array(inverse)
	
	return polygon
