extends Node

onready var animation = $AnimationPlayer

func _ready():
	GameJoltAPI.connect("api_add_achieved_completed", self, '_show_trophy')

func _show_trophy(response, id, result, metadata):
	if not (response.body.has('message') and response.body.message == 'The user already has this trophy.') and response.body.success == 'true': 
		animation.play("EnteringScreen")
