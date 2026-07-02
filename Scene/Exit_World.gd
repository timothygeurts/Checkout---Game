extends StaticBody3D

@onready var popup_label: Label3D = $Label3D

var required_tickets: int = 6

func _ready() -> void:
	if popup_label:
		popup_label.visible = false

func _on_area_3d_area_entered(area: Area3D) -> void:
	var amount: int = Inventory.get_aantal("ticket")

	if amount < required_tickets:
		show_message("You need all 6 tickets! (" + str(amount) + "/7)")
	else:
		show_message("You can leave!")
		leave_game()

func show_message(text: String) -> void:
	if popup_label:
		popup_label.text = text
		popup_label.visible = true
		await get_tree().create_timer(2.0).timeout
		popup_label.visible = false

func leave_game() -> void:
	get_tree().change_scene_to_file("res://Scene/Escape.tscn")
