extends CutsceneScript

func cutscene():
	if Global.hasTag("vegetaDefeated"):
		displayDialogue("you've bested me... grrr")
		await waitForDialogue()
		hideDialogue()
