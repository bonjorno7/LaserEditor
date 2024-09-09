extends Node

signal scroll_changed
signal zoom_changed
signal snap_changed
signal layer_changed
signal measures_changed

enum Layer { NOTE_BT, NOTE_FX, LASER_L, LASER_R }

const zoom_values: PackedFloat64Array = [0.25, 0.375, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0]
const snap_values: PackedInt32Array = [4, 8, 12, 16, 24, 32, 48, 64, 96, 192]

var settings := Settings.new()
var chart := Chart.new()
var measures: Array[Measure]

var scroll := 0.0:
	set = set_scroll
var zoom := 1.0:
	set = set_zoom
var snap := 16:
	set = set_snap
var layer := Layer.NOTE_BT:
	set = set_layer


func _ready():
	update_measures()


func snap_y(y: float) -> float:
	for index in range(len(measures) - 1):
		var curr := measures[index]
		var next := measures[index + 1]

		if y < next.time:
			return minf(curr.time + snappedf(y - curr.time, 192.0 / snap), next.time)

	return snappedf(y, 192.0 / snap)


func update_measures(skip: Meter = null):
	measures.clear()

	var meters: Array[Meter] = chart.meters.duplicate()
	meters.erase(skip)
	meters.sort_custom(func(a, b): return a.time < b.time)
	meters.append(Meter.new(192000))

	var start := 0
	for index in range(len(meters) - 1):
		var curr := meters[index]
		var next := meters[index + 1]

		while start < next.time:
			var measure := Measure.new(start, curr.numerator, curr.denominator)
			measures.append(measure)
			start += measure.span()

	measures_changed.emit()


func copy_to_clipboard():
	var tick_count := 0
	var ticks: Array[Tick] = []

	for note in chart.notes:
		var time := note.time + note.span
		if time > tick_count:
			tick_count = time

	for laser in chart.lasers:
		var time = laser.tail.y
		if time > tick_count:
			tick_count = time

	for measure in measures:
		var time = measure.end()
		if time > tick_count:
			tick_count = time
			break

	for index in range(tick_count):
		ticks.append(Tick.new())

	for note in chart.notes:
		if note.is_chip():
			ticks[note.time].set_note_chip(note)
		else:
			for time in range(note.time, note.time + note.span):
				ticks[time].set_note_hold(note)

	for laser in chart.lasers:
		ticks[laser.head.y].set_laser_sample(laser, laser.head.x)
		ticks[laser.tail.y].set_laser_sample(laser, laser.tail.x)
		for index in range(laser.head.y + 1, laser.tail.y):
			ticks[index].set_laser_between(laser)
		for sample in laser.samples:
			ticks[sample.y].set_laser_sample(laser, sample.x)

	for tempo in chart.tempos:
		ticks[tempo.time].set_tempo(tempo)

	for meter in chart.meters:
		ticks[meter.time].set_meter(meter)

	for measure in measures:
		var time := measure.end() - 1
		if time >= len(ticks):
			break
		ticks[time].set_measure()

	DisplayServer.clipboard_set("\n".join(ticks))


func set_scroll(value: float):
	value = clampf(value, 0.0, 192000.0)
	if scroll != value:
		scroll = value
		scroll_changed.emit()


func reset_scroll():
	scroll = 0.0


func increase_scroll():
	scroll += 48.0 / zoom


func decrease_scroll():
	scroll -= 48.0 / zoom


func get_scroll_text() -> String:
	return str(roundi(scroll))


func set_zoom(value: float):
	value = clampf(value, 0.25, 4.0)
	if zoom != value:
		zoom = value
		zoom_changed.emit()


func reset_zoom():
	zoom = 1.0


func increase_zoom():
	for index in range(len(zoom_values)):
		if zoom < zoom_values[index]:
			zoom = zoom_values[index]
			break


func decrease_zoom():
	for index in range(len(zoom_values) - 1, -1, -1):
		if zoom > zoom_values[index]:
			zoom = zoom_values[index]
			break


func get_zoom_text() -> String:
	return String.num(zoom * 100.0, 1).pad_decimals(1) + " %"


func set_snap(value: int):
	value = clampi(value, 4, 192)
	if snap != value:
		snap = value
		snap_changed.emit()


func reset_snap():
	snap = 16


func increase_snap():
	for index in range(len(snap_values)):
		if snap < snap_values[index]:
			snap = snap_values[index]
			break


func decrease_snap():
	for index in range(len(snap_values) - 1, -1, -1):
		if snap > snap_values[index]:
			snap = snap_values[index]
			break


func get_snap_text() -> String:
	return "1 / " + str(snap)


func set_layer(value: Layer):
	value = clampi(value, 0, 3) as Layer
	if layer != value:
		layer = value
		layer_changed.emit()


func reset_layer():
	layer = Layer.NOTE_BT


func increase_layer():
	layer = (layer + 1) as Layer


func decrease_layer():
	layer = (layer - 1) as Layer


func get_layer_text() -> String:
	return ["BT", "FX", "LS-L", "LS-R"][layer]
