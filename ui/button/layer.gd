extends HBoxContainer

@onready var buttons: Array[Button] = [$NoteBT, $NoteFX, $LaserL, $LaserR]


func _ready():
	Session.layer_changed.connect(_on_layer_changed)


func _on_item_gui_input(event):
	if event.is_action_pressed("scroll_up"):
		Session.increase_layer()
	elif event.is_action_pressed("scroll_down"):
		Session.decrease_layer()


func _on_item_toggled(toggled_on: bool, layer: int):
	if toggled_on:
		Session.layer = layer as Session.Layer


func _on_layer_changed():
	buttons[Session.layer].button_pressed = true
