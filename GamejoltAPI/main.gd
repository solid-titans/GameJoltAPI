tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("GameJoltAPI", "res://addons/GamejoltAPI/API.gd")

	#Adding all project settings
	add_custom_project_setting("GameJoltAPI/Game/GameID",                    "",              TYPE_STRING)
	add_custom_project_setting("GameJoltAPI/Game/PrivateKey",                "",              TYPE_STRING)
	add_custom_project_setting("GameJoltAPI/Requests/ParallelRequestsLimit", 50,              TYPE_INT)
	add_custom_project_setting("GameJoltAPI/Requests/Multithread",           false,           TYPE_BOOL)
	add_custom_project_setting("GameJoltAPI/Debug/Verbose",                  false,           TYPE_BOOL)
	
	
	#Saving settings
	var error := ProjectSettings.save()
	if error: push_error("Encountered error %d when saving project settings." % error)
	

func add_custom_project_setting(name: String, value, type: int, hint: int = PROPERTY_HINT_NONE, hint_string: String = "") -> void:
	#Add a setting to Project Settings

	if ProjectSettings.has_setting(name): return
	ProjectSettings.clear(name)

	var setting_info: Dictionary = {
		"name"        : name,
		"type"        : type,
		"hint"        : hint,
		"hint_string" : hint_string
	}

	ProjectSettings.set_setting(name, value)
	ProjectSettings.add_property_info(setting_info)

func _exit_tree():

	#Clear all Project Settings
	ProjectSettings.clear("GameJoltAPI/Game/GameID")
	ProjectSettings.clear("GameJoltAPI/Game/PrivateKey")
	ProjectSettings.clear("GameJoltAPI/Requests/ParallelRequestsLimit")
	ProjectSettings.clear("GameJoltAPI/Requests/Multithread")
	ProjectSettings.clear("GameJoltAPI/Debug/Verbose")

	remove_autoload_singleton("GameJoltAPI")
	
	
