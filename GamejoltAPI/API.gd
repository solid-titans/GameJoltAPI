extends HTTPRequest

export(String) var username   #Use auth_user to instead of changing this
export(String) var user_token #This one too

const BASE_LINK = "https://api.gamejolt.com/api/game/"

#Change this on Project Settings
var gameID : String       = ProjectSettings.get_setting("GameJoltAPI/GameID")
var privateKey : String   = ProjectSettings.get_setting("GameJoltAPI/PrivateKey")
var parrallel_limit : int = ProjectSettings.get_setting("GameJoltAPI/PrallelRequestsLimit")
var verbose: bool         = ProjectSettings.get_setting("GameJoltAPI/Verbose")

var requests = {
	"counter": 0,  #The number of requests done (used to define the ID's)
	"nodes": {},   #The request Nodes
	"queue": [],   #Requests that are waiting to others to finish
}

signal api_request_completed(id, type, response_code, data)


#----------------- Functionality functions -----------------#
######################## Do not use! ########################

func on_request_completed(result, response_code, headers, body, id):
	_print_verbose("Request (ID = " + id + ") completed with code: " + response_code)
	
	if requests.queue.size() > 0: 
		var next = requests.queue.pop_front()
		_make_request(next.url, next.type)
	
	var request_node = requests.nodes.get(id)
	request_node.node.disconnect("request_completed", self, "on_request_completed")
	
	var parsed_body = JSON.parse(body.get_string_from_utf8())
	emit_signal("api_request_completed", id, request_node.type, response_code, parsed_body)
	emit_signal("api_" + request_node.type, id, response_code, parsed_body)
	request_node.node.queue_free()


func _make_request(url: String, type:="unknown") -> int:
	#Add the request to the queue and return request id
	
	var id = requests.counter
	requests.counter += 1
	
	var formated_URL = _url_format(url, {"format": "json"})
	_print_verbose("Formated URL: " + formated_URL)
	
	formated_URL = _sign_url(formated_URL)
	_print_verbose("Signed URL: " + formated_URL)
	
	if requests.nodes.size() < parrallel_limit:
		#Create a new instace of HTTPRequest and make a request for parallelization
		var node = HTTPRequest.new()
		node.request(url)
		add_child(node)
		node.connect("request_completed", self, "on_request_completed", id)
		_print_verbose("New request (ID: " + id + ")!")
		
		requests.nodes[id] = ({
			"url": url,
			"type": type,
			"node": node,
		})
	else:
		#If the limit was reached, add to queue
		requests.queue.push_back({
			"url": url,
			"type": type,
		})
		_print_verbose("Added request to queue")
	
	return id


func _url_format (base: String, args: Dictionary = {}) -> String:
	#Get an url and arguments and return a formated url
	
	var link = base
	
	if (!base.ends_with("?")):
		if (base.find("?") == -1):
			link += "?"
		else:
			link += "&"
			
	
	for key in args:
		if (args[key]):
			link += String(key).http_escape() + "=" + String(args[key]).http_escape() + "&"
	
	link = link.rstrip("&")
	
	return link


func _sign_url(url: String) -> String:
	var signature = url + privateKey
	signature = signature.sha1_text()
	
	return _url_format(url, {"signature": signature})
	
	
func _print_verbose(msg):
	if verbose: print("[GameJoltAPI] " + msg)

#----------------- API functions -----------------#

func auth_user(username: String, user_token: String) -> int:
	#Login the player with the username and user_token
	
	return _make_request(_url_format(BASE_LINK + "v1" + "/users/auth/", {
		"username":		username,
		"user_token":	user_token
	}))


func add_achieved(trophy_id: int) -> int:
	#Add a trophy to the player
	
	return _make_request(_url_format(
		BASE_LINK + "v1_2" + "/trophies/add-achieved/", { 
			"trophy_id":	String(trophy_id),
			"game_id":		gameID,
			"username":		username,
			"user_token":	user_token
		}
	))
	
func remove_achieved(trophy_id: int) -> int:
	#Remove a trophy of the player
	return _make_request(_url_format(
		BASE_LINK + "v1_2" + "/trophies/remove-achieved/", {
			"trophy_id": String(trophy_id),
			"game_id":		gameID,
			"username":		username,
			"user_token":	user_token
		})
	)
	
	
func fetch_achieved(trophy_id: int, achieved: bool) -> int:
	#	Fetch whatever if a trophy is achived or not
	#	@params:
	#		*tropy_id: 
	#			- The target trophy id 
	#			- Return all trophyies if null
	#		*achived:
	#			- Filters the target trophyes
	#			- Return all if null
	#			- Return achived if true
	#			- Return not achived if false
	
	return _make_request(_url_format(BASE_LINK + "v1" + "/trophies/", {
		"trophy_id":	trophy_id,
		"achived":		achieved,
		"game_id":		gameID,
		"username":		username,
		"user_token":	user_token
	}))
	
	
func open_session() -> int:
	#Open the player session
	return _make_request(BASE_LINK + "v1" + "/sessions/open/")
	
