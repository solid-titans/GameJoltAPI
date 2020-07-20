tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("GameJoltAPI", "res://addons/GamejoltAPI/API.gd")

	add_custom_project_setting("GameJoltAPI/GameID", "", TYPE_STRING)
	add_custom_project_setting("GameJoltAPI/PrivateKey", "", TYPE_STRING)
	add_custom_project_setting("GameJoltAPI/ParallelRequestsLimit", 50, TYPE_INT)
	add_custom_project_setting("GameJoltAPI/Verbose", false, TYPE_BOOL)
	add_custom_project_setting("GameJoltAPI/Multithread", false, TYPE_BOOL)
	
	var error := ProjectSettings.save()
	if error: push_error("Encountered error %d when saving project settings." % error)

func add_custom_project_setting(name: String, default_value, type: int, hint: int = PROPERTY_HINT_NONE, hint_string: String = "") -> void:

	if ProjectSettings.has_setting(name): return
	ProjectSettings.clear(name)

	var setting_info: Dictionary = {
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string
	}

	ProjectSettings.add_property_info(setting_info)
	ProjectSettings.set_initial_value(name, default_value)
	ProjectSettings.set_setting(name, default_value)

func _exit_tree():
	remove_autoload_singleton("GameJoltAPI")
	ProjectSettings.clear("GameJoltAPI/PrivateKey")
	ProjectSettings.clear("GameJoltAPI/GameID")
	ProjectSettings.clear("GameJoltAPI/ParallelRequestsLimit")
	ProjectSettings.clear("GameJoltAPI/Verbose")
	ProjectSettings.clear("GameJoltAPI/Multithread")
	
	
