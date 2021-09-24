extends PopupPanel

onready var p1_label = $MarginContainer/VBoxContainer/Scoreboard/CenterContainer/ScoreContainer/Player1/Label
onready var p2_label = $MarginContainer/VBoxContainer/Scoreboard/CenterContainer/ScoreContainer/Player2/Label

func _ready():
	if Global.use_js:
		$MarginContainer/VBoxContainer/ExitToDesktop.visible = false


func set_player_info(num:int, player:Dictionary):
	var label = null
	if num == 1:
		label = p1_label
	elif num == 2:
		label = p2_label
		
	if label != null:
		label.text = "%s: $%d" % [player["name"], player["money"]]


func _on_ExitToTitle_pressed():
	get_tree().change_scene("res://Scenes/TitleScene/TitleScene.tscn")


func _on_ExitToDesktop_pressed():
	get_tree().quit()
