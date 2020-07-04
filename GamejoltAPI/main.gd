tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("GameJoltAPI", "HTTPRequest", preload("API.gd"), preload("gamejolt.png"))
	add_autoload_singleton("GameJoltAPI", "res://addons/GamejoltAPI/API.gd")

func _exit_tree():
	remove_custom_type("GameJoltAPI")
	remove_autoload_singleton("GameJoltAPI")
