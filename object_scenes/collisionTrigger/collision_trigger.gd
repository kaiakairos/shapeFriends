extends Area2D

@export var cutsceneScript :CutsceneScript
@export var destroySelfTrigger :bool = false

func _on_body_entered(body: Node2D) -> void:
	if cutsceneScript:
		await cutsceneScript.runCutscene()
		if destroySelfTrigger:
			queue_free()
	else:
		printerr("ERROR: COLLISION TRIGGER MISSING SCRIPT " + str(self))
