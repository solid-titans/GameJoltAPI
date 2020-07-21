tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("GameJoltAPI", "res://addons/GamejoltAPI/API.gd")

	add_custom_project_setting("GameJoltAPI/GameID",                "",    TYPE_STRING)
	add_custom_project_setting("GameJoltAPI/PrivateKey",            "",    TYPE_STRING)
	add_custom_project_setting("GameJoltAPI/ParallelRequestsLimit", 50,    TYPE_INT)
	add_custom_project_setting("GameJoltAPI/Multithread",           false, TYPE_BOOL)
	add_custom_project_setting("GameJoltAPI/Verbose",               false, TYPE_BOOL)
	
	
	var error := ProjectSettings.save()
	if error: push_error("Encountered error %d when saving project settings." % error)
	
	
func get_gj_credentials_from_file() -> Dictionary:
	var directory = Directory.new()
	var path = ".gj-credentials"
	var credentials = {}
	
	if directory.file_exists():
		var file = File.new()
		file.open(path, file.READ)
		
		credentials = {
			"version" : file.get_line(),
			"username": file.get_line(),
			"user_token": file.get_line(),
		}
		file.close()
	
	return credentials
	
		

func add_custom_project_setting(name: String, value, type: int, hint: int = PROPERTY_HINT_NONE, hint_string: String = "") -> void:

	if ProjectSettings.has_setting(name): return
	ProjectSettings.clear(name)

	var setting_info: Dictionary = {
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string
	}

	ProjectSettings.set_setting(name, value)
	ProjectSettings.add_property_info(setting_info)

func _exit_tree():
	ProjectSettings.clear("GameJoltAPI/PrivateKey")
	ProjectSettings.clear("GameJoltAPI/GameID")
	ProjectSettings.clear("GameJoltAPI/ParallelRequestsLimit")
	ProjectSettings.clear("GameJoltAPI/Multithread")
	ProjectSettings.clear("GameJoltAPI/Verbose")
	remove_autoload_singleton("GameJoltAPI")
	
	
