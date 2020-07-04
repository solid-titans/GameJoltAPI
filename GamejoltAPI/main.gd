tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("GameJoltAPI", "HTTPRequest", preload("API.gd"), preload("gamejolt.png"))

func _exit_tree():
	remove_custom_type("GameJoltAPI")
