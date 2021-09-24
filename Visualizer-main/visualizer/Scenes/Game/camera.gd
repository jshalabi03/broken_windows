extends Camera2D

# Adapted from https://www.braindead.bzh/entry/godot-interactive-camera2d

export var MAX_ZOOM_LEVEL = 0.1
export var MIN_ZOOM_LEVEL = 1.25
export var ZOOM_INCREMENT = 0.1

signal moved
signal zoomed
signal began_following(num)

var _current_zoom_level = 1
var _drag = false
var tilemap_bounds: Rect2
var bg_texture_scale: float = 0.015
var initial_scale

onready var map: Node = get_node("../Map")
onready var Background = $Background

var following: Node = null
var following_player: int = -1
var players = [] # Set by Game


func _ready():
	resize_bg()
	Background.material.set_shader_param("global_transform", Background.get_global_transform())
	get_viewport().connect("size_changed",self,"resize_bg")


func follow_player(num: int):
	if num < 0:
		following = null
		following_player = -1
	else:
		following = players[num % 2]
		following_player = num % 2
	emit_signal("began_following", following_player)


func _refresh_background():
	# Changes params in background grass shader to work around 
	# lack of world vertexes in shader language
	Background.position = self.offset
	Background.material.set_shader_param("global_transform", Background.get_global_transform())


func center():
	var tile_center = tilemap_bounds.position + tilemap_bounds.size / 2
	_center_on_position(Vector2(tile_center.x, 150))


func _center_on_position(pos: Vector2):
	set_offset(pos - get_viewport_rect().size / 2)
	_refresh_background()


# Changes scale of grass background in uniform with screen size
func resize_bg():
	#var m = max(get_viewport_rect().size.x, get_viewport_rect().size.y)
	Background.scale = get_viewport_rect().size / 24
	if !initial_scale: initial_scale = Background.scale
	var s = bg_texture_scale * (Background.scale / initial_scale)
	Background.material.set_shader_param("texture_scale", s)


func refresh_bounds():
	tilemap_bounds = map.get_bounds()


# Use _unhandled_input so that we don't move camera if mouse-down is on GUI
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("cam_drag"):
		_drag = true
	elif event.is_action_released("cam_drag"):
		_drag = false
	elif event.is_action_pressed("cam_zoom_in"):
		_update_zoom(-ZOOM_INCREMENT, get_local_mouse_position())
	elif event.is_action_pressed("cam_zoom_out"):
		_update_zoom(ZOOM_INCREMENT, get_local_mouse_position())
	elif event is InputEventMouseMotion && _drag:
		follow_player(-1)
		set_offset(get_offset() - event.relative * _current_zoom_level)
		_constrain_view()
		emit_signal("moved")
	elif event.is_action_released("ui_focus_next"):
		follow_player((following_player + 1) % 2)


func _update_zoom(incr: float, zoom_anchor: Vector2):
	var old_zoom = _current_zoom_level
	
	_current_zoom_level = clamp(_current_zoom_level + incr, MAX_ZOOM_LEVEL, MIN_ZOOM_LEVEL)

	if old_zoom == _current_zoom_level:
		return
	
	var zoom_center = zoom_anchor - get_offset()
	var ratio = 1-_current_zoom_level/old_zoom
	
	set_offset(get_offset() + zoom_center*ratio)
	set_zoom(Vector2(_current_zoom_level, _current_zoom_level))
	_constrain_view()
	
	emit_signal("zoomed")


# Limits camera so that it is impossible to have just one of the two opposing
# edges of the tilemap off the screen. To be called after movement or zooming
func _constrain_view():
	var _map: Rect2 = Rect2( \
			tilemap_bounds.position - get_offset(), tilemap_bounds.size)
	var view: Rect2 = Rect2(get_viewport_rect().position, \
			get_viewport_rect().size * _current_zoom_level)
	
	# If just one of two opposite boundaries is out of view, 
	# move the camera the shortest distance so one boundary is on the edge
	if _map.end.x > view.end.x and _map.position.x >= view.position.x \
			or _map.position.x < view.position.x and _map.end.x <= view.end.x:
		if abs(_map.end.x - view.end.x) < abs(_map.position.x - view.position.x):
			self.offset.x +=  _map.end.x - view.end.x
		else:
			self.offset.x += _map.position.x - view.position.x
	
	if _map.end.y > view.end.y and _map.position.y >= view.position.y \
			or _map.position.y < view.position.y and _map.end.y <= view.end.y:
		if abs(_map.end.y - view.end.y) < abs(_map.position.y - view.position.y):
			self.offset.y +=  _map.end.y - view.end.y
		else:
			self.offset.y += _map.position.y - view.position.y
	
	_refresh_background()


func _process(_delta):
	if following == null: return
	_center_on_position(following.global_position)
