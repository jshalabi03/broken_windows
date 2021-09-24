extends Node
class_name ItemBox

onready var _texture_node : TextureRect = $TextureRect
onready var _text_node : Label = $MarginContainer/ItemInfo

func set_texture(t : Texture) -> void:
	if _texture_node:
		_texture_node.texture = t


func set_text(t : String) -> void:
	if _text_node:
		_text_node.text = t
