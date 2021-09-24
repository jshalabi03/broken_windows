extends Node2D

# NOTE ON TESTING:
# read_line will crash if no input is received on stdin!

# NOTE ON IO:
# stdin receives game state from engine,
# stdout sends decisions to engine.
# stderr is reserved for debugging

onready var text_edit: TextEdit = $GUI/VBoxContainer/Controls/TextEdit

var input: String


func _ready():
	next()


func next():
	text_edit.text = ""
	input = $CLInput.read_line()


func _on_Button_pressed():
	printerr("Text entered:\n", text_edit.text, "\n")
	print(input)
	next()
