extends Area2D

enum Mode { NONE, MOVE, SPAN }

@export var note: Note
@export var grid: Grid

var hovering := false
var mode := Mode.NONE
var offset_y := 0

@onready var chip: CollisionPolygon2D = $Chip
@onready var hold: CollisionPolygon2D = $Hold


func _ready():
	note.changed.connect(_update_note)

	Session.scroll_changed.connect(_update_note)
	Session.zoom_changed.connect(_update_note)
	Session.layer_changed.connect(_update_layer)

	_update_note()
	_update_layer()

	if note.type == Note.Type.BT:
		modulate = Session.settings.color_note_bt
	else:
		modulate = Session.settings.color_note_fx


func _input(event: InputEvent):
	if hovering and event.is_action_pressed("left_click"):
		get_viewport().set_input_as_handled()

		if event.shift_pressed:
			mode = Mode.MOVE
			offset_y = get_local_mouse_position().y - grid.unit_to_pixel_y(note.time)
		else:
			mode = Mode.SPAN

	elif event.is_action_released("left_click"):
		mode = Mode.NONE

	elif hovering and event.is_action_pressed("right_click"):
		get_viewport().set_input_as_handled()

		if event.shift_pressed:
			note.span = 0
			note.emit_changed()
		else:
			Session.chart.notes.erase(note)
			queue_free()

	elif mode != Mode.NONE:
		var mouse := get_local_mouse_position()

		match mode:
			Mode.MOVE:
				note.lane = grid.pixel_to_unit_x(mouse.x)
				note.time = Session.snap_y(grid.pixel_to_unit_y(mouse.y - offset_y))
			Mode.SPAN:
				note.span = maxi(Session.snap_y(grid.pixel_to_unit_y(mouse.y)) - note.time, 0)

		note.emit_changed()


func _mouse_enter():
	hovering = true


func _mouse_exit():
	hovering = false


func setup_edit():
	var mouse := get_local_mouse_position()
	note.lane = grid.pixel_to_unit_x(mouse.x)
	note.time = Session.snap_y(grid.pixel_to_unit_y(mouse.y - offset_y))
	note.emit_changed()
	mode = Mode.SPAN


func _update_note():
	if note.is_chip():
		hold.hide()
		hold.disabled = true

		chip.position.x = grid.unit_to_pixel_x(note.lane)
		chip.position.y = grid.unit_to_pixel_y(note.time)

		chip.disabled = false
		chip.show()

	else:
		chip.hide()
		chip.disabled = true

		hold.position.x = grid.unit_to_pixel_x(note.lane)
		hold.position.y = grid.unit_to_pixel_y(note.time)
		hold.scale.y = hold.position.y - grid.unit_to_pixel_y(note.time + note.span)

		hold.disabled = false
		hold.show()


func _update_layer():
	if Session.layer == [Session.Layer.NOTE_BT, Session.Layer.NOTE_FX][note.type]:
		set_process_input(true)
	else:
		set_process_input(false)
		mode = Mode.NONE
