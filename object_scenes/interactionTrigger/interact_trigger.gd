extends Area2D

@export var cutsceneScript :CutsceneScript

func runInteractionTrigger() -> void:
	cutsceneScript.runCutscene()
