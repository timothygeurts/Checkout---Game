extends Area3D

@export var benodigdeTickets: int = 6
@export var beginschermPad: String = "res://Scene/Main_Menu.tscn"

func _ready() -> void:
	body_entered.connect(OpBodyBinnengekomen)

func OpBodyBinnengekomen(body: Node3D) -> void:
	print("Iets kwam binnen: ", body.name)
	if not body.is_in_group("player"):
		print("Niet de player")
		return
	print("Tickets: ", Inventory.get_aantal("ticket"))
	if Inventory.get_aantal("ticket") >= benodigdeTickets:
		GaNaarBeginscherm()

func GaNaarBeginscherm() -> void:
	get_tree().change_scene_to_file(beginschermPad)
