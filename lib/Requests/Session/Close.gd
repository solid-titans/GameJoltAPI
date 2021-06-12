extends "res://addons/GamejoltAPI/lib/GameJoltRequestClass.gd"
class_name GameJoltSessionClose

func _init(game_id : String, username : String, user_token : String,  data := {},
 headers := PoolStringArray()):
	data["game_id"] = game_id
	data["username"] = username
	data["user_token"] = user_token
	._init(data, headers)

func _ready():
	_uri = "sessions/close/"
	
