extends "res://addons/gut/test.gd"

func before_each():
	pass

func after_each():
	pass

func before_all():
	pass

func after_all():
	pass

func test_json_load():
	var gamelog = JsonTranslator.parse_json("res://Tests/Inputs/gamelog_1.json")
	assert_true(gamelog is Dictionary, "Test gamelog is Dictionary")
	assert_true(JsonTranslator.valid_gamelog(gamelog), "Test gamelog validity")
	
	gamelog = JsonTranslator.parse_json("res://Tests/Inputs/gamelog_2.json")
	assert_true(gamelog is Dictionary, "Test gamelog is Dictionary")
	assert_true(JsonTranslator.valid_gamelog(gamelog), "Test gamelog validity")
