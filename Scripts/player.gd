extends CharacterBody3D

# ─────────────────────────────────────────────
#  Bewegingssnelheden
# ─────────────────────────────────────────────
const SPEED         = 4.0   # Normale loopsnelheid
const SPRINT_SPEED  = 7.0   # Sprintsnelheid
const CROUCH_SPEED  = 2.0   # Loopsnelheid tijdens crouchen
const JUMP_VELOCITY = 3.0   # Sprongkracht

# ─────────────────────────────────────────────
#  Camera
# ─────────────────────────────────────────────
var look_dir: Vector2
@onready var camera = $Head/Camera3D
var camera_sens = 20

# ─────────────────────────────────────────────
#  Head bob instellingen
# ─────────────────────────────────────────────
# Hoe snel de bob-cyclus draait per staat
const BOB_FREQ_WALK   = 5.0   # Frequentie tijdens lopen
const BOB_FREQ_SPRINT = 8.2   # Frequentie tijdens sprinten (sneller)
const BOB_FREQ_CROUCH = 3.2   # Frequentie tijdens crouchen (langzamer)

# Hoe groot de uitwijking is (amplitude) per as
const BOB_AMP_Y = 0.1   # Op/neer beweging
const BOB_AMP_X = 0.2   # Links/rechts beweging (geeft een natuurlijke zwaai)

var _bob_time := 0.0                      # Bijgehouden tijd voor de sinus-berekening
var _velocity_before_slide := Vector3.ZERO  # Velocity vóór move_and_slide voor de bob check


# ─────────────────────────────────────────────
#  Crouch instellingen
# ─────────────────────────────────────────────
const STAND_HEIGHT  = 2.0   # Normale hoogte van de CollisionShape
const CROUCH_HEIGHT = 1.0   # Hoogte tijdens crouchen
const HEAD_STAND_Y  = 0.7   # Positie van $Head bij staan
const HEAD_CROUCH_Y = 0.2   # Positie van $Head bij crouchen

@onready var head: Node3D                      = $Head
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# ─────────────────────────────────────────────
#  Overige staat
# ─────────────────────────────────────────────
var capMouse = false
var _is_crouching := false   # Of de speler momenteel aan het crouchen is


func _physics_process(delta: float) -> void:
	# Voeg zwaartekracht toe zolang de speler niet op de grond staat
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Springen — niet mogelijk tijdens crouchen
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not _is_crouching:
		velocity.y = JUMP_VELOCITY

	# Muis vergrendelen/vrijgeven met de pause-knop
	if Input.is_action_just_pressed("pause"):
		capMouse = !capMouse
		if capMouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Crouch: alleen reageren op het moment dat de knop ingedrukt of losgelaten wordt
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		_start_crouch()
	if Input.is_action_just_released("crouch"):
		_try_stand_up()

	# Bepaal de huidige snelheid op basis van staat
	var current_speed: float
	if _is_crouching:
		current_speed = CROUCH_SPEED
	elif Input.is_action_pressed("sprint"):
		current_speed = SPRINT_SPEED
	else:
		current_speed = SPEED

	# Bewegingsrichting berekenen vanuit speler-rotatie
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Horizontale velocity toepassen of afremmen naar stilstand
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	# Sla de velocity op vóór move_and_slide — daarna kan het naar nul zijn afgerond
	_velocity_before_slide = velocity

	move_and_slide()
	_rotate_camera(delta)
	_update_head_bob(delta)


func _input(event: InputEvent):
	# Sla muisbeweging op als look_dir zodat _rotate_camera dit kan gebruiken
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01


func _rotate_camera(delta: float, sens_mod: float = 1.0):
	# Voeg controller-invoer toe aan de muisbeweging
	var input = Input.get_vector("look_left", "look_right", "look_down", "look_up")
	look_dir += input

	# Speler-body draait horizontaal (links/rechts kijken)
	rotation.y -= look_dir.x * camera_sens * delta

	# Camera draait verticaal (omhoog/omlaag kijken), begrensd zodat je nek niet omdraait
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod * delta, -1.5, 1.5)

	# Reset look_dir zodat de beweging niet blijft doorlopen
	look_dir = Vector2.ZERO


# ─────────────────────────────────────────────
#  Head bob
# ─────────────────────────────────────────────
func _update_head_bob(delta: float) -> void:
	# Gebruik de velocity van vóór move_and_slide, anders is het al nul afgerond
	var is_moving := _velocity_before_slide.length() > 0.1 and is_on_floor()

	if is_moving:
		# Kies de juiste frequentie op basis van de huidige staat
		var freq: float
		if _is_crouching:
			freq = BOB_FREQ_CROUCH
		elif Input.is_action_pressed("sprint"):
			freq = BOB_FREQ_SPRINT
		else:
			freq = BOB_FREQ_WALK

		# Laat de bob-timer oplopen
		_bob_time += delta * freq

		# Bob de $Head node zodat camera rotatie hier volledig buiten blijft
		# Y-as: op/neer beweging gesynchroniseerd met de stappencyclus
		# X-as: lichte zijwaartse zwaai voor een natuurlijk loopgevoel
		var bob_y := sin(_bob_time * 2.0) * BOB_AMP_Y
		var bob_x := cos(_bob_time) * BOB_AMP_X
		var target_y := HEAD_CROUCH_Y if _is_crouching else HEAD_STAND_Y
		head.position.y = target_y + bob_y
		head.position.x = bob_x
	else:
		# Geen beweging: schuif de head soepel terug naar de rustpositie
		_bob_time = 0.0
		var target_y := HEAD_CROUCH_Y if _is_crouching else HEAD_STAND_Y
		head.position.x = lerp(head.position.x, 0.0, delta * 6.0)
		head.position.y = lerp(head.position.y, target_y, delta * 6.0)


# ─────────────────────────────────────────────
#  Crouch logica
# ─────────────────────────────────────────────
func _start_crouch() -> void:
	# Wordt één keer aangeroepen wanneer de crouch-knop ingedrukt wordt
	_is_crouching = true
	_set_crouch_shape(CROUCH_HEIGHT)
	head.position.y = HEAD_CROUCH_Y


func _try_stand_up() -> void:
	# Wordt één keer aangeroepen wanneer de crouch-knop losgelaten wordt
	# Controleer eerst of er ruimte boven de speler is
	if _can_stand_up():
		_is_crouching = false
		_set_crouch_shape(STAND_HEIGHT)
		head.position.y = HEAD_STAND_Y
	# Als er geen ruimte is blijft de speler gecroucht totdat er wel ruimte is


func _set_crouch_shape(height: float) -> void:
	# Pas de hoogte van de CapsuleShape aan
	var capsule := collision_shape.shape as CapsuleShape3D
	if capsule:
		capsule.height = height


func _can_stand_up() -> bool:
	# Schiet een ray omhoog om te checken of er een plafond boven de speler zit
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3.UP * STAND_HEIGHT
	)
	query.exclude = [self]  # Negeer de speler zelf
	return space_state.intersect_ray(query).is_empty()  # Leeg = genoeg ruimte
