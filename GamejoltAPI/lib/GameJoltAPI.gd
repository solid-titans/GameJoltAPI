extends Node

var _last_id = -1
var _requests = {}
	
func _on_request_completed(id, result, response_code, headers, parsed_body):
	if _requests.get(id):
		self.remove_child(_requests[id])
		_requests.erase(id)
	else:
		printerr("Unable to delete request Node (maybe it's already deleted?)")


func new_request(request) -> int:
	"""Create a new request object and add it as a child"""
	_last_id += 1
	_requests[_last_id] = request
	add_child(request)
	request.connect("request_completed", self, "_on_request_completed")
	request.request()
	return _last_id
	
