extends Node

onready var animation = $AnimationPlayer

func _ready():
	GameJoltAPI.connect("api_add_achieved_completed", self, '_show_trophy')

func _show_trophy(id, response_code, body):
	animation.play("EnteringScreen")
