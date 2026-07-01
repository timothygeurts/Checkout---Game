extends CharacterBody3D

var player = null

const SPEED = 4.0

@export var player_path : NodePath

@onready var nav_agent = 

func _ready():
	player = get_node(player_path)
