extends CutsceneScript

@export var textArray :Array[String] = []

func cutscene():
	for text in textArray:
		displayDialogue(text)
		await waitForDialogue()
	hideDialogue()
