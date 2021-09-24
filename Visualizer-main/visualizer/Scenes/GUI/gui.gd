extends CanvasLayer

# Signal interface
signal timeline_changed(value)
signal game_over
signal paused
signal resumed

onready var GameInfo = $Container/HUD/GameInfoUI

onready var timeline: Slider = $Container/HUD/Controls/Timeline
onready var play_button: Button = $Container/HUD/Controls/PlayButton

onready var EscapeMenu = $Container/EscapeMenu


func _ready():
	# This check allows this scene to run independently
	if Global.gamelog.keys().has("states"):
		timeline.max_value = len(Global.gamelog["states"])
	pass


func set_player_info(num, player_info):
	GameInfo.set_player_info(num, player_info)
	EscapeMenu.set_player_info(num, player_info)


func _on_Timeline_value_changed(value):
	emit_signal("timeline_changed", value)


func _on_PlayButton_pressed():
	if play_button.text == "Play":
		play_button.text = "Pause"
		emit_signal("resumed")
	elif play_button.text == "Pause":
		play_button.text = "Play"
		emit_signal("paused")


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if not EscapeMenu.is_visible():
			EscapeMenu.call_deferred("popup_centered")



func game_over():
	if play_button.text == "Pause":
		_on_PlayButton_pressed()
	
	if not EscapeMenu.is_visible():
		EscapeMenu.call_deferred("popup_centered")


func _on_Camera_began_following(num):
	var turn = Global.gamelog["states"][Global.current_turn]
	if num < 0 or num > 1:
		GameInfo.set_following("None")
	elif num == 0:
		GameInfo.set_following(turn["p1"]["name"])
	else:
		GameInfo.set_following(turn["p2"]["name"])
