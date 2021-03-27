extends Node

var _last_id = -1
var _requests = {}
var session

onready var _game_id 	 : String = ProjectSettings.get_setting("GameJoltAPI/Game/GameID")
onready var _verbose     : bool = bool(ProjectSettings.get_setting("GameJoltAPI/Debug/Verbose"))
onready var _username    : String
onready var _user_token  : String
var session_status = STATUS.OFF


enum STATUS {
	OK,
	STARTING,
	CONNECTION_LOST,
	OFF,
}

signal request_completed(id, result, response_code, headers, parsed_body, node)

func _ready():
	self.connect("request_completed", self, "_on_session_opened")
	
	#
	#
	# Add a callback
	#
	#

func _on_request_completed(id, result, response_code, headers, parsed_body):
	var node = _requests.get(id)
	if node:
		_print_verbose("Request " + str(id) + " completed")
		self.emit_signal("request_completed", id, result, response_code, headers, parsed_body, node)
		self.remove_child(_requests[id])
		_requests.erase(id)
	else:
		printerr("Unable to delete request Node (maybe it's already deleted?)")

func _on_session_opened(id, result, response_code, headers, parsed_body, node):
	if parsed_body.success == true:
		_print_verbose("Session opened!")
		session_status = STATUS.OK
		_game_id = node._data["game_id"]
		_username = node._data["username"]
		_user_token = node._data["user_token"]
	else:
		session_status = STATUS.OFF
		printerr(parsed_body.message)
		

func open_session(username : String, user_token : String):
	var request = GameJoltSessionOpen.new(_game_id, username, user_token)
	self.make_request(request)
	

func make_request(request) -> int:
	"""Create a new request object and add it as a child"""
	_last_id += 1
	_requests[_last_id] = request
	print("Request added (id: " + str(_last_id) + ")")
	add_child(request)
	request.connect("request_completed", self, "_on_request_completed")
	request.request()
	return _last_id
	
	
func _print_verbose(msg):
	if _verbose:
		print(msg)
