class_name Laser
extends Resource

enum Type { L, R }

@export var type: Type
@export var head: Vector2i
@export var tail: Vector2i
@export var body: Vector2i
@export var wide: bool

var samples: Array[Vector2i]


func _init(
	type_: Type = Type.L,
	head_: Vector2i = Vector2i.ZERO,
	tail_: Vector2i = Vector2i.ZERO,
	body_: Vector2i = Vector2i.ZERO,
	wide_: bool = false,
):
	type = type_
	head = head_
	tail = tail_
	body = body_
	wide = wide_


func is_slam() -> bool:
	return tail.y - head.y <= 6


func is_curve() -> bool:
	return tail.y - head.y > 6
