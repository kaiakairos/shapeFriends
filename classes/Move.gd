extends Resource
class_name Move

## Name that displays in game
@export var moveDisplayName :String = "Move Name"
## Internal name for enemy code to use
@export var moveID:String = "move"

## How much mana does this move require?
@export var manaCost :int = 0

## 1 - 100. 50 is neutral
@export var speed :int = 50 

@export var moveAnimation :PackedScene

@export_group("Hitbox")
@export_enum("ROTATIONAL","SWAPPING","MOVEABLE","SINGLE") var hitboxMode :int = 0
## If hitbox mode is anything other than "swapping", this array should only have one value
@export var hitboxTextures :Array[Texture2D]
var hitboxes :Array[Array] # used by the move handler to hold the real hitboxes

@export_group("Behavior")
@export var damage :int = 5
@export var armorPierce :int = 0
@export var healing :int = 0
@export_subgroup("Status Effect")
## STATUSNAME: CHANCE TO APPLY...       chance in a percentile
@export var statusToApply :Dictionary[String,int] = {}


func generateHitboxes() -> void:
	match hitboxMode:
		0:
			for i in range(4):
				hitboxes.append( scanHitboxTexture( hitboxTextures[0], i) )
		1:
			for tex in hitboxTextures:
				hitboxes.append( scanHitboxTexture(tex) )
		2:
			hitboxes.append( scanHitboxTexture(hitboxTextures[0]) )
		3:
			hitboxes.append( scanHitboxTexture(hitboxTextures[0]) )

func scanHitboxTexture(texture:Texture2D,rotation:int=0) -> Array[Vector2i]:
	var vectors :Array[Vector2i] = []
	var img :Image = texture.get_image()
	
	for i in range(rotation):
		img.rotate_90(ClockDirection.CLOCKWISE)
	
	for x in range(21):
		for y in range(21):
			var r :float = img.get_pixel(x,y).r
			if r > 0.5: # pixel is white
				vectors.append( Vector2i(x - 10,y - 10) )
	
	return vectors
