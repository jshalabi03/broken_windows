extends Node2D

# Time in seconds between turn animations
const TURN_SEPARATOR: float = 0.5

var paused: bool = false

var cam_bounds: Rect2
onready var Map = $Map
onready var GUI = $GUI
onready var camera = $Camera

# Internal signals
signal paused
signal resumed


func _ready():
	update_state(0, true)
	camera.refresh_bounds()
	camera.center()
	camera.players = Map.get_players_array()
	camera.follow_player(0)


# Using _input because we specifically want to pause specifically when the
# mouse down was consumed by the GUI (when user is scrubbing through timeline).
# This also pauses on camera dragging, but that's not specifically necessary
var pause_cache: bool
func _input(event: InputEvent):
	if event.is_action_pressed("cam_drag"):
		pause_cache = paused
		paused = true
		emit_signal("paused")
	elif event.is_action_released("cam_drag"):
		paused = pause_cache
		if !paused:
			emit_signal("resumed")


func update_state(value: int, instant_update: bool = false):
	if value < len(Global.gamelog["states"]):
		Global.current_turn = value
		
		# Update Map
		Map.update_state(value, instant_update)
		
		# Update GUI
		GUI.set_player_info(1, Global.gamelog["states"][value]["p1"])
		GUI.set_player_info(2, Global.gamelog["states"][value]["p2"])
		
		# TODO: Should I use the GameState["turn"]?
		GUI.GameInfo.set_turn(value + 1)
	else:
		game_over()


# Timeline was manipulated by the user
func _on_GUI_timeline_changed(value):
	update_state(value, true)


func game_over():
	GUI.game_over()
	if not Global.gamelog_paths.empty():
		# Switch back to TitleScene for autoplay
		yield(get_tree().create_timer(5), "timeout")
		get_tree().change_scene("res://Scenes/TitleScene/TitleScene.tscn")



# Only allow one "move_completed" to pend a resume at a time
var pause_locked: bool = false
func _on_Map_move_completed():
	# Check pause state before and after any yields
	if paused:
		if !pause_locked:
			pause_locked = true
			yield(self, "resumed")
			pause_locked = false
		else:
			# There is already a move_completed pending a resume, so quit
			return
	
	yield(get_tree().create_timer(TURN_SEPARATOR), "timeout")
	
	# Check pause state before and after any yields
	if paused:
		if !pause_locked:
			pause_locked = true
			yield(self, "resumed")
			pause_locked = false
		else:
			# There is already a move_completed pending a resume, so quit
			return
	
	var new_val = GUI.timeline.value + 1
	
	# timeline_changed signal only applies for manual manipulations
	GUI.disconnect("timeline_changed", self, "_on_GUI_timeline_changed")
	GUI.timeline.value = new_val
	GUI.connect("timeline_changed", self, "_on_GUI_timeline_changed")
	
	update_state(new_val)


func _on_GUI_paused():
	paused = true
	emit_signal("paused")


func _on_GUI_resumed():
	paused = false
	emit_signal("resumed")
