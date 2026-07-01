extends Node3D

@onready var player = get_parent()
@onready var animation_player = $AnimationPlayer

func _process(_delta):
	var moving := Vector2(player.velocity.x, player.velocity.z).length() > 0.1

	if moving:
		if animation_player.current_animation != "Walking":
			animation_player.play("Walking")
	else:
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")
