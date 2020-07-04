extends HTTPRequest

export(String) var gameId
export(String) var privateKey
export(String) var username
export(String) var user_token


const base_link = "https://api.gamejolt.com/api/game/"

func request(url: String, custom_headers:=PoolStringArray(), ssl_validate_domain:=true, method:=0, request_data:=""):
	var formated_URL = url_format(url, {
		"game_id":		gameId,
		"username":		username,
		"user_token":	user_token
	})
	
	if (privateKey):
		formated_URL = sign_url(formated_URL)
	
	.request(formated_URL, custom_headers, ssl_validate_domain, method, request_data)


func auth_user(username, user_token):
	request(base_link + "v1" + "/users/auth/")
	
func add_achieved(username, user_token, trophy_id):
	request(url_format(
		base_link + "v1_2" + "/trophies/add-achieved/", { "trophy_id": String(trophy_id) }
	))
	
func remove_achieved(username, user_token, trophy_id):
	request(url_format(
		base_link + "v1_2" + "/trophies/remove-achieved/", { "trophy_id": String(trophy_id) }
	))
	
	
func fetch_achieved(username, user_token, trophy_id=null, achieved=null):
	var parameters = {}
	if (trophy_id): parameters["trophy_id"] = trophy_id
	if (achieved): parameters["achived"] = achieved
	
	request(url_format(base_link + "v1" + "/trophies/", parameters))
	
	
func open_session(username, user_token):
	request(base_link + "v1" + "/sessions/open/")
	
func url_format (base: String, args: Dictionary = {}) -> String:
	
	var link = base
	
	if (!base.match("\\?")):
		link += "?"
	else:
		link += "&"
	
	for key in args:
		link += String(key).strip_edges().http_escape() + "=" + String(args[key]).strip_edges().http_escape() + "&"
	
	link = link.rstrip("&")
	
	return link

func sign_url(url: String) -> String:
	var signature = url + privateKey
	signature = signature.sha1_text().http_escape()
	
	return url + "&signature=" + signature
