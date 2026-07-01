extends Camera3D

# === Settings ===
@export var shake_speed: float = 0.75      # How fast the movement is
@export var position_amount: float = 0.1 # Position movement (meters)
@export var rotation_amount: float = 0.75  # Rotation movement (degrees)

var time := 0.0
var base_position: Vector3
var base_rotation: Vector3

func _ready():
	base_position = position
	base_rotation = rotation

func _process(delta):
	time += delta * shake_speed

	# Smooth floating movement
	position = base_position + Vector3(
		sin(time * 1.2) * position_amount,
		cos(time * 1.6) * position_amount * 0.5,
		sin(time * 0.8) * position_amount * 0.7
	)

	rotation = base_rotation + Vector3(
		deg_to_rad(sin(time * 1.3) * rotation_amount),
		deg_to_rad(cos(time * 1.1) * rotation_amount),
		0.0
	)
