extends Node2D

export(NodePath) var p1_node
export(NodePath) var p2_node
export(NodePath) var tilemap_node

# Base speed of players in tiles per second
const BASE_SPEED: float = 7.0

# Players to control
var p1: PlayerSprite
var p2: PlayerSprite

# Tilemap for map_to_world translation
var tilemap: TileMap

# Configures player's movement speed
var speed: float = 1 setget change_speed

# Signals when both players are done moving
signal move_completed
var p1_move_flag: bool = false
var p2_move_flag: bool = false


func _ready():
	assert(p1_node and get_node(p1_node) is PlayerSprite)
	assert(p2_node and get_node(p2_node) is PlayerSprite)
	assert(tilemap_node and get_node(tilemap_node) is TileMap)
	
	p1 = get_node(p1_node)
	var _err = p1.connect("move_completed", self, "p1_move_completed")
	p2 = get_node(p2_node)
	_err = p2.connect("move_completed", self, "p2_move_completed")
	tilemap = get_node(tilemap_node)
	
	# Initialize player speed based on cell size
	p1.base_speed = tilemap.cell_size.x * BASE_SPEED
	p2.base_speed = tilemap.cell_size.x * BASE_SPEED


# Move each player to new positions smoothly
func move_smooth(p1_pos: Dictionary, p2_pos: Dictionary):
	var new_world_pos = tilemap.map_to_world(Vector2(p1_pos["x"], p1_pos["y"]))
	p1_move_flag = false
	p1.move_to(new_world_pos)
	
	new_world_pos = tilemap.map_to_world(Vector2(p2_pos["x"], p2_pos["y"]))
	p2_move_flag = false
	p2.move_to(new_world_pos)


# Instantly update positions
func move_instant(p1_pos: Dictionary, p2_pos: Dictionary):
	var p1_new_pos = tilemap.map_to_world(Vector2(p1_pos["x"], p1_pos["y"]))
	var p2_new_pos = tilemap.map_to_world(Vector2(p2_pos["x"], p2_pos["y"]))
	
	p1.next_pos = p1_new_pos
	p2.next_pos = p2_new_pos
	snap_to()


# Stop smooth movement and instantly moves to destination instead
func snap_to():
	for p in [p1, p2]:
		p.tween.remove_all()
		p.playing = false
		var a = p.next_pos - p.position
		var anim_name = p.color + "Idle"
		if abs(a.x) > abs(a.y):
			#p.frame = p.SPRITE_LEFT if a.x < 0 else p.SPRITE_RIGHT
			anim_name += "Left" if a.x < 0 else "Right"
			p.animation = anim_name
		else:
			#p.frame = p.SPRITE_BACK if a.y < 0 else p.SPRITE_FRONT
			anim_name += "Up" if a.y < 0 else "Down"
			p.animation = anim_name
		
		p.position = p.next_pos + p.POSITION_OFFSET
	
	emit_signal("move_completed")


# Don't allow both move_completed functions to run at the same time! 
var move_lock := Mutex.new()


func check_move_complete():
	if p1_move_flag and p2_move_flag:
		p1_move_flag = false
		p2_move_flag = false
		emit_signal("move_completed")


func p1_move_completed():
	while move_lock.try_lock() != OK:
		pass
	
	p1_move_flag = true
	move_lock.unlock()
	check_move_complete()


func p2_move_completed():
	while move_lock.try_lock() != OK:
		pass
	
	p2_move_flag = true
	move_lock.unlock()
	check_move_complete()

# Changes time for players to move
func change_speed(new: float):
	speed = new
	for p in [p1, p2]:
		p.tween.playback_speed = new


func pause():
	for p in [p1, p2]:
		p.tween.stop_all()


func resume():
	for p in [p1, p2]:
		p.tween.resume_all()
