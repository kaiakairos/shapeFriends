extends Area2D

@export var cutsceneScript :CutsceneScript

func runInteractionTrigger() -> void:
	if cutsceneScript:
		cutsceneScript.runCutscene()
	else:
		printerr("ERROR: INTERACTION TRIGGER MISSING SCRIPT " + str(self))
