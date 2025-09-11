extends Area2D

@export var levelString:String = ""
@export var pos:Vector2i = Vector2i.ZERO
@export var facing :int = 0


func _on_body_entered(body: Node2D) -> void:
	Global.switchLevel(levelString,pos,facing)
