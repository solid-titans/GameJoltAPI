extends "res://addons/GamejoltAPI/lib/GameJoltRequestClass.gd"
class_name GameJoltSessionAdd

func _init(game_id : String, score : String, sort : int, table_id := NAN,
 username := "", user_token := "", guest := "",
 data := {}, headers := PoolStringArray()):
	data["game_id"] = game_id
	if username and user_token:
		data["username"] = username
		data["user_token"] = user_token
	else:
		data["guest"] = guest
		
	if table_id != NAN: data["table_id"] = table_id
	
	._init(data, headers)

func _ready():
	_uri = "scores/add/"
	
