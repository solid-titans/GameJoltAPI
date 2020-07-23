extends Node

onready var animation = $AnimationPlayer

func _ready():
	GameJoltAPI.connect("api_add_achieved_completed", self, '_show_trophy')

func _show_trophy(data, id, response, result):
	if not (data.has('message') and data.message == 'The user already has this trophy.') and data.success == 'true': 
		animation.play("EnteringScreen")
