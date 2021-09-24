extends Node2D

func _ready():
	var time = OS.get_datetime()
	var path = "res://Scenes/MapEditor/maps/" + \
			String(time.month)+"-"+String(time.day)+"-"+ \
			String(time.hour)+"-"+String(time.minute)+"-"+String(time.second)+ \
			".json"
	
	# Save map
	var tilemap: Dictionary
	var size = $Base.get_used_rect().size
	
	tilemap["mapWidth"] = size.x
	tilemap["mapHeight"] = size.y
	tilemap["tiles"] = []
	tilemap["tiles"].resize(size.y)
	for y in range(size.y):
		tilemap["tiles"][y] = []
		tilemap["tiles"][y].resize(size.x)
	
	for pos in $Base.get_used_cells():
		tilemap["tiles"][pos.y][pos.x] = $Base.get_cellv(pos)
	
	# Save into gamelog
	var gamelog: Dictionary
	gamelog["tileMap"] = tilemap
	gamelog["playerNames"] = ["Player 1", "Player 2"]
	gamelog["states"] = []
	gamelog["initPlayersPos"] = [{"x": 0, "y": 0}, {"x": 0, "y": 0}]
	
	var p1 = $Characters.tile_set.find_tile_by_name("Player 1")
	var p2 = $Characters.tile_set.find_tile_by_name("Player 2")
	for pos in $Characters.get_used_cells():
		if p1 == $Characters.get_cellv(pos):
			gamelog["initPlayersPos"][0] = {"x": pos.x, "y": pos.y}
		if p2 == $Characters.get_cellv(pos):
			gamelog["initPlayersPos"][1] = {"x": pos.x, "y": pos.y}
	
	save_dict(gamelog, path)
	get_tree().quit()


func save_dict(data: Dictionary, path: String):
	var file = File.new()
	file.open(path, file.WRITE)
	file.store_string(JSON.print(data))
	file.close()
