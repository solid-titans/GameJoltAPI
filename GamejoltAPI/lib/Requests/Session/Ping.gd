extends "res://addons/GameJoltAPI/lib/GameJoltRequestClass.gd"


var timer := Timer.new()
var delay := 30


func _init(game_id : String, username : String, user_token : String,  data := {},
 headers := PoolStringArray(), proxy := HTTPRequest.new()):
	self._data["game_id"] = game_id
	self._data["username"] = username
	self._data["user_token"] = user_token
	._init(data, headers, proxy)

func _on_timeout():
	timer.start(delay)
	self.request()

func _ready():
	timer.connect("timeout", self, "_on_timeout")
	timer.wait_time = delay
	timer.start(delay)
	_uri = "/sessions/ping/"
	_method = METHODS.GET
