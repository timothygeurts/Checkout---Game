extends Node

signal inventory_veranderd

var items: Dictionary = {}
var item_info: Dictionary = {}

func voeg_item_toe(item_type: String, aantal: int = 1) -> void:
	if items.has(item_type):
		items[item_type] += aantal
	else:
		items[item_type] = aantal
	inventory_veranderd.emit()

func verwijder_item(item_type: String, aantal: int = 1) -> void:
	if not items.has(item_type):
		return
	items[item_type] -= aantal
	if items[item_type] <= 0:
		items.erase(item_type)
	inventory_veranderd.emit()

func registreer_item_info(item_type: String, weergave_naam: String, icoon: Texture2D) -> void:
	item_info[item_type] = {"naam": weergave_naam, "icoon": icoon}

func get_weergave_naam(item_type: String) -> String:
	if item_info.has(item_type):
		return item_info[item_type]["naam"]
	return item_type

func get_icoon(item_type: String) -> Texture2D:
	if item_info.has(item_type):
		return item_info[item_type]["icoon"]
	return null

func heeft_item(item_type: String) -> bool:
	return items.has(item_type)

func get_aantal(item_type: String) -> int:
	if items.has(item_type):
		return items[item_type]
	return 0
