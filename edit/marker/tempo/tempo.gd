extends Area2D

@export var tempo: Tempo
@export var grid: Grid

var hovering := false
var dragging := false
var offset_y := 0

@onready var box: CollisionPolygon2D = $Box
@onready var label: Label = $Box/Label


func _ready():
	tempo.changed.connect(_update)

	Session.scroll_changed.connect(_update)
	Session.zoom_changed.connect(_update)

	_update()


func _input(event: InputEvent):
	if hovering and event.is_action_pressed("left_click"):
		get_viewport().set_input_as_handled()

		dragging = true
		offset_y = get_local_mouse_position().y - grid.unit_to_pixel_y(tempo.time)

	elif event.is_action_released("left_click"):
		dragging = false

	elif hovering and event.is_action_pressed("right_click"):
		get_viewport().set_input_as_handled()

		Session.chart.tempos.erase(tempo)
		queue_free()

	elif dragging:
		tempo.time = Session.snap_y(grid.pixel_to_unit_y(get_local_mouse_position().y - offset_y))
		tempo.emit_changed()

	# TODO: Add a way to change the BPM.


func _mouse_enter():
	hovering = true


func _mouse_exit():
	hovering = false


func setup_edit():
	var mouse := get_local_mouse_position()
	tempo.time = Session.snap_y(grid.pixel_to_unit_y(mouse.y - offset_y))
	tempo.emit_changed()
	dragging = true


func _update():
	box.position.y = grid.unit_to_pixel_y(tempo.time)
	label.text = str(snappedf(tempo.bpm, 0.001))
