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
	
func _on_request_completed(result, response_code, headers, parsed_body, id):
	var node = _requests.get(id)
	if node:
		_print_verbose("Request " + str(id) + " completed")
		self.emit_signal("request_completed", id, result, response_code, headers, parsed_body, node)
		self.remove_child(_requests[id])
		_requests.erase(id)
	else:
		printerr("Unable to delete request Node (maybe it's already deleted?)")


func _on_session_opened(id, result, response_code, headers, parsed_body, node):
	
	session_status = STATUS.OFF

	if result != HTTPRequest.RESULT_SUCCESS:
		printerr('Error trying to make a request: error code ', result)
	elif response_code / 100 == 4 or response_code / 100 == 5:
		printerr('Error trying to open a session: Returned error code', response_code)
	elif not parsed_body.result or not parsed_body.result.success:
		printerr('Error trying to open a session: Request body:', parsed_body.result)
	else:
		_print_verbose("Session opened!")
		session_status = STATUS.OK
		_game_id = node._data["game_id"]
		_username = node._data["username"]
		_user_token = node._data["user_token"]
		

func open_session(username : String, user_token : String):
	var request = GameJoltSessionOpen.new(_game_id, username, user_token)
	self.make_request(request)
	

func make_request(request) -> int:
	"""Create a new request object and add it as a child"""
	_last_id += 1
	var id = _last_id
	_requests[id] = request
	print("Request added (id: " + str(id) + ")")
	add_child(request)
	request.connect("request_completed", self, "_on_request_completed", [id])
	request.request()
	return id
	
	
func _print_verbose(msg):
	if _verbose:
		print(msg)
