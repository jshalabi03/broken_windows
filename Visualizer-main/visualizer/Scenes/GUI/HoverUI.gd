extends CanvasLayer

export(NodePath) var Map

const SNAP = Vector2(32, 32)
const OFFSET = Vector2(25,5)
const PLAYERSPRITE_SIZE = Vector2(32, 32)
const ANIM_ENTER = "Enter"
const ANIM_EXIT = "Exit"

onready var Anim = $AnimationPlayer
onready var Box = $Node2D/HBoxContainer

onready var CropInfo = $Node2D/HBoxContainer/CropPanel/MarginContainer/CropInfo
onready var CropInfoBox = $Node2D/HBoxContainer/CropPanel

onready var P1ItemInfo = $Node2D/HBoxContainer/ItemPanel/MarginContainer/VBoxContainer/P1ItemInfo
onready var P2ItemInfo = $Node2D/HBoxContainer/ItemPanel/MarginContainer/VBoxContainer/P2ItemInfo
onready var ItemInfoBox = $Node2D/HBoxContainer/ItemPanel

onready var Positioner = $Node2D

onready var appear_radius = Box.rect_size.x * 1.5

onready var item_names = Global.Item.keys()

var prev_tile_pos := Vector2(0, 0)

var Crops


func _ready():
	Box.hide()
	var map = get_node(Map)
	Crops = map.get_crops_tilemap()


# Checks what the mouse is hovering over to display their info
func select_object():
	var global_pos = (Box.get_global_mouse_position()) # Window position
	var local_pos = Crops.get_local_mouse_position() # Game position
	var tilemap_pos = Crops.world_to_map(local_pos) # Tilemap position
	
	var tile = Global.gamelog["states"][Global.current_turn]["tileMap"]["tiles"]
	
	# returns if clicking off the field
	if tilemap_pos.y >= tile.size() or tilemap_pos.x >= tile[tilemap_pos.y].size(): return
	
	prev_tile_pos = tilemap_pos
	tile = tile[tilemap_pos.y][tilemap_pos.x]
	Positioner.global_position = (global_pos + OFFSET)
	
	var box_length = _update_info(tilemap_pos)
	
	# clamps menu so it doesn't go outside game window
	var box_size = Vector2(max(box_length, 15), Box.rect_size.y)
	var maximum = get_viewport().get_visible_rect().size - box_size - OFFSET
	Positioner.global_position.x = clamp(Positioner.global_position.x, 0, maximum.x)
	Positioner.global_position.y = clamp(Positioner.global_position.y, 0, maximum.y)
	
	if box_length > 0:
		Anim.stop(true)
		Anim.play(ANIM_ENTER)
		Box.show()


func _unhandled_input(event):
	if Input.is_action_just_released("lmb"):
		select_object()
	elif Input.is_action_just_pressed("lmb"):
		Box.hide()
#	elif Box.visible and event is InputEventMouseMotion:
#		if Positioner.global_position.distance_to(event.position) > appear_radius \
#			and Anim.current_animation != ANIM_EXIT and Anim.get_queue().size() < 1:
#			Anim.queue(ANIM_EXIT)


func _on_PanelContainer_resized():
	if !Box: return
	appear_radius = Box.rect_size.x * 1.2


func _update_info(tilemap_pos):
	Box.hide()
	CropInfoBox.hide()
	ItemInfoBox.hide()
	
	var box_length = 0
	
	var tilemap = Global.gamelog["states"][Global.current_turn]["tileMap"]
	if tilemap_pos.x < 0 or tilemap_pos.y > tilemap["mapWidth"] \
			or tilemap_pos.y < 0 or tilemap_pos.y > tilemap["mapHeight"]:
		return box_length
	
	var tile = tilemap["tiles"][tilemap_pos.y][tilemap_pos.x]
	
	# Finds if a crop is selected
	var selected_crop = Crops.get_cellv(tilemap_pos)
	if selected_crop != -1:
		CropInfo.set_name(tile["crop"]["type"].to_lower().capitalize())
		CropInfo.set_stage(tile["crop"]["growthTimer"])
		CropInfo.set_value(tile["crop"]["value"])
		
		box_length += CropInfoBox.rect_size.x
		CropInfoBox.show()
	
	
	# Finds items selected
	var p1_item = Global.Item.get(tile["p1_item"], -1)
	var p2_item = Global.Item.get(tile["p2_item"], -1)
	if p1_item > 0:
		ItemInfoBox.show()
		P1ItemInfo.set_item_name(tile["p1_item"].capitalize(), 1)
		P1ItemInfo.set_description(Global.item_descriptions[p1_item])
		
	if p2_item > 0:
		ItemInfoBox.show()
		P2ItemInfo.set_item_name(tile["p2_item"].capitalize(), 2)
		P2ItemInfo.set_description(Global.item_descriptions[p2_item])
		
	if p1_item > 0 or p2_item > 0: 
		box_length += ItemInfoBox.rect_size.x
	
	if box_length > 0:
		Box.show()
	
	return box_length


func _on_Map_map_updated():
	if not Box.visible: return 
	_update_info(prev_tile_pos)


func _on_Camera_began_following(_num):
	_update_info(Vector2(-1, -1))
