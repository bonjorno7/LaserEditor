class_name Tempo
extends Resource

@export var time: int
@export var bpm: float


func _init(time_: int = 0, bpm_: float = 120.0):
	time = time_
	bpm = bpm_
