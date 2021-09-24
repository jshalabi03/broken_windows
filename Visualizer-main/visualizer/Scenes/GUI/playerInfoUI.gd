extends VBoxContainer
class_name InfoUI

onready var SeedInventory = $Inventory/MarginContainer/VBoxContainer/HBoxContainer/SeedInventory
onready var HarvestedInventory = $Inventory/MarginContainer/VBoxContainer/HBoxContainer/HarvestedInventory
onready var InventoryValue = $Inventory/MarginContainer/VBoxContainer/InventoryValue
onready var Name = $NameContainer/Name
onready var Money = $MoneyContainer/Money
onready var Item = $MarginContainer/AttributeContainer/Item
onready var Upgrade = $MarginContainer/AttributeContainer/Upgrade

var item_keys = Global.Item.keys()
var crop_keys = Global.CropType.keys()
const ItemBox = preload("res://Scenes/GUI/ItemBox.tscn")

var Items = {
	Global.Item.NONE : preload("res://Assets/Inventory/Items/None.png"),
	Global.Item.RAIN_TOTEM : preload("res://Assets/Inventory/Items/Rain Totem.png"),
	Global.Item.FERTILITY_IDOL : preload("res://Assets/Inventory/Items/Fertility Idol.png"),
	Global.Item.PESTICIDE : preload("res://Assets/Inventory/Items/Pesticide.png"),
	Global.Item.SCARECROW : preload("res://Assets/Inventory/Items/Scarecrow.png"),
	Global.Item.DELIVERY_DRONE : preload("res://Assets/Inventory/Items/Delivery Drone.png"),
	Global.Item.COFFEE_THERMOS : preload("res://Assets/Inventory/Items/Coffee Thermos.png"),
}

var Upgrades = {
	Global.Upgrade.NONE: preload("res://Assets/Inventory/Items/None.png"),
	Global.Upgrade.BACKPACK : preload("res://Assets/Inventory/Upgrades/Backpack.png"),
	Global.Upgrade.LOYALTY_CARD : preload("res://Assets/Inventory/Upgrades/Green Grocer Loyalty Card.png"),
	# TODO: why do we have moon shoes????
	Global.Upgrade.LONGER_LEGS: preload("res://Assets/Inventory/Upgrades/Moon Shoes.png"),
	Global.Upgrade.RABBITS_FOOT : preload("res://Assets/Inventory/Upgrades/Rabbit_s Foot.png"),
	Global.Upgrade.SCYTHE : preload("res://Assets/Inventory/Upgrades/Scythe.png"),
	Global.Upgrade.SEED_A_PULT : preload("res://Assets/Inventory/Upgrades/Seed-a-Pult.png"),
	Global.Upgrade.SPYGLASS : preload("res://Assets/Inventory/Upgrades/Spyglass.png"),
}

var Seeds = {
	Global.CropType.NONE : preload("res://Assets/Images/None.png"),
	Global.CropType.CORN : preload("res://Assets/Inventory/Seed Packets/CornPacket.png"),
	Global.CropType.GRAPE : preload("res://Assets/Inventory/Seed Packets/GrapePacket.png"),
	Global.CropType.POTATO : preload("res://Assets/Inventory/Seed Packets/PotatoPacket.png"),
	Global.CropType.JOGAN_FRUIT : preload("res://Assets/Inventory/Seed Packets/JoganPacket.png"),
	Global.CropType.DUCHAM_FRUIT : preload("res://Assets/Inventory/Seed Packets/DuchamPacket.png"),
	Global.CropType.PEANUT : preload("res://Assets/Inventory/Seed Packets/PeanutPacket.png"),
	Global.CropType.QUADROTRITICALE : preload("res://Assets/Inventory/Seed Packets/WheatPacket.png"),
	Global.CropType.GOLDEN_CORN : preload("res://Assets/Inventory/Seed Packets/GoldenPacket.png")
}

var Harvests = {
	Global.CropType.NONE : preload("res://Assets/Images/None.png"),
	Global.CropType.CORN : preload("res://Assets/Inventory/Harvested Crops/CornHarvested.png"),
	Global.CropType.GRAPE : preload("res://Assets/Inventory/Harvested Crops/GrapeHarvested.png"),
	Global.CropType.POTATO : preload("res://Assets/Inventory/Harvested Crops/PotatoHarvested.png"),
	Global.CropType.JOGAN_FRUIT : preload("res://Assets/Inventory/Harvested Crops/JoganHarvested.png"),
	Global.CropType.DUCHAM_FRUIT : preload("res://Assets/Inventory/Harvested Crops/DuchamHarvested.png"),
	Global.CropType.PEANUT : preload("res://Assets/Inventory/Harvested Crops/PeanutHarvested.png"),
	Global.CropType.QUADROTRITICALE : preload("res://Assets/Inventory/Harvested Crops/WheatHarvested.png"),
	Global.CropType.GOLDEN_CORN : preload("res://Assets/Inventory/Harvested Crops/GoldenHarvested.png")
}

func _ready():
	for crop in crop_keys:
		if Global.CropType.get(crop) == Global.CropType.NONE: continue
		
		var seedSlot = ItemBox.instance()
		seedSlot.name = crop
		
		var harvestedSlot = ItemBox.instance()
		harvestedSlot.name = crop
		
		SeedInventory.add_child(seedSlot, true)
		HarvestedInventory.add_child(harvestedSlot, true)
		
		# Set textures of inventory slot
		seedSlot.set_texture(Seeds.get(Global.CropType.get(crop)))
		harvestedSlot.set_texture(Harvests.get(Global.CropType.get(crop)))


func set_player_info(player_info):
	# Fill in Player Name text
	Name.set_text(player_info["name"])
	
	# Fill in Player Money text
	Money.set_text("$ %d" % player_info["money"])
	
	# Fill in Player Item sprite
	Item.texture = Items.get(Global.Item.get(player_info["item"]))
	
	# Fill in Player Upgrade sprite
	Upgrade.texture = Upgrades.get(Global.Upgrade.get(player_info["upgrade"]))
	
	# Fill in Player Inventory boxes
	for item in SeedInventory.get_children():
		if player_info["seedInventory"].keys().has(item.name):
			item.set_text(String(player_info["seedInventory"][item.name]))
	
	for item in HarvestedInventory.get_children():
		if player_info["harvestedInventoryTotals"].keys().has(item.name):
			item.set_text(String(player_info["harvestedInventoryTotals"][item.name]))
	
	# Fill in inventory value
	InventoryValue.text = "Value: $%d" % player_info["inventoryValue"]
