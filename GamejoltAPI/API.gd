extends Node

var username   #Use _auth_user to instead of changing this
var user_token #This one too

const BASE_LINK = "https://api.gamejolt.com/api/game/"

#Change this on Project Settings
var gameID          : String  = ProjectSettings.get_setting("GameJoltAPI/GameID")
var privateKey      : String  = ProjectSettings.get_setting("GameJoltAPI/PrivateKey")
var parrallel_limit : int     = ProjectSettings.get_setting("GameJoltAPI/ParallelRequestsLimit")
var verbose         : bool    = ProjectSettings.get_setting("GameJoltAPI/Verbose")
var multithread     : bool    = ProjectSettings.get_setting("GameJoltAPI/Multithread")

var requests = {
	"counter" : 0,  #The number of requests done (used to define the ID's)
	"nodes"   : {},   #The request Nodes
	"queue"   : [],   #Requests that are waiting to others to finish
}

# This signal is called every request is completed, try to use the other ones instead.
signal api_request_completed(id, type, response_code, data) 

signal api_auth_user_completed(id, response_code, data)
signal api_open_session_completed(id, response_code, data)
signal api_ping_session_completed(id, response_code, data)
signal api_check_session_completed(id, response_code, data)
signal api_close_session_completed(id, response_code, data)
signal api_add_score_completed(id, response_code, data)
signal api_score_get_rank_completed(id, response_code, data)
signal api_fetch_score_completed(id, response_code, data)
signal api_score_tables_completed(id, response_code, data)

signal api_fetch_achieved_completed(id, response_code, data)
signal api_add_achieved_completed(id, response_code, data)
signal api_remove_achieved_completed(id, response_code, data)
signal api_fetch_user_data_completed(id, response_code, data)

#----------------- API functions -----------------#

func _auth_user(username: String, user_token: String) -> int:
	#Login the player with the username and user_token
	self.username   = username
	self.user_token = user_token
	
	return make_request(url_format(BASE_LINK + "v1" + "/users/auth/", {
		"game_id":      gameID,
		"username":		username,
		"user_token":	user_token
	}), "auth_user")

func _open_session() -> int:
	# Open the player session
	return make_request(url_format(BASE_LINK + "v1" + "/sessions/open/", {
		'game_id'    : gameID,
		'username'   : username,
		'user_token' : user_token
		}), "open_session")

func _ping_session(status: String) -> int:
	# Ping the session
	# Valid values for status: "active" and "idle"
	return make_request(url_format(BASE_LINK + "v1" + "/sessions/ping/", {
		"game_id"    : gameID,
		"username"   : username,
		"user_token" : user_token,
		"status"     : status
	}), "ping_session")

func _check_session() -> int:
	# Check what game the player is current playing
	return make_request(url_format(BASE_LINK + "v1_2" + "/sessions/check/", {
		"game_id"    : gameID,
		"username"   : username,
	}), "check_session")

func _close_session() -> int:
	# Close the current session for the game
	return make_request(url_format(BASE_LINK + "v1_2" + "/sessions/close/", {
		"game_id"    : gameID,
		"username"   : username,
	}), "close_session")

func _add_score(use_players_credentials: bool, guest: String, score: String, sort: int, extra_data: String, table_id: int) -> int:
	# Add a score to the scoreboard
	# Required : 'Score' and 'Sort'!
	# Optional : The players credentials, some extra data you want to store and the table id to store
	# If you choose to not use the players credentials you can choose a name for the player

	var parameters = {
		"game_id"    : gameID,
		"score"      : score,
		"sort"       : sort,
		"extra_data" : extra_data,
		"table_id"   : table_id 
	}
	
	if use_players_credentials: 
		parameters["username"]   = username
		parameters["user_token"] = user_token
	else: 
		parameters["guest"]      = guest

	return make_request(url_format(BASE_LINK + "v1" + "/scores/add/", parameters), "add_score")

func _score_get_rank(table_id: int) -> int:
	# Returns the rank of a particular score on a score table
	
	return make_request(url_format(BASE_LINK + "v1_2" + "/scores/get-rank/", {
		'game_id'    : gameID,
		'username'   : username,
		'user_token' : user_token,
		'table_id'   : table_id
	}), "score_get_rank")

func _fetch_score(use_players_credentials: bool, limit: int, table_id: int, guest: String, better_than: int, worse_than: int) -> int:
	# Return a especific score of your game
	
	var parameters = {
		'game_id'     : gameID,
		'limit'       : limit,
		'table_id'    : table_id,
		'better_than' : better_than,
		'worse_than'  : worse_than
	}
	
	if use_players_credentials:
		parameters['username']   = username
		parameters['user_token'] = user_token
	else:
		parameters['guest']      = guest
	
	return make_request(url_format(BASE_LINK + 'v1_2' + '/scores/', parameters), 'fetch_score')

func _score_tables() -> int:
	# Return the score tables of your game
	
	return make_request(url_format(BASE_LINK + 'v1.0' + '/scores/tables/', {
		'game_id' : gameID
	}), 'score_tables')

func _fetch_achieved(trophy_id: int, achieved: bool) -> int:
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
	
	return make_request(url_format(BASE_LINK + "v1" + "/trophies/", {
		"trophy_id":	trophy_id,
		"achived":		achieved,
		"game_id":		gameID,
		"username":		username,
		"user_token":	user_token
	}), "fetch_achived")

func _add_achieved(trophy_id: int) -> int:
	#Add a trophy to the player
	
	return make_request(url_format(
		BASE_LINK + "v1_2" + "/trophies/add-achieved/", { 
			"game_id"     : gameID,
			"username"    : username,
			"user_token"  : user_token,
			"trophy_id"   : trophy_id
		}), "add_achieved")
	
func _remove_achieved(trophy_id: int) -> int:
	#Remove a trophy of the player
	return make_request(url_format( BASE_LINK + "v1_2" + "/trophies/remove-achieved/", {
			"game_id"    : gameID,
			"username"   : username,
			"user_token" : user_token,
			"trophy_id"  : trophy_id
		}), "remove_achieved")
	

func _fetch_user_data(user_ids: String) -> int:
	# Fetch user data
	var parameters = {"game_id" : gameID, "user_id": user_ids}
	if user_ids == null: parameters["username"] = username

	return make_request(url_format(BASE_LINK + "v1_2" + "/users/", parameters), "fetch_user_data")


#----------------- Functionality functions -----------------#
######################## Do not use! ########################

func add_request_to_list (url: String, type: String, id: int = -1) -> int:
	#Add a request to the queue or parallel list
	if id == -1:
		id = requests.counter
		requests.counter += 1
	
	if parrallel_limit <= 0 or requests.nodes.size() < parrallel_limit:
		#Create a new instace of HTTPRequest for parallelization
		var node = HTTPRequest.new()
		node.use_threads = multithread
		add_child(node)
		node.request(url)
		node.connect("request_completed", self, "on_request_completed", [id])
		print_verbose("New request (ID: " + String(id) + ")!")
		
		requests.nodes[id] = ({
			"url": url,
			"type": type,
			"node": node,
		})
	else:
		#If the limit was reached, add to queue
		requests.queue.push_back({
			"id": id,
			"url": url,
			"type": type,
		})
		print_verbose("Added request to queue")
		
	return id

func on_request_completed(result, response_code, headers, body, id):
	print_verbose("Request (ID = " + String(id) + ") completed with code: " + String(response_code) +
	"(Result = " + String(result) + ")")

	var request_node = requests.nodes.get(id)
	requests.nodes.erase(id)
	request_node.node.disconnect("request_completed", self, "on_request_completed")
	
	emit_signal("api_request_completed", id, request_node.type, response_code, body)
	emit_signal("api_" + request_node.type + "_completed", id, response_code, body)
	request_node.node.queue_free()
	
	if requests.queue.size() > 0: 
		var next = requests.queue.pop_front()
		add_request_to_list(next.url, next.type, next.id)

func make_request(url: String, type: String) -> int:
	#Add the request to the queue and return request id
	
	var formated_URL = url
	if formated_URL.find("format") == -1:
		formated_URL = url_format(url, {"format": "json"})
	
	formated_URL = sign_url(formated_URL)
	print_verbose("Final URL: " + formated_URL)
	
	return add_request_to_list(formated_URL, type)


func url_format (base: String, args: Dictionary = {}) -> String:
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


func sign_url(url: String) -> String:
	var signature = url + privateKey
	signature = signature.sha1_text()
	
	return url_format(url, {"signature": signature})
	
	
func print_verbose(msg):
	if verbose: print("[GameJoltAPI] " + msg)
