extends "res://addons/GamejoltAPI/lib/GameJoltRequestClass.gd"

func _init(game_id : String, score : String, sort : int, table_id := NAN,
 username := "", user_token := "", guest := "",
 data := {}, headers := PoolStringArray(), proxy := HTTPRequest.new()):
	self._data["game_id"] = game_id
	if username and user_token:
		self._data["username"] = username
		self._data["user_token"] = user_token
	else:
		self._data["guest"] = guest
		
	if table_id != NAN: self._data["table_id"] = table_id
	
	._init(data, headers, proxy)

func _ready():
	_uri = "/scores/add/"
	