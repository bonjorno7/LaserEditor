class_name Measure
extends Resource

@export var time: int
@export var numerator: int
@export var denominator: int


func _init(time_: int = 0, numerator_: int = 4, denominator_: int = 4):
	time = time_
	numerator = numerator_
	denominator = denominator_


func end() -> int:
	return time + span()


func span() -> int:
	@warning_ignore("integer_division")
	return 192 * numerator / denominator


func beat(num: int) -> int:
	@warning_ignore("integer_division")
	return time + 192 * num / denominator


func snap(num: int) -> int:
	@warning_ignore("integer_division")
	return time + 192 * num / Session.snap
