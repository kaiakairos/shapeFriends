extends CutsceneScript


func cutscene():
	
	if Global.hasTag("vegetaDefeated"):
		displayDialogue("Hey you.")
		await waitForDialogue()
		var tween = get_tree().create_tween() # tween vegeta down
		tween.tween_property($"../../Vegeta","position:y",$"../../Player".position.y - 32.0,1.0)
		await tween.finished
		displayDialogue("You already beat me...")
		await waitForDialogue()
		displayDialogue("So I won't bother you...")
		await waitForDialogue()
		hideDialogue()
		return
	
	displayDialogue("H+++e+++y+++ +++y+++o+++u+++.")
	await waitForDialogue()
	var tween = get_tree().create_tween() # tween vegeta down
	tween.tween_property($"../../Vegeta","position:y",$"../../Player".position.y - 32.0,1.0)
	await tween.finished
	Global.addTag("vegetaDefeated")
	displayDialogue("I'm not some faggot like goku.")
	await waitForDialogue()
	displayDialogue("I'm gonna kill you!!")
	await waitForDialogue()
	hideDialogue()
	BattleData.startBattle(enemies,messages)
	await BattleData.finishedWithBattle
	
	hideDialogue()
	
