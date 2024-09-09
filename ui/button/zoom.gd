extends Button

@onready var popup = $Popup


func _ready():
	set_process_input(false)
	Session.zoom_changed.connect(_on_zoom_changed)


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		button_pressed = false

	elif event.is_action_pressed("left_click"):
		var mouse := get_global_mouse_position()
		if get_global_rect().has_point(mouse):
			return
		if popup.get_global_rect().has_point(mouse):
			return
		button_pressed = false


func _gui_input(event: InputEvent):
	if event.is_action_pressed("right_click"):
		Session.reset_zoom()
	elif event.is_action_pressed("scroll_up"):
		Session.increase_zoom()
	elif event.is_action_pressed("scroll_down"):
		Session.decrease_zoom()


func _toggled(toggled_on: bool):
	popup.visible = toggled_on
	set_process_input(toggled_on)


func _on_item_pressed(value: float):
	button_pressed = false
	Session.zoom = value


func _on_zoom_changed():
	text = Session.get_zoom_text()
