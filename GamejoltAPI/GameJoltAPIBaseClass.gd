########################################
##### Base Class of GameJoltAPI ########
########################################

extends HTTPRequest

#Use _auth_user instead of changing both of these manually
var username   : String
var user_token : String

#If the clinet is using the GameJolt client, it will change
var client_version : String = "none"

#Called when session changes
signal api_session_status_changed(status)

const BASE_LINK = "https://api.gamejolt.com/api/game/"

#Change this on Project Settings
var GAME_ID        : String  = ProjectSettings.get_setting("GameJoltAPI/Game/GameID")
var PRIVATE_KEY    : String  = ProjectSettings.get_setting("GameJoltAPI/Game/PrivateKey")
var MULTITHREAD    : bool    = ProjectSettings.get_setting("GameJoltAPI/Requests/Multithread")
var VERBOSE        : bool    = ProjectSettings.get_setting("GameJoltAPI/Debug/Verbose")
var DOWNLOAD_PATH  : String  = ProjectSettings.get_setting("GameJoltAPI/Requests/DownloadPath")

var requests := {
	"counter" : 0,  #The number of requests done (used to define the ID's)
	"nodes"   : {}, #The request Nodes
}

signal api_download_file_completed(response, id, result, metadata)

func get_gj_credentials() -> Dictionary:
	#Get Credentials from GameJolt credentials file
	var directory = Directory.new()
	var path = ".gj-credentials"
	var credentials = {}
	
	if directory.file_exists(path):
		var file = File.new()
		file.open(path, file.READ)
		
		#Get each credential from each line
		credentials = {
			"version"    : file.get_line(),
			"username"   : file.get_line(),
			"user_token" : file.get_line(),
		}
		file.close()
	
	return credentials


func add_request_node_to_list (node: HTTPRequest, type: String, metadata:= {},  id: int = -1) -> int:
	#Add a request to the queue or parallel list
	if id == -1:
		id = requests.counter
		requests.counter += 1
	
	
	#Parallelization
	add_child(node)
	node.connect("request_completed", self, "on_request_completed", [id])
	print_verbose("New request (ID: " + String(id) + ")!")
	
	requests.nodes[id] = ({
		"type"     : type,
		"node"     : node,
		"metadata" : metadata
	})
	
	return id


func on_request_completed(result, response_code, headers, body, id):
	print_verbose("Request (ID = " + String(id) + ") completed with code: " + String(response_code) +
	"(Result = " + String(result) + ")")
	
	
	var request_node = requests.nodes.get(id)
	# Remove the node from nodes list
	requests.nodes.erase(id)
	request_node.node.disconnect("request_completed", self, "on_request_completed")
	
	var parsed_body = body.get_string_from_utf8()
	
	if not parsed_body: parsed_body = {'success': 'false'}
	else: parsed_body = JSON.parse(parsed_body).result.response
	
	var response = {
		"response_code": response_code,
		"headers": headers,
		"body": body,
	}
	
	# Emit a general signal and then a specific one
	emit_signal("api_request_completed", request_node.type, response, id, result, request_node.metadata)
	emit_signal("api_" + request_node.type + "_completed", response, id, result, request_node.metadata)
	#Remove the node
	request_node.node.queue_free()
	


func make_request(url: String, type: String, path:=DOWNLOAD_PATH + String(requests.counter).md5_text(), metadata:= {}) -> int:
	#Add the request to the queue and return request id
	
	var formated_URL = url
	if formated_URL.find("format") == -1:
		formated_URL = url_format(url, {"format": "json"})
	
	formated_URL = sign_url(formated_URL)
	print_verbose("Final URL: " + formated_URL)
	
	var node = HTTPRequest.new()
	node.request(formated_URL)
	node.use_threads = MULTITHREAD
	node.download_file = path
	
	metadata["path"] = path
	metadata["url"]  = url
	
	return add_request_node_to_list(node, type, metadata)

func download_from_link(url: String, type:="download_file", path:=DOWNLOAD_PATH + String(requests.counter).md5_text(), metadata:= {}) -> int:
		return make_request(url, type, path, metadata)

func url_format (base: String, args: Dictionary = {}) -> String:
	#Get an url and arguments and return a formated url
	
	var link = base
	
	if (!base.ends_with("?")):
		if (base.find("?") == -1):
			link += "?"
		else:
			link += "&"
			
	
	for key in args:
		if (args.get(key)):
			link += String(key).http_escape() + "=" + String(args.get(key)).http_escape() + "&"
	
	link = link.rstrip("&")
	
	return link


func sign_url(url: String) -> String:
	var signature = url + PRIVATE_KEY
	signature = signature.sha1_text()
	
	return url_format(url, {"signature": signature})
	
func print_verbose(msg):
	if VERBOSE: print("[GameJoltAPI] ", msg)

