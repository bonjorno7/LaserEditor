class_name Note
extends Resource

enum Type { BT, FX }

@export var type: Type
@export var lane: int
@export var time: int
@export var span: int


func _init(
	type_: Type = Type.BT,
	lane_: int = 0,
	time_: int = 0,
	span_: int = 0,
):
	type = type_
	lane = lane_
	time = time_
	span = span_


func is_chip() -> bool:
	return span == 0


func is_hold() -> bool:
	return span > 0
