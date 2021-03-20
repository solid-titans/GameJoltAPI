extends Node

var _last_id = -1
var _requests = {}
var session

onready var _game_id 	: String = ProjectSettings.get_setting("GameJoltAPI/Game/GameID")
onready var _username   : String
onready var _user_token : String
var session_status = STATUS.OFF


enum STATUS {
	OK,
	STARTING,
	CONNECTION_LOST,
	OFF,
}

signal request_completed(id, result, response_code, headers, parsed_body, node)

func _on_request_completed(id, result, response_code, headers, parsed_body):
	var node = _requests.get(id)
	if node:
		self.emit_signal("request_completed", id, result, response_code, headers, parsed_body, node)
		self.remove_child(_requests[id])
		_requests.erase(id)
	else:
		printerr("Unable to delete request Node (maybe it's already deleted?)")

func _on_session_opened(id, result, response_code, headers, parsed_body, node):
	if parsed_body.success == true:
		session_status = STATUS.OK
		_game_id = node._data["game_id"]
		_username = node._data["username"]
		_user_token = node._data["user_token"]
	else:
		session_status = STATUS.OFF
		printerr(parsed_body.message)
		

func open_session(game_id : String, username : String, user_token : String):
	var request = GameJoltSessionOpen.new(game_id, username, user_token)
	request.make_request(request, self, "_on_session_opened")
	

func make_request(request, target: Node, callback: String) -> int:
	"""Create a new request object and add it as a child"""
	_last_id += 1
	_requests[_last_id] = request
	add_child(request)
	request.connect("request_completed", self, "_on_request_completed")
	if target and callback:
		self.connect("request_completed", target, callback)
	request.request()
	return _last_id
	
