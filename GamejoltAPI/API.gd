extends HTTPRequest

export(String) var gameId
export(String) var privateKey

const base_link = "https://api.gamejolt.com/api/game/"

signal login(username, token)

func _ready():
	connect("request_completed", self, "_on_request_completed")
	

func _on_request_completed(result, response_code, headers, body):
	print(body.get_string_from_ascii())
	
func _auth_user(username, user_token):
	var urlContruct = urlFormat(base_link + "v1" + "/users/auth/", {
		"game_id":	gameId,
		"username":	username,
		"user_token":	user_token
	})
	
	var finalUrl = signUrl(urlContruct)
	
	print(finalUrl)
	request(finalUrl)
	
func _add_achieved(username, user_token, trophy_id):
	var urlContruct = urlFormat(base_link + "v1_2" + "/trophies/add-achieved/", {
		"game_id":	gameId,
		"username":	username,
		"user_token":	user_token,
		"trophy_id":	String(trophy_id)
	})
	
	var finalUrl = signUrl(urlContruct)
	
	request(finalUrl)
	
func _remove_achieved(username, user_token, trophy_id):
	var urlContruct = urlFormat(base_link + "v1_2" + "/trophies/remove-achieved/", {
		"game_id":	gameId,
		"username":	username,
		"user_token":	user_token,
		"trophy_id":	String(trophy_id)
	})
	
	var finalUrl = signUrl(urlContruct)
	
	request(finalUrl)
	
func _fetch_achieved(username, user_token, trophy_id='1', achieved=false):
	var urlContruct = urlFormat(base_link + "v1" + "/trophies/", {
		"game_id":	gameId,
		"username":	username,
		"user_token":	user_token
	})
	#urlContruct     = urlContruct + "&achieved="   + String(achieved)
	#urlContruct     = urlContruct + "&trophy_id="  + String(trophy_id)
	
	var finalUrl = signUrl(urlContruct)
	
	print(finalUrl)
	request(finalUrl)
	
func _open_session(username, user_token):
	var urlContruct = urlFormat(base_link + "v1" + "/sessions/open/", {
		"game_id": gameId,
		"username": username,
		"user_token": user_token	
	})
	
	var finalUrl = signUrl(urlContruct)
	
	print(finalUrl)
	request(finalUrl)
	
func urlFormat (base: String, args: Dictionary = {}) -> String:
	var link = base + "?"
	
	for key in args:
		link += key.http_escape() + "=" + args[key].http_escape() + "&"
	
	link = link.rstrip("&")
	
	return link

func signUrl(url: String) -> String:
	var signature = url + privateKey
	signature = signature.sha1_text().http_escape()
	var finalUrl = url + "&signature=" + signature
	return finalUrl
