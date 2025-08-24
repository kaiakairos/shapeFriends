extends CutsceneScript

func cutscene():
	displayDialogue("hey, you look strong! You wanna fight?")
	await waitForDialogue()
	displayDialogue("Alright, let's go!")
	await waitForDialogue()
	hideDialogue()
	
	BattleData.startBattle(enemies,messages)
	await BattleData.finishedWithBattle
	
	displayDialogue("That was a cool battle!")
	await waitForDialogue()
	displayDialogue("Thanks for training with me!")
	await waitForDialogue()
	hideDialogue()
