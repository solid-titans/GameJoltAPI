extends HTTPRequest

export(String) var username   #Use auth_user to instead of changing this
export(String) var user_token #This one too

const BASE_LINK = "https://api.gamejolt.com/api/game/"

var gameID : String     #Look at Project Settings
var privateKey : String #to change this two variables

var request_queue = {
	"counter": 0,  #The number of requests done (used to define the ID's)
	"requests": [] #The request queue
}

signal api_request_completed(id, response_code, data)


#----------------- Functionality functions -----------------#
################ Do not use this functions ################

func _ready():
	connect("request_completed", self, "_on_request_completed")


func _on_request_completed(result, response_code, headers, body):
	var response = request_queue.requests.pop_front() #Get the request metadata
	
	if (request_queue.requests.size() > 0):
		#Get the next request and do a request
		var next_request = request_queue.requests.front()
		request(next_request.url)

	
	emit_signal("api_request_completed", response.id, response_code, JSON.parse(body))

func _make_request(url: String) -> int:
	"""Add the request to the queue and return request id"""
	request_queue.counter += 1
	
	var formated_URL = _url_format(url, {"format": "json"})
	
	formated_URL = _sign_url(formated_URL)
	
	
	if (request_queue.requests.size() == 0):
		request(url)
		
	request_queue.requests.push_back({
		"id": request_queue.counter,
		"url": url
	})
	
	return request_queue.counter


func _url_format (base: String, args: Dictionary = {}) -> String:
	"""Get an url and arguments and return a formated url"""
	
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

#----------------- API functions -----------------#

func auth_user(username: String, user_token: String) -> int:
	"""Login the player with the username and user_token"""
	return _make_request(_url_format(BASE_LINK + "v1" + "/users/auth/", {
		"username":		username,
		"user_token":	user_token
	}))


func add_achieved(trophy_id: int) -> int:
	"""Add a trophy to the player"""
	
	return _make_request(_url_format(
		BASE_LINK + "v1_2" + "/trophies/add-achieved/", { 
			"trophy_id":	String(trophy_id),
			"game_id":		gameID,
			"username":		username,
			"user_token":	user_token
		}
	))
	
func remove_achieved(trophy_id: int ) -> int:
	"""Remove a trophy of the player"""
	return _make_request(_url_format(
		BASE_LINK + "v1_2" + "/trophies/remove-achieved/", {
			"trophy_id": String(trophy_id),
			"game_id":		gameID,
			"username":		username,
			"user_token":	user_token
		})
	)
	
	
func fetch_achieved(trophy_id: int, achieved: bool) -> int:
	"""
		Fetch whatever if a trophy is achived or not
		@params:
			*tropy_id: 
				- The target trophy id 
				- Return all trophyies if null
			*achived:
				- Filters the target trophyes
				- Return all if null
				- Return achived if true
				- Return not achived if false
	"""
	return _make_request(_url_format(BASE_LINK + "v1" + "/trophies/", {
		"trophy_id":	trophy_id,
		"achived":		achieved,
		"game_id":		gameID,
		"username":		username,
		"user_token":	user_token
	}))
	
	
func open_session() -> int:
	"""Open the player session"""
	return _make_request(BASE_LINK + "v1" + "/sessions/open/")
	
