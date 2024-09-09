class_name Meter
extends Resource

@export var time: int
@export var numerator: int
@export var denominator: int


func _init(time_: int = 0, numerator_: int = 4, denominator_: int = 4):
	time = time_
	numerator = numerator_
	denominator = denominator_
