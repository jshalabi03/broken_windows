extends TileMap
# Taken and edited from https://github.com/gingerageous/OpenSimplexNoiseTilemapTutorial

const BOUNDS_EXTENSION: Vector2 = Vector2(40, 10)
const GRASS_CAP = Vector2(-0.03, 0.08)
const BUSH_CAP = Vector2(0.2, 0.4)
const TREE_CAP = Vector2(0.4, 1)
const FOREST_TILE_EXTEND = Vector2(2,2)

export(NodePath) var Base_Node
var Base

enum {GRASS = 0, TREE = 1, FOREST = 3, BUSH = 2, FENCE = 8}

# OpenSimplexNoise Texture
onready var noise = load("res://Assets/Images/Background_Tilemap_Noise.tres").noise

onready var Map = get_parent()
onready var tree_types = [TREE, FOREST]
var bounds: Rect2
var edges
var game_area
var fence_bounds


func _ready():
	print("background _ready")
	randomize()
	#print(randi())
	noise.seed = randi()
	
	# 200 iq solution is to wait for map to be set up first
	yield(get_tree(), "idle_frame")
	
	if !Base_Node or !has_node(Base_Node):
		printerr("Base node at path %s does not exist!" % Base_Node)
		return
	
	Base = get_node(Base_Node)
	
	bounds = Map.get_bounds()
	edges = Map.TILE_BOUNDS_EXTEND
	
	game_area = Global.gamelog["states"][0]["tileMap"]
	game_area = Vector2(game_area['mapWidth'],game_area['mapHeight'])
	fence_bounds = Rect2(Vector2(-1,-1), game_area)
	generate_background()
	


func generate_background():
	print("generating background")
	if !Base: return
	
	_create_fence()
	#_generate_forest()
	


# Places fence tiles surrounding the field
func _create_fence():
	print("Creating fence")
	set_cell(fence_bounds.position.x, fence_bounds.size.y, Global.TileType.FENCE_CORNER_S)
	set_cell(fence_bounds.size.x, fence_bounds.size.y, Global.TileType.FENCE_CORNER_S, true)
	set_cell(fence_bounds.position.x, fence_bounds.position.y, Global.TileType.FENCE_CORNER_N)
	set_cell(fence_bounds.size.x, fence_bounds.position.y, Global.TileType.FENCE_CORNER_N, true)
	
	for x in range(fence_bounds.position.x+1, fence_bounds.size.x):
		set_cell(x, fence_bounds.position.y, Global.TileType.FENCE_MID)
		set_cell(x, fence_bounds.size.y, Global.TileType.FENCE_S)

	for y in range(fence_bounds.position.y+1, fence_bounds.size.y):
		set_cell(fence_bounds.position.x, y, Global.TileType.FENCE_SIDE)
		set_cell(fence_bounds.size.x, y, Global.TileType.FENCE_SIDE)
	
	update_bitmask_region()
	

# Uses noise texture to generate a environment around the field
func _generate_forest():
	var map_bounds = Map.get_bounds()
	var bound_pos_map = Base.world_to_map(map_bounds.position)
	var bound_size_map = Base.world_to_map(map_bounds.size + map_bounds.position)
	
		# North section
	for x in range(bound_pos_map.x - BOUNDS_EXTENSION.x, bound_size_map.x + BOUNDS_EXTENSION.x):
		for y in range(bound_pos_map.y - BOUNDS_EXTENSION.y, bound_pos_map.y + Map.TILE_BOUNDS_EXTEND.y - 1):
			var tile = _noise_to_tile(noise.get_noise_2d(x, y))
			if !check_valid_position(x,y, tile): continue
			set_cell(x,y, tile)
			
		
	
		# South section
	for x in range(bound_pos_map.x - BOUNDS_EXTENSION.x, bound_size_map.x + BOUNDS_EXTENSION.x):
		for y in range(bound_size_map.y - Map.TILE_BOUNDS_EXTEND.y + 1, bound_size_map.y + BOUNDS_EXTENSION.y):
			var tile = _noise_to_tile(noise.get_noise_2d(x, y))
			if !check_valid_position(x,y, tile): continue
			set_cell(x,y, tile)
		
	
	# West section
	for x in range(bound_pos_map.x - BOUNDS_EXTENSION.x, bound_pos_map.x + Map.TILE_BOUNDS_EXTEND.x - 1):
		for y in range(bound_pos_map.y + Map.TILE_BOUNDS_EXTEND.y - 1, bound_size_map.y - Map.TILE_BOUNDS_EXTEND.y + 1):
			var tile = _noise_to_tile(noise.get_noise_2d(x, y))
			if !check_valid_position(x,y, tile): continue
			set_cell(x,y, tile)
		
	
	# East section
	for x in range(bound_size_map.x - Map.TILE_BOUNDS_EXTEND.x + 1, bound_size_map.x + BOUNDS_EXTENSION.x):
		for y in range(bound_pos_map.y + Map.TILE_BOUNDS_EXTEND.y - 1, bound_size_map.y - Map.TILE_BOUNDS_EXTEND.y + 1):
			var tile = _noise_to_tile(noise.get_noise_2d(x, y))
			if !check_valid_position(x,y, tile): continue
			set_cell(x,y, tile)
		
	

# Takes a noise value and converts it to a tile
func _noise_to_tile(var value: float):
	
	if value >= GRASS_CAP.x and value <= GRASS_CAP.y:
		return GRASS
	if value >= BUSH_CAP.x and value <= BUSH_CAP.y:
		return BUSH
	if value >= TREE_CAP.x and value <= TREE_CAP.y:
		return tree_types[randi() % tree_types.size()]
	return -1


# Checks if tile overlaps with a bigger tile,
func check_valid_position(x, y, tile):
	var end = 2 if tile == FOREST else 1
	for i in range(x - 1, x + end):
		for j in range(y - 1, y + end):
			if i == x and j == y: continue
			var c = get_cell(i, j)
			if c == FOREST or (c == FENCE and tile == FOREST): 
				return false
	return true
	
