extends Control

@onready var copy_button: Button = %Copy
@onready var chart_control: Control = %Chart


func _ready():
	DisplayServer.window_set_min_size(Vector2i(880, 440))

	copy_button.pressed.connect(Session.copy_to_clipboard)
	chart_control.show()
