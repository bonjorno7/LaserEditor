class_name Tick
extends Resource

const LASER_LANES = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmno"

var _measure := ""
var _tempo := ""
var _meter := ""
var _notes_bt := "0000"
var _notes_fx := "00"
var _lasers := "--"


func set_measure():
	_measure = "--"


func set_tempo(tempo: Tempo):
	_tempo = "t=" + str(tempo.bpm)


func set_meter(meter: Meter):
	_meter = "beat=" + str(meter.numerator) + "/" + str(meter.denominator)


func set_note_chip(note: Note):
	match note.type:
		Note.Type.BT:
			_notes_bt[note.lane] = "1"
		Note.Type.FX:
			_notes_fx[note.lane] = "2"


func set_note_hold(note: Note):
	match note.type:
		Note.Type.BT:
			_notes_bt[note.lane] = "2"
		Note.Type.FX:
			_notes_fx[note.lane] = "1"


func set_laser_sample(laser: Laser, lane: int):
	match laser.type:
		Laser.Type.L:
			_lasers[0] = LASER_LANES[lane]
		Laser.Type.R:
			_lasers[1] = LASER_LANES[lane]


func set_laser_between(laser: Laser):
	match laser.type:
		Laser.Type.L:
			_lasers[0] = ":"
		Laser.Type.R:
			_lasers[1] = ":"


func _to_string():
	var lines := PackedStringArray()
	if _tempo:
		lines.append(_tempo)
	if _meter:
		lines.append(_meter)
	lines.append("|".join([_notes_bt, _notes_fx, _lasers]))
	if _measure:
		lines.append(_measure)
	return "\n".join(lines)
