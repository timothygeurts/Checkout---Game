extends Area3D

@export var interactie_naam: String = "Oppakken"
@export var item_type: String = "ticket"

signal opgepakt(item_type: String)

func interact() -> void:
	opgepakt.emit(item_type)
	queue_free()
