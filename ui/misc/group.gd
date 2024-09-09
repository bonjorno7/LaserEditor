class_name Group
extends Control

@onready var canvas := CanvasGroup.new()
@onready var control := Control.new()


func _ready():
	_update()

	for child in get_children():
		child.reparent(control, false)

	canvas.add_child(control)
	add_child(canvas)

	resized.connect(_update)
	resized.emit()


func _update():
	control.global_position = global_position
	control.size = size
	control.scale = scale
