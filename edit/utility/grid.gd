class_name Grid
extends Resource

@export_group("Unit Grid", "unit_")
@export var unit_left: float
@export var unit_right: float
@export var unit_bottom: float
@export var unit_top: float

@export_group("Pixel Grid", "pixel_")
@export var pixel_left: float
@export var pixel_right: float
@export var pixel_bottom: float
@export var pixel_top: float


func _init(
	unit_left_: float = 0.0,
	unit_right_: float = 0.0,
	unit_bottom_: float = 0.0,
	unit_top_: float = 0.0,
	pixel_left_: float = 0.0,
	pixel_right_: float = 0.0,
	pixel_bottom_: float = 0.0,
	pixel_top_: float = 0.0,
):
	unit_left = unit_left_
	unit_right = unit_right_
	unit_bottom = unit_bottom_
	unit_top = unit_top_
	pixel_left = pixel_left_
	pixel_right = pixel_right_
	pixel_bottom = pixel_bottom_
	pixel_top = pixel_top_


func unit_to_pixel_x(value: float) -> float:
	return roundf(remap(value, unit_left, unit_right, pixel_left, pixel_right))


func unit_to_pixel_y(value: float) -> float:
	return floorf(remap(value - Session.scroll, unit_bottom, unit_top, pixel_bottom, pixel_top * Session.zoom))


func unit_to_pixel(point: Vector2) -> Vector2:
	return Vector2(unit_to_pixel_x(point.x), unit_to_pixel_y(point.y))


func pixel_to_unit_x(value: float) -> float:
	return clampf(roundf(remap(value, pixel_left, pixel_right, unit_left, unit_right)), unit_left, unit_right)


func pixel_to_unit_y(value: float) -> float:
	return maxf(floorf(roundf(remap(value, pixel_bottom, pixel_top, unit_bottom, unit_top / Session.zoom))) + Session.scroll, unit_bottom)


func pixel_to_unit(point: Vector2) -> Vector2:
	return Vector2(pixel_to_unit_x(point.x), pixel_to_unit_y(point.y))
