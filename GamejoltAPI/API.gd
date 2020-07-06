extends HTTPRequest

export(String) var username
export(String) var user_token

const base_link = "https://api.gamejolt.com/api/game/"
var gameID : String
var privateKey : String

func _ready():
	connect("request_completed", self, "_on_request_completed")


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	print("Request completed! (Response code = %d)" % response_code)


func request(url: String, custom_headers:=PoolStringArray(), ssl_validate_domain:=true, method:=0, request_data:=""):
	
	assert(username, "Username is null")
	assert(user_token, "User token is null")
	assert(ProjectSettings.has_setting("GameJoltAPI/GameID"), "Could not find GameID setting")
	assert(ProjectSettings.has_setting("GameJoltAPI/PrivateKey"), "Could not find PrivateKey setting")
	
	privateKey = ProjectSettings.get_setting("GameJoltAPI/PrivateKey")
	gameID = ProjectSettings.get_setting("GameJoltAPI/GameID")
		
	
	var formated_URL = url_format(url, {
		"game_id":		gameID,
		"username":		username,
		"user_token":	user_token
	})
	
	formated_URL = sign_url(formated_URL)
	
	print("Making request to GameJolt!...")
	return .request(formated_URL, custom_headers, ssl_validate_domain, method, request_data)


func url_format (base: String, args: Dictionary = {}) -> String:
	
	var link = base
	
	if (!base.ends_with("?")):
		if (base.find("?") == -1):
			link += "?"
		else:
			link += "&"
			
	
	for key in args:
		if (args[key]):
			link += String(key).strip_edges().http_escape() + "=" + String(args[key]).strip_edges().http_escape() + "&"
	
	link = link.rstrip("&")
	
	return link

func sign_url(url: String) -> String:
	var signature = url + privateKey
	signature = signature.sha1_text()
	
	return url_format(url, {"signature": signature})
	
	
func login(username: String, user_token: String):
	self.username = username
	self.user_token = user_token
	
	return auth_user()

func auth_user():
	return request(base_link + "v1" + "/users/auth/")
	
func add_achieved(trophy_id):
	return request(url_format(
		base_link + "v1_2" + "/trophies/add-achieved/", { "trophy_id": String(trophy_id) }
	))
	
func remove_achieved(trophy_id):
	return request(url_format(
		base_link + "v1_2" + "/trophies/remove-achieved/", { "trophy_id": String(trophy_id) }
	))
	
	
func fetch_achieved(trophy_id=null, achieved=null):
	var parameters = {}
	if (trophy_id): parameters["trophy_id"] = trophy_id
	if (achieved): parameters["achived"] = achieved
	
	return request(url_format(base_link + "v1" + "/trophies/", parameters))
	
	
func open_session():
	return request(base_link + "v1" + "/sessions/open/")
	
