extends Node


signal request_completed(result, response_code, headers, parsed_body)

enum METHODS {
	GET = HTTPClient.METHOD_GET,
	POST = HTTPClient.METHOD_POST,
}

const _BASE_URL	 := "https://api.gamejolt.com/api/game/"

onready var _proxy			:= HTTPRequest.new() setget set_proxy
onready var _private_key 	: String = ProjectSettings.get_setting("GameJoltAPI/Game/PrivateKey")
var _uri					: String
var _method					: int = METHODS.GET
var _headers				: PoolStringArray
var _data					: Dictionary


func _init(data := {}, headers := PoolStringArray()):
	self._data = data
	self._headers = headers


func _parse_data(data : Dictionary):
	"""Creates an uri using a dictionary"""
	var uri = ""
	for key in data.keys():
		uri += "%s=%s&" % [String(key).http_escape(), String(data[key]).http_escape()]
	
	return uri.rstrip("&")

func set_proxy(proxy: HTTPRequest):
	remove_child(self._proxy)
	_proxy = proxy
	add_child(proxy)
	

func _ready():
	_proxy.connect("request_completed", self, "_on_request_completed")
	
func _on_request_completed(result, response_code, headers, body):
	var parsed_body = JSON.parse(body)
	emit_signal("request_completed", result, response_code, headers, parsed_body)
		


func _sign_url(url):
	"""Sign the url with your game private key"""
	var signature = (url + _private_key).sha1_text()
	var signed_url = url
	if url.find("?"):
		signed_url += "&"
	else:
		signed_url += "?"
		
	signed_url += "signature={}".format([signature])
	
	return signed_url

func request():
	var url = _sign_url(_BASE_URL + _uri + "?" + _parse_data(_data))
	_proxy.request(url, _headers, true, _method)
	if _method == METHODS.POST:
		printerr("POST method not implemented")
