extends CutsceneScript

func cutscene():
	$"../GrillGuy".play('talk')
	displayDialogue("love me grill...")
	await waitForDialogue()
	displayDialogue("love me family...")
	await waitForDialogue()
	$"../GrillGuy".play('default')
	$"../Family".play("talk")
	displayDialogue("love we dad !!")
	await waitForDialogue()
	$"../GrillGuy".play('talk')
	$"../Family".play("default")
	displayDialogue("love me life...")
	await waitForDialogue()
	$"../GrillGuy".play('default')
	hideDialogue()
