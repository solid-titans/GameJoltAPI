extends Node

onready var animation = $AnimationPlayer
onready var trophys   = preload("res://addons/GamejoltAPI/resources/GameJoltResources/Trophys/trophysConstants.gd")
onready var trophy    = $AnimatedNode/TrophyPhoto

func _ready():
	trophy.texture = load(trophys.new().SILVER_TROPHY)
	animation.play("EnteringScreen")
