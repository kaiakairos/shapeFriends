extends Area2D

@export var levelString:String = ""
@export var pos:Vector2 = Vector2.ZERO
@export var facing :int = 0


func _on_body_entered(body: Node2D) -> void:
	Global.switchLevel(levelString,pos,facing)
