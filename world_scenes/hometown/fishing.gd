extends CutsceneScript

func cutscene():
	if !Global.hasTag("hasFishingRod"):
		displayDialogue("the water is swag")
		await waitForDialogue()
		displayDialogue("if only you had a fishing rod")
		await waitForDialogue()
		hideDialogue()
		
		BattleData.startBattle(enemies,messages)
		await BattleData.finishedWithBattle
		
		return
	
	displayDialogue("go fishing?")
	await waitForDialogue()
	hideDialogue()
