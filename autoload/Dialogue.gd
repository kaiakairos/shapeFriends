extends CanvasLayer

var dialogueBox :DialogueBox

func _ready() -> void:
	# create dialogue box
	
	dialogueBox = load("res://dialogue/dialogueBox/dialogue_box.tscn").instantiate()
	changeBoxPosition()
	add_child(dialogueBox)

func displayDialogue(text:String,character:int=0,mood:int=0):
	dialogueBox.displayDialogue(text,character,mood)

func hideDialogue():
	dialogueBox.hide()

func clearbox():
	dialogueBox.clearbox()

func changeBoxPosition(top:bool=false):
	dialogueBox.position.y = int(!top) * 200
