extends Node


const _BASE_URL				:= "https://api.gamejolt.com/api/game/"
onready var _private_key 	: String = ProjectSettings.get_setting("GameJoltAPI/Game/PrivateKey")
onready var GameJoltRequestClass = $"res://addons/GamejoltAPI/lib/GameJoltRequestClass.gd"
var _last_id = -1
var _requests = {}

	
func _on_request_completed(id, result, response_code, headers, parsed_body):
	if _requests.get(id):
		self.remove_child(_requests[id])
		_requests.erase(id)
	else:
		printerr("Unable to delete request Node (maybe it's already deleted?)")


func new_request(uri : String, data := {}, headers := PoolStringArray(),
 method := HTTPClient.METHOD_GET) -> int:
	"""Create a new request object and add it as a child"""
	_last_id += 1
	var r = GameJoltRequestClass.new(_last_id, _private_key, _BASE_URL + uri,
	  data, headers, method)
	_requests[_last_id] = r
	add_child(r)
	r.connect("request_completed", self, "_on_request_completed")
	r.request()
	return _last_id
	
