extends HTTPRequest

export(String) var username
export(String) var user_token

const base_link = "https://api.gamejolt.com/api/game/"
var gameID : String
var privateKey : String

func _ready():
	connect("request_completed", self, "_on_request_completed")
	
	
func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	print("Request completed (Response code = %d)!" % response_code)


func request(url: String, custom_headers:=PoolStringArray(), ssl_validate_domain:=true, method:=0, request_data:=""):
	
	
	privateKey = ProjectSettings.get_setting("GameJoltAPI/PrivateKey")
	gameID = ProjectSettings.get_setting("GameJoltAPI/GameID")
	
	var formated_URL = url_format(url, {
		"game_id":		gameID,
		"username":		username,
		"user_token":	user_token
	})
	
	if (privateKey):
		formated_URL = sign_url(formated_URL)
	
	print("Making request to GameJolt!...")
	print(formated_URL)
	.request(formated_URL, custom_headers, ssl_validate_domain, method, request_data)


func auth_user():
	request(base_link + "v1" + "/users/auth/")
	
func add_achieved(trophy_id):
	request(url_format(
		base_link + "v1_2" + "/trophies/add-achieved/", { "trophy_id": String(trophy_id) }
	))
	
func remove_achieved(trophy_id):
	request(url_format(
		base_link + "v1_2" + "/trophies/remove-achieved/", { "trophy_id": String(trophy_id) }
	))
	
	
func fetch_achieved(trophy_id=null, achieved=null):
	var parameters = {}
	if (trophy_id): parameters["trophy_id"] = trophy_id
	if (achieved): parameters["achived"] = achieved
	
	request(url_format(base_link + "v1" + "/trophies/", parameters))
	
	
func open_session():
	request(base_link + "v1" + "/sessions/open/")
	
func url_format (base: String, args: Dictionary = {}) -> String:
	
	var link = base
	
	if (!base.ends_with("?")):
		if (base.find("?")):
			link += "&"
		else:
			link += "?"
			
	
	for key in args:
		if (args[key]):
			link += String(key).strip_edges().http_escape() + "=" + String(args[key]).strip_edges().http_escape() + "&"
	
	link = link.rstrip("&")
	
	return link

func sign_url(url: String) -> String:
	var signature = url + privateKey
	signature = signature.sha1_text().http_escape()
	
	return url_format(url, {"signature": signature})
