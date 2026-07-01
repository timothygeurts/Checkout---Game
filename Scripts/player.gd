extends CharacterBody3D


const SPEED: float = 4.0
const SPRINT_SPEED: float = 7.0
const CROUCH_SPEED: float = 2.0
const JUMP_VELOCITY: float = 3.0

const BOB_FREQ_WALK: float = 5.0
const BOB_FREQ_SPRINT: float = 8.2
const BOB_FREQ_CROUCH: float = 3.2
const BOB_AMP_Y: float = 0.08
const BOB_AMP_X: float = 0.04

const STAND_HEIGHT: float = 2.0
const CROUCH_HEIGHT: float = 1.0
const HEAD_STAND_Y: float = 0.7
const HEAD_CROUCH_Y: float = 0.2

var lookDirection: Vector2
var cameraSensitivity: float = 20.0
var isCrouching: bool = false
var isMouseCaptured: bool = false
var bobTime: float = 0.0
var velocityBeforeSlide: Vector3 = Vector3.ZERO

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collisionShape: CollisionShape3D = $CollisionShape3D


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not isCrouching:
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("pause"):
		isMouseCaptured = !isMouseCaptured
		if isMouseCaptured:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.is_action_just_pressed("crouch") and is_on_floor():
		StartCrouch()
	if Input.is_action_just_released("crouch"):
		TryStandUp()

	var currentSpeed: float
	if isCrouching:
		currentSpeed = CROUCH_SPEED
	elif Input.is_action_pressed("sprint"):
		currentSpeed = SPRINT_SPEED
	else:
		currentSpeed = SPEED

	var inputDirection: Vector2 = Input.get_vector("left", "right", "up", "down")
	var moveDirection: Vector3 = (transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized()

	if moveDirection:
		velocity.x = moveDirection.x * currentSpeed
		velocity.z = moveDirection.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

	velocityBeforeSlide = velocity
	move_and_slide()
	RotateCamera(delta)
	UpdateHeadBob(delta)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		lookDirection = event.relative * 0.01


func RotateCamera(delta: float, sensitivityModifier: float = 1.0) -> void:
	var controllerInput: Vector2 = Input.get_vector("look_left", "look_right", "look_down", "look_up")
	lookDirection += controllerInput

	rotation.y -= lookDirection.x * cameraSensitivity * delta
	camera.rotation.x = clamp(camera.rotation.x - lookDirection.y * cameraSensitivity * sensitivityModifier * delta, -1.5, 1.5)

	lookDirection = Vector2.ZERO


func UpdateHeadBob(delta: float) -> void:
	var isMoving: bool = velocityBeforeSlide.length() > 0.1 and is_on_floor()

	if isMoving:
		var frequency: float
		if isCrouching:
			frequency = BOB_FREQ_CROUCH
		elif Input.is_action_pressed("sprint"):
			frequency = BOB_FREQ_SPRINT
		else:
			frequency = BOB_FREQ_WALK

		bobTime += delta * frequency

		var bobOffsetY: float = sin(bobTime * 2.0) * BOB_AMP_Y
		var bobOffsetX: float = cos(bobTime) * BOB_AMP_X
		var targetY: float = HEAD_CROUCH_Y if isCrouching else HEAD_STAND_Y

		head.position.y = targetY + bobOffsetY
		head.position.x = bobOffsetX
	else:
		bobTime = 0.0
		var targetY: float = HEAD_CROUCH_Y if isCrouching else HEAD_STAND_Y
		head.position.x = lerp(head.position.x, 0.0, delta * 6.0)
		head.position.y = lerp(head.position.y, targetY, delta * 6.0)


func StartCrouch() -> void:
	isCrouching = true
	SetCrouchShape(CROUCH_HEIGHT)
	head.position.y = HEAD_CROUCH_Y


func TryStandUp() -> void:
	if CanStandUp():
		isCrouching = false
		SetCrouchShape(STAND_HEIGHT)
		head.position.y = HEAD_STAND_Y


func SetCrouchShape(height: float) -> void:
	var capsule: CapsuleShape3D = collisionShape.shape as CapsuleShape3D
	if capsule:
		capsule.height = height


func CanStandUp() -> bool:
	var spaceState: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3.UP * STAND_HEIGHT
	)
	query.exclude = [self]
	return spaceState.intersect_ray(query).is_empty()

@onready var interaction_ray: RayCast3D = $Head/Camera3D/InteractionRay


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		probeer_interactie()


func probeer_interactie() -> void:
	interaction_ray.force_raycast_update()

	if interaction_ray.is_colliding():
		var geraakt_object = interaction_ray.get_collider()
		print("Geraakt: ", geraakt_object.name)
		print("In groep: ", geraakt_object.is_in_group("interactable"))

		if geraakt_object.is_in_group("interactable"):
			geraakt_object.interact()
	else:
		print("Raycast raakt niks")
