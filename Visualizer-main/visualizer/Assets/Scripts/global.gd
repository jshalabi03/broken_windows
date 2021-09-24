# Auto-loaded script for global variables and communication specification
extends Node

# gamelog used to udpate visualization
var gamelog: Dictionary
var current_turn: int

# File paths
var gamelog_paths: PoolStringArray

# HTML5/JS detection
onready var use_js = OS.get_name() == "HTML5" and OS.has_feature('JavaScript')

### Enum Types ###

enum PlayerEndState {
	WON,
	LOST,
	TIED,
	ERROR,
}

# Values correspond to TileSet index
enum TileType {
	GRASS = -1,
	GREEN_GROCER = 2,
	ARID = 6,
	SOIL = 6,
	F_BAND_OUTER = 5,
	F_BAND_MID = 4,
	F_BAND_INNER = 3,
	FENCE_CORNER_N = 8,
	FENCE_MID = 9,
	FENCE_CORNER_S = 10,
	FENCE_SIDE = 11,
	FENCE_S = 12,
}


enum CropType {
	NONE = -1,
	CORN,
	GRAPE,
	POTATO,
	JOGAN_FRUIT,
	PEANUT,
	QUADROTRITICALE,
	DUCHAM_FRUIT,
	GOLDEN_CORN,
}

enum Item {
	NONE = -1,
	RAIN_TOTEM,
	FERTILITY_IDOL = 0,
	PESTICIDE = 1,
	SCARECROW = 2,
	DELIVERY_DRONE,
	COFFEE_THERMOS,
	GREEN_GROCER = 3,
}

enum Upgrade {
	NONE,
	BACKPACK,
	LOYALTY_CARD,
	MOON_SHOES,
	RABBITS_FOOT,
	SCYTHE,
	SEED_A_PULT,
	SPYGLASS,
	LONGER_LEGS,
}

var item_descriptions = {
	Item.NONE : "",
	Item.RAIN_TOTEM : "Causes each crop in a 5x5 square centered on the farmer’s position to grow up to three times this turn only.",
	Item.FERTILITY_IDOL : "Doubles the fertility of all tiles within radius 2 for the next growth step.",
	Item.PESTICIDE : "Decrease the current value of all crops within 1 radius by 20%.",
	Item.SCARECROW : "Protects tiles within radius 2 from harvest or planting by the opponent.(5x5)",
	Item.DELIVERY_DRONE : "Allows the farmer to buy and sell crops and seeds from anywhere on the farm for one turn.",
	Item.COFFEE_THERMOS : "Triples the farmer’s MAX_MOVEMENT for the next turn",
}

var crop_prices = {
	CropType.NONE : 0,
	CropType.CORN : 5,
	CropType.GRAPE : 15,
	CropType.POTATO : 5,
	CropType.JOGAN_FRUIT : 20,
	CropType.PEANUT : 5,
	CropType.QUADROTRITICALE : 30,
	CropType.DUCHAM_FRUIT : 100,
	CropType.GOLDEN_CORN : 1000,
}

func _ready():
	set_process(false)


### Verification functions ###

var gamelog_states: Array
var progress_increment: float
var progress_text: String setget set_progress_text
var current_progress: float setget set_current_progress
signal progress_changed
signal progress_text_changed
signal verify_gamelog_start
signal gamelog_check_completed
signal gamelog_check_failed

# Changes recorded progression of verification
func set_current_progress(new: float):
	current_progress = new
	emit_signal("progress_changed", new)


# Changes text explaining current step in verifictation
func set_progress_text(new: String):
	progress_text = new
	emit_signal("progress_text_changed", new)


# Checks a game state every frame
func _process(_delta):
	#var t = OS.get_ticks_msec()
	
	# Each iteration take 9-13 msec
	for _i in range(3):
		if gamelog_states.empty():
			emit_signal("gamelog_check_completed")
			set_progress_text("Verification complete")
			set_process(false)
			return
		
		var state = gamelog_states.pop_front()
		if not valid_game_state(state):
			emit_signal("gamelog_check_failed")
			set_progress_text("Invalid gamelog")
			set_process(false)
			return
		
		set_current_progress(current_progress + progress_increment)
	#print(OS.get_ticks_msec() - t)


func valid_gamelog(_gamelog: Dictionary):
	#emit_signal("verify_gamelog_start")
	
	if not valid_keys(_gamelog) or not valid_end_states(_gamelog):
		emit_signal("gamelog_check_failed")
		return
	
	gamelog = _gamelog
	gamelog_states = gamelog["states"].duplicate(false)
	set_progress_text("Verifying game log...")
	progress_increment = 1.0 / gamelog_states.size()
	
	set_process(true)
	


func valid_keys(_gamelog: Dictionary) -> bool:
	set_progress_text("Verifying Keys...")
	
	var gamelog_keys = ["states", "p1_status", "p2_status"]
	for key in gamelog_keys:
		if not _gamelog.keys().has(key):
			printerr("Gamelog doesn't contain key: ", key)
			set_progress_text("File Error: Invalid keys")
			return false
	return true


func valid_end_states(_gamelog: Dictionary) -> bool:
	set_progress_text("Verifying Player End States...")
	
	if PlayerEndState.get(_gamelog["p1_status"]) == null:
		printerr("Invalid PlayerEndState for p1")
		set_progress_text("File Error: Invalid PlayerEndState for p1")
		return false
	
	if PlayerEndState.get(_gamelog["p2_status"]) == null:
		printerr("Invalid PlayerEndState for p2")
		set_progress_text("File Error: Invalid PlayerEndState for p2")
		return false
	
	return true


func valid_game_state(state: Dictionary) -> bool:
	var keys = ["p1", "p2", "tileMap"]
	for key in keys:
		if not state.keys().has(key):
			printerr("GameState did not contain key: ", key)
			return false
	
	if not valid_tile_map(state["tileMap"]):
		return false
	
	if not valid_player(state["p1"], state["tileMap"]):
		return false
	
	if not valid_player(state["p2"], state["tileMap"]):
		return false
	
	return true


func valid_tile_map(tile_map: Dictionary) -> bool:
	var keys = ["mapHeight", "mapWidth", "tiles"]
	for key in keys:
		if not tile_map.keys().has(key):
			printerr("TileMap did not contain key: ", key)
			return false
	
	if len(tile_map["tiles"]) != tile_map["mapHeight"]:
		printerr("TileMap had incorrect number of rows")
		return false
	
	for row in tile_map["tiles"]:
		if len(row) != tile_map["mapWidth"]:
			print("TileMap had incorrect number of columns")
			return false
		for tile in row:
			if not valid_tile(tile):
				return false
	
	return true


func valid_tile(tile: Dictionary) -> bool:
	var keys = ["type", "crop", "p1_item", "p2_item"]
	for key in keys:
		if not tile.keys().has(key):
			printerr("Tile did not have key: ", key)
			return false
	
	if TileType.get(tile["type"]) == null:
		printerr("Invalid TileType: ", tile["type"])
		return false
	
	if not valid_crop(tile["crop"]):
		return false
	
	if Item.get(tile["p1_item"]) == null:
		printerr("Invalid p1_item: ", tile["p1_item"])
		return false
	
	if Item.get(tile["p2_item"]) == null:
		printerr("Invalid p2_item: ", tile["p2_item"])
		return false
	
	return true


func valid_crop(crop: Dictionary) -> bool:
	var keys = ["type", "growthTimer", "value"]
	for key in keys:
		if not crop.keys().has(key):
			printerr("Crop did not contain key: ", key)
			return false
	
	if CropType.get(crop["type"]) == null:
		printerr("Invalid crop type: ", crop["type"])
		return false
	
	if not is_int(crop["growthTimer"]):
		printerr("Invalid growthTimer: ", crop["growthTimer"])
		return false
	
	if typeof(crop["value"]) != TYPE_REAL:
		printerr("Invalid crop value: ", crop["value"])
		return false
	
	return true


func valid_player(player: Dictionary, tilemap: Dictionary) -> bool:
	var keys = ["name", "position", "item", "upgrade", "money", 
				"seedInventory", "harvestedInventory"]
	for key in keys:
		if not player.keys().has(key):
			printerr("Player missing key: ", key)
			return false
	
	if typeof(player["money"]) != TYPE_REAL:
		printerr("Player money must be a number")
		return false
	
	if Item.get(player["item"]) == null:
		printerr("Invalid player item: ", player["item"])
		return false
	
	if not valid_position(player["position"], tilemap):
		return false
	
	if Upgrade.get(player["upgrade"]) == null:
		printerr("Invalid player upgrade: ", player["upgrade"])
		return false
	
	# Validate seed inventory
	# Because of pass-by-reference, we can add some aggregate data here
	player["harvestedInventoryTotals"] = Dictionary()
	player["inventoryValue"] = 0
	for key in CropType.keys():
		player["harvestedInventoryTotals"][key] = 0
		if not player["seedInventory"].keys().has(key):
			printerr("Player seedInventory missing key: %s" % key)
			return false
	
	# Validate harversted inventory and collect aggregates
	for crop in player["harvestedInventory"]:
		player["inventoryValue"] += crop["value"]
		if not valid_crop(crop):
			printerr("Invalid crop in player harvestedInventory: %s" % crop)
			return false
		
		player["harvestedInventoryTotals"][crop["type"]] += 1 
	
	return true


func valid_position(pos: Dictionary, tilemap: Dictionary) -> bool:
	if not (pos.keys().has("x") and pos.keys().has("y")):
		printerr("Invalid position keys")
		return false
	if pos["x"] < 0 or pos["x"] >= tilemap["mapWidth"]:
		printerr("Position x out of bounds: ", pos["x"])
		return false
	if pos["y"] < 0 or pos["y"] >= tilemap["mapHeight"]:
		printerr("Position y out of bounds: ", pos["y"])
		return false
	
	return true


func is_int(value):
	# JSON parsing will always interpret numbers as floats/reals
	if typeof(value) != TYPE_REAL or int(value) != value:
		return false
	return true
