extends Button

@onready var popup = $Popup


func _ready():
	set_process_input(false)
	Session.snap_changed.connect(_on_snap_changed)


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
		Session.reset_snap()
	elif event.is_action_pressed("scroll_up"):
		Session.snap += 1
	elif event.is_action_pressed("scroll_down"):
		Session.snap -= 1


func _toggled(toggled_on: bool):
	popup.visible = toggled_on
	set_process_input(toggled_on)


func _on_item_pressed(value: int):
	button_pressed = false
	Session.snap = value


func _on_snap_changed():
	text = Session.get_snap_text()
