extends Area2D

@export var cutsceneScript :CutsceneScript
@export var destroySelfTrigger :bool = false

func _on_body_entered(body: Node2D) -> void:
	await cutsceneScript.runCutscene()
	if destroySelfTrigger:
		queue_free()
