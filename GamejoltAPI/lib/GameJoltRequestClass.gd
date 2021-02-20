extends Node

signal request_completed(result, response_code, headers, parsed_body)

enum METHODS {
	GET = HTTPClient.METHOD_GET,
	POST = HTTPClient.METHOD_POST,
}


onready var _http_request 	: HTTPRequest
var _private_key			: String
var _url					: String
var _method					: int
var _headers				: PoolStringArray
var _data					: Dictionary


func _init(private_key : String, url : String, data := {}, headers := PoolStringArray(),
 method := HTTPClient.METHOD_GET, requester := HTTPRequest.new()):
	self._url = url
	self._data = data
	self._headers = headers
	self._private_key = private_key


func _parse_data(data : Dictionary):
	"""Creates an uri using a dictionary"""
	var uri = ""
	for key in data.keys():
		uri += "%s=%s&" % [String(key).http_escape(), String(data[key]).http_escape()]
	
	return uri.rstrip("&")

func _ready():
	add_child(_http_request)
	_http_request.connect("request_completed", self, "_on_request_completed")
	
	
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
	var url = _sign_url(_url + "?" + _parse_data(_data))
	_http_request.request(url, _headers, true, _method)
	if _method == METHODS.POST:
		printerr("POST method not implemented")
