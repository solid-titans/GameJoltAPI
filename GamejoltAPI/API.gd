extends "GameJoltAPIBaseClass.gd"

var URLs = {
	"auth_user"       : "/users/auth/",
	"open_session"    : "/sessions/open/",
	"ping_session"    : "/sessions/ping/",
	"check_session"   : "/sessions/check/",
	"close_session"   : "/sessions/close/",
	"add_score"       : "/scores/add/",
	"score_get_rank"  : "/scores/get-rank/",
	"fetch_score"     : "/scores/",
	"score_tables"    : "/scores/tables/",
	"fetch_achieved"  : "/trophies/",
	"add_achieved"    : "/trophies/add-achieved/",
	"remove_achieved" : "/trophies/remove-achieved/",
	"fetch_user_data" : "/users/",
	"batch_request"   : "/batch/",
}

# GameJolt server require to ping every 120s to make sure you still online
var session_timer := Timer.new()

enum STATUS {
	NOT_AUTENTICATED,
	RECONNECTING,
	OPEN,
	CLOSED,
}

var session = STATUS.NOT_AUTENTICATED setget change_session_status

signal api_auth_user_completed(response, id, result, metadata)
signal api_open_session_completed(response, id, result, metadata)
signal api_login_user_completed(response, id, result, metadata)
signal api_ping_session_completed(response, id, result, metadata)
signal api_check_session_completed(response, id, result, metadata)
signal api_close_session_completed(response, id, result, metadata)
signal api_add_score_completed(response, id, result, metadata)
signal api_score_get_rank_completed(response, id, result, metadata)
signal api_fetch_score_completed(response, id, result, metadata)
signal api_score_tables_completed(response, id, result, metadata)
signal api_fetch_achieved_completed(response, id, result, metadata)
signal api_add_achieved_completed(response, id, result, metadata)
signal api_remove_achieved_completed(response, id, result, metadata)
signal api_fetch_user_data_completed(response, id, result, metadata)
signal api_batch_request_completed(response, id, result, metadata)

#----------------- API functions -----------------#

func _auth_user(username: String, user_token: String) -> int:
	#Login the player with the username and user_token
	self.username   = username
	self.user_token = user_token
	
    return make_request(url_format(BASE_LINK + "v1" + URLs.auth_user, 
        {
            "game_id":      GAME_ID,
            "username":		username,
            "user_token":	user_token
        }
    ), "auth_user")

func _open_session() -> int:
	# Open the player session
    var id = make_request(url_format(BASE_LINK + "v1" + URLs.open_session, 
        {
            'game_id'    : GAME_ID,
            'username'   : username,
            'user_token' : user_token
        }
    ), "open_session")

	return id

func _login_user(username: String, user_token: String) -> int:
	# Athenticate the user and opens a new session if succeded
	var req = []
    req.append(url_format(URLs.auth_user, 
        {
            "game_id":      GAME_ID,
            "username":		username,
            "user_token":	user_token
        }
    ))
    req.append(url_format(URLs.open_session, 
        {
            'game_id'    : GAME_ID,
            'username'   : username,
            'user_token' : user_token
        }
    ))
	return _batch_request(PoolStringArray(req), true, false)

func _ping_session(status:= "") -> int:
	# Ping the session
	# Valid values for status: "active" and "idle"
    return make_request(url_format(BASE_LINK + "v1" + URLs.ping_session, 
        {
            "game_id"    : GAME_ID,
            "username"   : username,
            "user_token" : user_token,
            "status"     : status
        }
    ), "ping_session")

func _check_session() -> int:
	# Check what game the player is current playing
    return make_request(url_format(BASE_LINK + "v1_2" + URLs.check_session, 
        {
            "game_id"    : GAME_ID,
            "username"   : username,
        }
    ), "check_session")

func _close_session() -> int:
	# Close the current session for the game
    return make_request(url_format(BASE_LINK + "v1_2" + URLs.close_session, 
        {
            "game_id"    : GAME_ID,
            "username"   : username,
        }
    ), "close_session")

func _add_score(use_players_credentials: bool, guest: String, score: String, sort: int, extra_data: String, table_id: int) -> int:
	# Add a score to the scoreboard
	# Required : 'Score' and 'Sort'!
	# Optional : The players credentials, some extra data you want to store and the table id to store
	# If you choose to not use the players credentials you can choose a name for the player
	
    return make_request(url_format(BASE_LINK + "v1" + URLs.add_score, 
        {
		    "game_id"    : GAME_ID,
		    "score"      : score,
		    "sort"       : sort,
		    "extra_data" : extra_data,
		    "table_id"   : table_id,
		    "username"   : username   if use_players_credentials     else null,
		    "user_token" : user_token if use_players_credentials     else null, 
		    "guest"      : guest      if not use_players_credentials else null,
        }
    ), "add_score")

func _score_get_rank(table_id: int) -> int:
	# Returns the rank of a particular score on a score table
	
    return make_request(url_format(BASE_LINK + "v1_2" + URLs.score_get_rank, 
        {
		    'game_id'    : GAME_ID,
		    'username'   : username,
		    'user_token' : user_token,
		    'table_id'   : table_id
        }
    ), "score_get_rank")

func _fetch_score(use_players_credentials: bool, limit: int, table_id: int, guest: String, better_than: int, worse_than: int) -> int:
	# Return a especific score of your game
	
    return make_request(url_format(BASE_LINK + 'v1_2' + URLs.fetch_scores, 
        {
		    'game_id'     : GAME_ID,
		    'limit'       : limit,
		    'table_id'    : table_id,
		    'better_than' : better_than,
            'worse_than'  : worse_than,
            "username"   : username   if use_players_credentials     else null,
		    "user_token" : user_token if use_players_credentials     else null, 
		    "guest"      : guest      if not use_players_credentials else null,
        }
    ), 'fetch_score')

func _score_tables() -> int:
	# Return the score tables of your game
	
    return make_request(url_format(BASE_LINK + 'v1.0' + URLs.score_tables, 
        {
		    'game_id' : GAME_ID
        }
    ), 'score_tables')

func _fetch_achieved(trophy_id, achieved) -> int:
	#	Fetch whatever if a trophy is achived or not
	#	@params:
	#		*tropy_id: 
	#			- The target trophy id 
	#			- Return all trophyies if null
	#		*achived:
	#			- Filters the target trophyes
	#			- Return all if null
	#			- Return achived if true
	#			- Return not achived if false
	
    return make_request(url_format(BASE_LINK + "v1" + URLs.fetch_achieved, 
        {
		    "trophy_id":	trophy_id,
		    "achived":		achieved,
		    "game_id":		GAME_ID,
		    "username":		username,
		    "user_token":	user_token
        }
    ), "fetch_achived")

func _add_achieved(trophy_id: int) -> int:
	#Add a trophy to the player
	
	return make_request(url_format(
        BASE_LINK + "v1_2" + URLs.add_achieved, 
        { 
			"game_id"     : GAME_ID,
			"username"    : username,
			"user_token"  : user_token,
			"trophy_id"   : trophy_id
        }
    ), "add_achieved")
	
func _remove_achieved(trophy_id: int) -> int:
	#Remove a trophy of the player
    return make_request(url_format( BASE_LINK + "v1_2" + URLs.remove_achieved,
        {
			"game_id"    : GAME_ID,
			"username"   : username,
			"user_token" : user_token,
			"trophy_id"  : trophy_id
        }
    ), "remove_achieved")
	

func _fetch_user_data(user_ids: String) -> int:
	# Fetch user data
	
    return make_request(url_format(BASE_LINK + "v1_2" + URLs.fetch_user_data, 
        {
            "game_id"  : GAME_ID,
            "user_id"  : user_ids,
            "username" : username if user_ids else null,
        }
    ), "fetch_user_data")

func _batch_request(requests:=PoolStringArray(), break_on_error:=true, parallel:=false, download_to_file:=DOWNLOAD_PATH+String(requests.counter).md5_text()) -> int:
	#Make a batch request
	#Can handle multiple sub-requests in one major request
	#You can create a sub-request by using url_format function
	
	var final_url = BASE_LINK + "v1_2" + URLs.batch_request
	for req in requests:
		#Concat each sub-request to the final url
		final_url = url_format(final_url, {
				"requests[]": sign_url(req).http_escape()
			})
	
    return make_request(url_format(final_url, 
        {
		    "break_on_error": break_on_error,
		    "parallel": parallel
        }
    ), "batch_request", download_to_file)

#----------------- Non-API functions -----------------#
##################### Do not use! #####################

func _ready():
	# Activating auto ping
	add_child(session_timer)
	session_timer.connect("timeout", self, "on_session_timer_timeout")
	
	connect("api_ping_session_completed", self, "on_api_ping_session_completed")
	connect("api_open_session_completed", self, "on_api_open_session_completed")
	connect("api_auth_user_completed", self, "on_api_auth_user_completed")
	connect("api_close_session_completed", self, "on_api_close_session_completed")
	
	# Get user credentials
	var credentials := get_gj_credentials()
	if credentials.size() > 0: 
		client_version = credentials.get("version")
		_auth_user(credentials.get("username"), credentials.get("user_token"))

func change_session_status (new_status: int):
	if not STATUS.has(new_status):
		print_verbose("Error while setting new session status (Unknow status)")
	
	print_verbose("Status changed of " + String(session) + " to " + String(new_status))
	session = new_status
	emit_signal("api_session_status_changed", new_status)

func on_api_close_session_completed (data, id, response_code, result):
	session = STATUS.CLOSED
	session_timer.stop()
	

func on_api_auth_user_completed(data, id, response_code, result):
	if response_code == 200:
		session = STATUS.CLOSED
	elif data.success == 'false':
		session = STATUS.NOT_AUTENTICATED


func on_api_open_session_completed(data, id, response_code, result):
	if result != RESULT_SUCCESS:
		session = STATUS.RECONNECTING
	elif data.success == 'false' or response_code != 200:
		session = STATUS.NOT_AUTENTICATED
	else:
		session_timer.start(3)
		session = STATUS.OPEN


func on_api_ping_session_completed(data, id, response_code, result):
	if result != RESULT_SUCCESS:
		session = STATUS.RECONNECTING
	elif data.success == 'false' or response_code != 200:
		print_verbose("Failed to ping: " + data.message)


func on_session_timer_timeout():
	match session:
		STATUS.RECONNECTING:
			print_verbose("Reconnectiong...")
			_open_session()
		STATUS.OPEN:
			_ping_session()
		STATUS.CLOSED, STATUS.NOT_AUTENTICATED:
			session_timer.stop()
