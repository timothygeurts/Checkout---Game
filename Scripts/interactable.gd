extends Area3D

@export var interactie_naam: String = "Oppakken"
@export var item_type: String = "ticket"
@export var item_icoon: Texture2D
@export var weergave_naam: String = "Treinticket"

signal opgepakt(item_type: String)

func interact() -> void:
	Inventory.voeg_item_toe(item_type, 1)
	Inventory.registreer_item_info(item_type, weergave_naam, item_icoon)
	opgepakt.emit(item_type)
	queue_free()
