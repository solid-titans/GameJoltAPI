extends "res://addons/GamejoltAPI/lib/GameJoltRequestClass.gd"

func _init(game_id : String, username : String, user_token : String, status := "",
 data := {}, headers := PoolStringArray(), proxy := HTTPRequest.new()):
	self._data["game_id"] = game_id
	self._data["username"] = username
	self._data["user_token"] = user_token
	self._data["status"] = status
	._init(data, headers, proxy)


func _ready():
	_uri = "/sessions/ping/"
