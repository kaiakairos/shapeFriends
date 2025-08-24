extends Node2D
class_name DialogueBox

var boilTick :float = 0.0

var allowedToSkip:bool = false
var skipDialogue:bool = false

var dialogueFinished:bool = false

signal finishedDialogue
signal finishedAnimation # finished text scroll
func _ready() -> void:
	hide()
	
func _process(delta: float) -> void:
	boilTick += delta
	if boilTick > 0.5:
		$Box.frame = ($Box.frame + 1) % 3
		boilTick = 0.0
	
	if Input.is_action_just_pressed("cancel") and allowedToSkip:
		skipDialogue = true
	
	if Input.is_action_just_pressed("interact") and dialogueFinished:
		emit_signal("finishedDialogue")

func displayDialogue(text:String,character:int=0,mood:int=0):
	
	allowedToSkip = false
	dialogueFinished = false
	var label = setCharacter(character,mood)
	
	# scan text for special characters
	
	label.text = text.replace("+","")
	label.visible_characters = 0
	label.show()
	
	show()
	
	for i in range(text.length()):
		if text[i] == "+":
			await get_tree().create_timer(0.1).timeout
		else:
			label.visible_characters += 1
		
		if skipDialogue:
			label.visible_characters = -1
			skipDialogue = false
			allowedToSkip = false
			break
		
		await get_tree().process_frame
		await get_tree().process_frame
		allowedToSkip = true
	
	allowedToSkip = false
	dialogueFinished = true
	
	emit_signal("finishedAnimation")

func setCharacter(character:int,mood:int) -> Label: # returns which label should be attacked
	$characterLabel.text = ""
	$baseLabel.text = ""
	
	if character == 0: # no character
		$portrait.hide()
		return $baseLabel
	
	# load character sprite
	$portrait.show()
	
	return $characterLabel

func hideDialogue() -> void:
	hide()

func clearbox() -> void:
	$characterLabel.text = ""
	$baseLabel.text = ""
	$portrait.hide()
