extends Node2D

const SceneNoteBT := preload("uid://bkkgp5n3jyo2c")
const SceneNoteFX := preload("uid://djgt7qokipgfd")
const SceneLaser := preload("uid://b4jxsbo5qdeyl")
const SceneTempo := preload("uid://dd4bwv6cer0rs")
const SceneMeter := preload("uid://p5bchy5rgcw6")

@export var grid: Grid
@export var color_dimmed: Color

@onready var notes_bt := %NotesBT
@onready var notes_fx := %NotesFX
@onready var lasers_l := %LasersL
@onready var lasers_r := %LasersR
@onready var tempos := %Tempos
@onready var meters := %Meters


func _ready():
	get_viewport().size_changed.connect(_on_size_changed)

	Session.scroll_changed.connect(queue_redraw)
	Session.zoom_changed.connect(queue_redraw)
	Session.snap_changed.connect(queue_redraw)
	Session.layer_changed.connect(_on_layer_changed)
	Session.measures_changed.connect(queue_redraw)

	_on_size_changed()
	_on_layer_changed()

	load_chart()


func _input(event: InputEvent):
	if event.is_action_pressed("home"):
		Session.reset_scroll()
		Session.reset_zoom()
		Session.reset_snap()
		Session.reset_layer()

	elif event.is_action_pressed("layer_note_bt"):
		Session.layer = Session.Layer.NOTE_BT
	elif event.is_action_pressed("layer_note_fx"):
		Session.layer = Session.Layer.NOTE_FX
	elif event.is_action_pressed("layer_laser_l"):
		Session.layer = Session.Layer.LASER_L
	elif event.is_action_pressed("layer_laser_r"):
		Session.layer = Session.Layer.LASER_R

	elif event.is_action_pressed("scroll_up"):
		if event.alt_pressed:
			Session.increase_layer()
		elif event.shift_pressed:
			Session.increase_snap()
		elif event.ctrl_pressed:
			Session.increase_zoom()
		else:
			Session.increase_scroll()

	elif event.is_action_pressed("scroll_down"):
		if event.alt_pressed:
			Session.decrease_layer()
		elif event.shift_pressed:
			Session.decrease_snap()
		elif event.ctrl_pressed:
			Session.decrease_zoom()
		else:
			Session.decrease_scroll()

	elif event.is_action_pressed("left_click"):
		match Session.layer:
			Session.Layer.NOTE_BT:
				_create_note_bt()
			Session.Layer.NOTE_FX:
				_create_note_fx()
			Session.Layer.LASER_L:
				_create_laser_l()
			Session.Layer.LASER_R:
				_create_laser_r()

		_create_tempo()
		_create_meter()


func _draw():
	var intervals = []
	var colors = []

	if Session.snap > 4 and Session.snap % 4 == 0:
		intervals.append(48)
		colors.append(Session.settings.color_beat_4)
	if Session.snap > 8 and Session.snap % 8 == 0:
		intervals.append(24)
		colors.append(Session.settings.color_beat_8)
	if Session.snap > 16 and Session.snap % 16 == 0:
		intervals.append(12)
		colors.append(Session.settings.color_beat_16)
	if Session.snap > 32 and Session.snap % 32 == 0:
		intervals.append(6)
		colors.append(Session.settings.color_beat_32)
	if Session.snap > 64 and Session.snap % 64 == 0:
		intervals.append(3)
		colors.append(Session.settings.color_beat_64)

	intervals.append(1)
	colors.append(Session.settings.color_beat_misc)

	for measure in Session.measures:
		if grid.unit_to_pixel_y(measure.end()) > get_viewport().size.y * 0.5:
			continue
		if grid.unit_to_pixel_y(measure.time) < get_viewport().size.y * -0.5:
			break

		var line_index := 0
		var line := measure.time
		var end := measure.end()

		while true:
			line = measure.snap(line_index)

			for snap_index in range(len(intervals)):
				if (line - measure.time) % intervals[snap_index] == 0:
					draw_line(
						Vector2(0, grid.unit_to_pixel_y(line)),
						Vector2(get_viewport().size.x, grid.unit_to_pixel_y(line)),
						colors[snap_index],
						2,
					)
					break

			line_index += 1
			line = measure.snap(line_index)

			if line >= end:
				break

	# TODO: Instead of drawing measure lines on top of the regular lines,
	# It should detect when we're drawing a measure line above here.

	draw_line(
		Vector2(0, grid.unit_to_pixel_y(0)),
		Vector2(get_viewport().size.x, grid.unit_to_pixel_y(0)),
		Session.settings.color_beat_measure,
		4,
	)

	for measure in Session.measures:
		var y := measure.end()
		draw_line(
			Vector2(0, grid.unit_to_pixel_y(y)),
			Vector2(get_viewport().size.x, grid.unit_to_pixel_y(y)),
			Session.settings.color_beat_measure,
			4,
		)


func load_chart():
	for note in Session.chart.notes:
		match note.type:
			Note.Type.BT:
				var scene := SceneNoteBT.instantiate()
				scene.note = note
				notes_bt.add_child(scene)
			Note.Type.FX:
				var scene := SceneNoteFX.instantiate()
				scene.note = note
				notes_fx.add_child(scene)

	for laser in Session.chart.lasers:
		var scene := SceneLaser.instantiate()
		scene.laser = laser
		match laser.type:
			Laser.Type.L:
				lasers_l.add_child(scene)
			Laser.Type.R:
				lasers_r.add_child(scene)

	for tempo in Session.chart.tempos:
		var scene := SceneTempo.instantiate()
		scene.tempo = tempo
		tempos.add_child(scene)

	for meter in Session.chart.meters:
		var scene := SceneMeter.instantiate()
		scene.meter = meter
		meters.add_child(scene)


func _on_size_changed():
	if is_inside_tree():  # Why is this necessary?
		position.y = get_viewport().size.y * 0.5


func _on_layer_changed():
	notes_bt.modulate = color_dimmed
	notes_fx.modulate = color_dimmed
	lasers_l.modulate = color_dimmed
	lasers_r.modulate = color_dimmed

	match Session.layer:
		Session.Layer.NOTE_BT:
			notes_bt.modulate = Color.WHITE
		Session.Layer.NOTE_FX:
			notes_fx.modulate = Color.WHITE
		Session.Layer.LASER_L:
			lasers_l.modulate = Color.WHITE
		Session.Layer.LASER_R:
			lasers_r.modulate = Color.WHITE


func _create_note_bt():
	if absf(notes_bt.get_local_mouse_position().x) < 120.0:
		var note := Note.new(Note.Type.BT)
		Session.chart.notes.append(note)
		var scene := SceneNoteBT.instantiate()
		scene.note = note
		notes_bt.add_child(scene)
		scene.setup_edit()


func _create_note_fx():
	if absf(notes_fx.get_local_mouse_position().x) < 120.0:
		var note := Note.new(Note.Type.FX)
		Session.chart.notes.append(note)
		var scene := SceneNoteFX.instantiate()
		scene.note = note
		notes_fx.add_child(scene)
		scene.setup_edit()


func _create_laser_l():
	if absf(lasers_l.get_local_mouse_position().x) < 300.0:
		var laser := Laser.new(Laser.Type.L)
		Session.chart.lasers.append(laser)
		var scene := SceneLaser.instantiate()
		scene.laser = laser
		lasers_l.add_child(scene)
		scene.setup_edit()


func _create_laser_r():
	if absf(lasers_r.get_local_mouse_position().x) < 300.0:
		var laser := Laser.new(Laser.Type.R)
		Session.chart.lasers.append(laser)
		var scene := SceneLaser.instantiate()
		scene.laser = laser
		lasers_r.add_child(scene)
		scene.setup_edit()


func _create_tempo():
	if absf(tempos.get_local_mouse_position().x) < 45.0:
		var tempo := Tempo.new()
		Session.chart.tempos.append(tempo)
		var scene := SceneTempo.instantiate()
		scene.tempo = tempo
		tempos.add_child(scene)
		scene.setup_edit()


func _create_meter():
	if absf(meters.get_local_mouse_position().x) < 45.0:
		var meter := Meter.new()
		Session.chart.meters.append(meter)
		var scene := SceneMeter.instantiate()
		scene.meter = meter
		meters.add_child(scene)
		scene.setup_edit()
