class_name Bezier
extends Resource

@export var step_size: int


func _init(step_size_: int = 0):
	step_size = step_size_


func bake(start: Vector2, middle: Vector2, end: Vector2) -> Array[Vector2i]:
	var samples: Array[Vector2i] = []

	var direction := (middle - start).cross(end - start)
	var segments := roundi((end.y - start.y) / step_size)

	for index in range(segments + 1):
		var y := roundi(remap(index, 0, segments, start.y, end.y))
		var x := roundi(_get_x(start, middle, end, y))
		samples.append(Vector2i(x, y))

	while true:
		var samples_new: Array[Vector2i] = []
		samples_new.append(samples[0])

		for index in range(1, len(samples) - 1):
			if abs(direction) < 1:
				break

			# Use inverse slope to avoid division by zero.
			var before := float(samples[index].x - samples[index - 1].x)
			before /= samples[index].y - samples[index - 1].y
			var after := float(samples[index + 1].x - samples[index].x)
			after /= samples[index + 1].y - samples[index].y

			if is_equal_approx(before, after):
				continue
			if direction > 0 and before < after:
				continue
			if direction < 0 and before > after:
				continue

			samples_new.append(samples[index])
		samples_new.append(samples[-1])

		if len(samples) > len(samples_new):
			samples = samples_new
		else:
			break

	return samples


func _get_x(start: Vector2, middle: Vector2, end: Vector2, y: float):
	if is_equal_approx(y, start.y):
		return start.x
	if is_equal_approx(y, end.y):
		return end.x

	var t = _get_t(start, middle, end, y)
	if t != null:
		return (1 - t) * (1 - t) * start.x + 2 * (1 - t) * t * middle.x + t * t * end.x


func _get_t(start: Vector2, middle: Vector2, end: Vector2, y: float):
	var a = start.y - 2 * middle.y + end.y
	var b = 2 * middle.y - 2 * start.y
	var c = start.y - y

	if is_zero_approx(a):  # Prevent division by zero.
		a = 0.00001  # Sign doesn't seem to matter.

	return _solve_quadratic(a, b, c)


func _solve_quadratic(a: float, b: float, c: float):
	var result = (-b + sqrt(b * b - 4 * a * c)) / (2 * a)
	if result >= 0 and result <= 1:
		return result

	result = (-b - sqrt(b * b - 4 * a * c)) / (2 * a)
	if result >= 0 and result <= 1:
		return result
