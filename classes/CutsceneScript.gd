extends Node
class_name CutsceneScript

## This script will be filled with useful triggers for cutscenes to work from
## player movement, dialogue boxes, and starting battles should all work from here

@export var enemies :Array[PackedScene] # these just make it a little easier to do battle triggers
@export var messages :Array[String]

# to make a new cutscene, just use cutscene(). it must have awaits in it
func cutscene():
	await get_tree().process_frame


func runCutscene():
	if Global.inCutscene:
		return
	
	Global.inCutscene = true
	await cutscene()
	await get_tree().process_frame # wait one frame in case of interaction
	Global.inCutscene = false

func displayDialogue(text:String,character:int=0,mood:int=0):
	Dialogue.displayDialogue(text,character,mood)

func hideDialogue():
	Dialogue.dialogueBox.hideDialogue()

func waitForDialogue():
	await Dialogue.dialogueBox.finishedDialogue
