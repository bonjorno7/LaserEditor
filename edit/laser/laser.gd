extends Area2D

enum Mode { NONE, MOVE, HEAD, TAIL, BODY }

@export var laser: Laser
@export var bezier: Bezier
@export var grid_thin: Grid
@export var grid_wide: Grid

var hovering := false
var mode := Mode.NONE
var offset_head := Vector2.ZERO
var offset_tail := Vector2.ZERO
var grid := grid_thin

@onready var collision: CollisionPolygon2D = $Collision
@onready var reference: Polygon2D = $Collision/Reference


func _ready():
	laser.changed.connect(_update_samples)
	laser.changed.connect(_update_polygons)

	Session.scroll_changed.connect(_update_polygons)
	Session.zoom_changed.connect(_update_polygons)
	Session.layer_changed.connect(_update_layer)

	_update_samples()
	_update_polygons()
	_update_layer()


func _input(event: InputEvent):
	if hovering and event.is_action_pressed("left_click"):
		get_viewport().set_input_as_handled()

		var mouse := get_local_mouse_position()
		var head := grid.unit_to_pixel(laser.head)
		var tail := grid.unit_to_pixel(laser.tail)
		var threshold := head.distance_to(tail) * 0.333

		if event.shift_pressed:
			mode = Mode.MOVE
			offset_head = mouse - Vector2(grid.unit_to_pixel(laser.head))
			offset_tail = mouse - Vector2(grid.unit_to_pixel(laser.tail))
		elif mouse.distance_to(head) < threshold:
			mode = Mode.HEAD
		elif mouse.distance_to(tail) < threshold:
			mode = Mode.TAIL
		elif laser.is_curve():
			mode = Mode.BODY

	elif event.is_action_released("left_click"):
		if laser.head.y == laser.tail.y:
			Session.chart.lasers.erase(laser)
			queue_free()
		else:
			mode = Mode.NONE

	elif hovering and event.is_action_pressed("right_click"):
		get_viewport().set_input_as_handled()

		if event.shift_pressed:
			laser.body = Vector2i.ZERO
			laser.emit_changed()
		else:
			Session.chart.lasers.erase(laser)
			queue_free()

	elif hovering and event.is_action_pressed("laser_color"):
		# TODO: Reparent node.
		laser.type = Laser.Type.L if laser.type == Laser.Type.R else Laser.Type.R
		laser.emit_changed()

	elif mode != Mode.NONE:
		var mouse := get_local_mouse_position()

		match mode:
			Mode.MOVE:
				laser.head.x = grid.pixel_to_unit_x(mouse.x - offset_head.x)
				laser.head.y = Session.snap_y(grid.pixel_to_unit_y(mouse.y - offset_head.y))
				laser.tail.x = grid.pixel_to_unit_x(mouse.x - offset_tail.x)
				laser.tail.y = Session.snap_y(grid.pixel_to_unit_y(mouse.y - offset_tail.y))
			Mode.HEAD:
				laser.head.x = grid.pixel_to_unit_x(mouse.x)
				laser.head.y = Session.snap_y(grid.pixel_to_unit_y(mouse.y))
				_ensure_direction()
			Mode.TAIL:
				laser.tail.x = grid.pixel_to_unit_x(mouse.x)
				laser.tail.y = Session.snap_y(grid.pixel_to_unit_y(mouse.y))
				_ensure_direction()
			Mode.BODY:
				laser.body.x = clampi(roundi(remap(mouse.x, grid.unit_to_pixel_x(laser.head.x), grid.unit_to_pixel_x(laser.tail.x), -8, 8)), -4, 4)
				laser.body.y = clampi(roundi(remap(mouse.y, grid.unit_to_pixel_y(laser.head.y), grid.unit_to_pixel_y(laser.tail.y), -8, 8)), -4, 4)

		laser.emit_changed()


func _mouse_enter():
	hovering = true


func _mouse_exit():
	hovering = false


func setup_edit():
	var mouse := get_local_mouse_position()
	laser.head.x = grid.pixel_to_unit_x(mouse.x)
	laser.head.y = Session.snap_y(grid.pixel_to_unit_y(mouse.y))
	laser.tail = laser.head
	laser.emit_changed()
	mode = Mode.TAIL


func _ensure_direction():
	if laser.head.y > laser.tail.y:
		var temp := laser.head
		laser.head = laser.tail
		laser.tail = temp
		laser.body = -laser.body
		mode = Mode.HEAD if mode == Mode.TAIL else Mode.TAIL


func _update_samples():
	if laser.is_curve():
		var x := remap(laser.body.x, -4, 4, laser.head.x, laser.tail.x)
		var y := remap(laser.body.y, -4, 4, laser.head.y, laser.tail.y)
		laser.samples = bezier.bake(laser.head, Vector2(x, y), laser.tail)
	else:
		laser.samples.clear()


func _update_polygons():
	grid = grid_wide if laser.wide else grid_thin

	match laser.type:
		Laser.Type.L:
			modulate = Session.settings.color_laser_left
		Laser.Type.R:
			modulate = Session.settings.color_laser_right

	var vertices := PackedVector2Array()
	var uvs := PackedVector2Array()
	var indices := []

	if laser.is_curve():
		for sample in laser.samples:
			var point := Vector2(grid.unit_to_pixel(sample))

			vertices.insert(0, point - Vector2(30, 0))
			vertices.append(point + Vector2(30, 0))

			uvs.insert(0, Vector2(0, 0))
			uvs.append(Vector2(1, 0))

		for index in len(laser.samples) - 1:
			indices.append([len(vertices) - index - 1, index, index + 1, len(vertices) - index - 2])

	else:
		var head := grid.unit_to_pixel(laser.head)
		var tail := grid.unit_to_pixel(laser.tail)
		var direction := 30 if head.x <= tail.x else -30

		vertices.append(Vector2(head.x - direction, head.y))
		vertices.append(Vector2(head.x + direction, head.y))
		vertices.append(Vector2(tail.x + direction, head.y))
		vertices.append(Vector2(tail.x + direction, tail.y))
		vertices.append(Vector2(tail.x - direction, tail.y))
		vertices.append(Vector2(head.x - direction, tail.y))

		uvs.append(Vector2(0, 0))
		uvs.append(Vector2(1, 0))
		uvs.append(Vector2(1, 0))
		uvs.append(Vector2(1, 0))
		uvs.append(Vector2(0, 0))
		uvs.append(Vector2(0, 0))

		indices.append([0, 1, 5])
		indices.append([1, 2, 4, 5])
		indices.append([2, 3, 4])

	collision.polygon = vertices
	reference.polygon = vertices
	reference.uv = uvs
	reference.polygons = indices


func _update_layer():
	if Session.layer == [Session.Layer.LASER_L, Session.Layer.LASER_R][laser.type]:
		set_process_input(true)
	else:
		set_process_input(false)
		mode = Mode.NONE
