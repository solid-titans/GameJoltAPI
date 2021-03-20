extends "res://addons/GamejoltAPI/lib/GameJoltRequestClass.gd"
class_name GameJoltUsersIndex

func _init(game_id : String, username : String, user_token : String,  data := {},
 headers := PoolStringArray()):
	self._data["game_id"] = game_id
	self._data["username"] = username
	self._data["user_token"] = user_token
	._init(data, headers)

func _ready():
	_uri = "/users/"
	
