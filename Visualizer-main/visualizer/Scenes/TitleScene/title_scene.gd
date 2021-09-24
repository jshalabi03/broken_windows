extends Control

func _ready():
	if Global.use_js:
		$MarginContainer/Menu/CenterRow/Buttons/QuitButton.visible = false
	
	# Autoplay the next gamelog
	if not Global.gamelog_paths.empty():
		var path: String = Global.gamelog_paths[0]
		
		# Don't know why but this copying to a local var, updating, 
		# and copying back is NECESSARY
		var paths = Global.gamelog_paths
		paths.remove(0)
		Global.gamelog_paths = paths
		
		$FileDialog.emit_signal("file_selected", path)



func _on_StartButton_pressed():
	$FileDialog.popup()


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_FileDialog_gamelog_ready():
	get_tree().change_scene("res://Scenes/Game/Game.tscn")
