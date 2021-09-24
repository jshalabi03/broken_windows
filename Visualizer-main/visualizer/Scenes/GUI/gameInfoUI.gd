extends HBoxContainer

onready var TurnLabel = $GameInfo/HBoxContainer/TurnLabel/MarginContainer/VBoxContainer/Turn
onready var FollowingLabel = $GameInfo/HBoxContainer/TurnLabel/MarginContainer/VBoxContainer/Following

func set_player_info(num, player_info):
	match num:
		1: $Player1Info.set_player_info(player_info)
		2: $Player2Info.set_player_info(player_info)


func set_turn(turn):
	TurnLabel.set_text("Turn: %d" % turn)

func set_following(name):
	FollowingLabel.set_text("Following: %s" % name)

