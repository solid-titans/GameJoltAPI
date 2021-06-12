extends "res://addons/GamejoltAPI/lib/GameJoltRequestClass.gd"
class_name GameJoltSessionPing

func _init(game_id : String, username : String, user_token : String, status := "",
 data := {}, headers := PoolStringArray(), proxy := HTTPRequest.new()):
	data["game_id"] = game_id
	data["username"] = username
	data["user_token"] = user_token
	data["status"] = status
	._init(data, headers)


func _ready():
	_uri = "sessions/ping/"
