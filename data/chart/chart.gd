class_name Chart
extends Resource

@export var notes: Array[Note]
@export var lasers: Array[Laser]
@export var tempos: Array[Tempo]
@export var meters: Array[Meter]


func _init(
	notes_: Array[Note] = [],
	lasers_: Array[Laser] = [],
	tempos_: Array[Tempo] = [Tempo.new()],
	meters_: Array[Meter] = [Meter.new()],
):
	notes = notes_
	lasers = lasers_
	tempos = tempos_
	meters = meters_
