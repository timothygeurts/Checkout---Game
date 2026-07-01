extends CanvasLayer

@onready var inventory_panel: Panel = $InventoryPanel
@onready var item_grid: GridContainer = $InventoryPanel/VBoxContainer/ItemGrid

func _ready() -> void:
	inventory_panel.visible = false
	Inventory.inventory_veranderd.connect(ververs_weergave)
	ververs_weergave()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		inventory_panel.visible = not inventory_panel.visible

func ververs_weergave() -> void:
	for kind in item_grid.get_children():
		kind.queue_free()

	for item_type in Inventory.items.keys():
		var aantal: int = Inventory.get_aantal(item_type)
		var weergave_naam: String = Inventory.get_weergave_naam(item_type)
		var icoon: Texture2D = Inventory.get_icoon(item_type)

		var vak: VBoxContainer = VBoxContainer.new()

		var icoon_rect: TextureRect = TextureRect.new()
		icoon_rect.texture = icoon
		icoon_rect.custom_minimum_size = Vector2(0, 0)
		icoon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icoon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		var naam_label: Label = Label.new()
		naam_label.text = weergave_naam + " x" + str(aantal)
		naam_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		vak.add_child(icoon_rect)
		vak.add_child(naam_label)
		item_grid.add_child(vak)
