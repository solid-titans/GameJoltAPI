extends Node

var _last_id = -1
var _requests = {}
var session

const PING_IDLE_TIME = 30
const PING_CONNECTING_TIME = 5


onready var _game_id 	 : String = ProjectSettings.get_setting("GameJoltAPI/Game/GameID")
onready var _verbose     : bool = bool(ProjectSettings.get_setting("GameJoltAPI/Debug/Verbose"))
onready var _username    : String
onready var _user_token  : String
onready var timer        := Timer.new()
var session_status = STATUS.OFF

signal status_changed(new_status)

enum STATUS {
	OK,
	STARTING,
	CONNECTION_LOST,
	OFF,
}

signal request_completed(id, result, response_code, headers, parsed_body, node)


func _ready():
	timer.autostart = true
	add_child(timer)
	

func _on_request_completed(result, response_code, headers, parsed_body, id):
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr('Error trying to make a request: error code ', result)
	
	var node = _requests.get(id)
	if node:
		_print_verbose("Request " + str(id) + " completed")
		self.emit_signal("request_completed", result, response_code, headers, parsed_body, id, node)
		self.remove_child(_requests[id])
		_requests.erase(id)
	else:
		printerr("Unable to delete request Node (maybe it's already deleted?)")


func _change_status(new_status):
	emit_signal("status_changed", new_status)
	session_status = new_status
	
	match new_status:
		STATUS.OK:
			timer.start(PING_IDLE_TIME)
			_ping()
		STATUS.CONNECTION_LOST:
			timer.start(PING_CONNECTING_TIME)
			_ping()

			
func _on_ping(result, response_code, _headers, parsed_body):
	if result != HTTPRequest.RESULT_SUCCESS:
		_change_status(STATUS.CONNECTION_LOST)
	elif response_code / 100 == 4 or response_code / 100 == 5:
		printerr('Error trying to open a session: Returned error code', response_code)
		_change_status(STATUS.CONNECTION_LOST)
	elif not parsed_body.result or parsed_body.result.response.success == 'false':
		printerr('Error trying to open a session: Request body:', parsed_body.result)
		_change_status(STATUS.CONNECTION_LOST)
	else:
		timer.start(PING_IDLE_TIME)


func _on_session_opened(_result, response_code, _headers, parsed_body, node):
	if response_code / 100 == 4 or response_code / 100 == 5:
		_change_status(STATUS.OFF)
		printerr('Error trying to open a session: Returned error code', response_code)
	elif not parsed_body.result or parsed_body.result.response.success == 'false':
		_change_status(STATUS.OFF)
		printerr('Error trying to open a session: Request body:', parsed_body.result)
	else:
		_print_verbose("Session opened!")
		_change_status(STATUS.OK)
		_game_id = node._data["game_id"]
		_username = node._data["username"]
		_user_token = node._data["user_token"]
		


func open_session(username : String, user_token : String):
	var request = GameJoltSessionOpen.new(_game_id, username, user_token)
	request.connect("request_completed", self, '_on_session_opened', [request])
	self.make_request(request)


func _ping():
	var request = GameJoltSessionPing.new(_game_id, _username, _user_token)
	request.connect("request_completed", self, '_on_ping')
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
