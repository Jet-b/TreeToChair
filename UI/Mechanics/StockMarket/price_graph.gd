extends Control

var history: Array = []
var wave: Array = []
@export var line_color = Color(0.0, 0.8, 0.2)
@export var wave_color = Color(1.0, 1.0, 0.0, 0.5)
@export var fill_color = Color(0.0, 0.8, 0.2, 0.15)
@export var grid_color = Color(0.3, 0.3, 0.3, 0.4)
@export var bg_color = Color(0.05, 0.05, 0.12)
@export var text_color = Color(0.7, 0.7, 0.7)
@export var last_point_color = Color(1.0, 1.0, 1.0)
@export var GRAPH_PADDING: float = 0.1
@export var ROW_COUNT: int = 5
@export var COL_COUNT: int = 7
@export var margin: float = 30.0
@export var left_margin: float = 40.0

func set_wave(new_wave: Array) -> void:
	wave = new_wave

func set_history(new_history: Array) -> void:
	history = new_history
	queue_redraw()

func draw_background(rect) -> void:
	draw_rect(Rect2(Vector2.ZERO, rect.size), bg_color)

func draw_vertical_grid_lines(graph_x: float, graph_y: float, graph_w: float, graph_h: float) -> void:
	# Vertical grid lines
	for i in range(COL_COUNT):
		var x_frac = float(i) / float(COL_COUNT - 1)
		var x_pos = graph_x + graph_w * x_frac
		draw_line(Vector2(x_pos, graph_y), Vector2(x_pos, graph_y + graph_h), grid_color, 1.0)

func draw_horizontal_grid_lines_and_labels(graph_x: float, graph_y: float, graph_w: float, graph_h: float, min_val: float, max_val: float) -> void:
	var val_range = max_val - min_val
	for i in range(ROW_COUNT):
		var y_frac = float(i) / float(ROW_COUNT - 1)
		var y_pos = graph_y + graph_h * y_frac
		draw_line(Vector2(graph_x, y_pos), Vector2(graph_x + graph_w, y_pos), grid_color, 1.0)

		var val: float = max_val - val_range * y_frac
		var label = "%d" % int(val)
		draw_string(ThemeDB.fallback_font, Vector2(4, y_pos + 4), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, text_color)

func build_points(graph_x: float, graph_y: float, graph_w: float, graph_h: float, min_val: float, val_range: float) -> PackedVector2Array:
	var points = PackedVector2Array()
	for i in range(history.size()):
		var x = graph_x + graph_w * (float(i) / float(history.size() - 1))
		var normalized: float = (float(history[i]) - min_val) / val_range
		var y: float = graph_y + graph_h * (1.0 - normalized)
		points.append(Vector2(x, y))
	return points

func shade_under_line(points: PackedVector2Array, baseline_y: float, color: Color) -> void:
	if points.size() >= 2:
		var fill_points = PackedVector2Array()
		fill_points.append(Vector2(points[0].x, baseline_y))
		for p in points:
			fill_points.append(p)
		fill_points.append(Vector2(points[points.size() - 1].x, baseline_y))
		draw_colored_polygon(fill_points, color)

func draw_price_line(points: PackedVector2Array, color: Color) -> void:
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], color, 2.5, true)

func draw_debug_wave(graph_x: float, graph_y: float, graph_w: float, graph_h: float, min_val: float, val_range: float) -> void:
	if wave.size() >= 2:
		var wave_points = PackedVector2Array()
		for i in range(wave.size()):
			var x = graph_x + graph_w * (float(i) / float(wave.size() - 1))
			var norm: float = (float(wave[i]) - min_val) / val_range
			var y: float = graph_y + graph_h * (1.0 - norm)
			wave_points.append(Vector2(x, y))
		for i in range(wave_points.size() - 1):
			draw_line(wave_points[i], wave_points[i + 1], wave_color, 1.5, true)

func draw_last_point(points: PackedVector2Array) -> void:
	if points.size() > 0:
		draw_circle(points[points.size() - 1], 4.0, last_point_color)

func _draw() -> void:
	var rect = get_rect()
	var w = rect.size.x
	var h = rect.size.y

	# Background
	draw_background(rect)

	if history.size() < 2:
		return

	var min_val: float = history.min()
	var max_val: float = history.max()
	max_val = max_val + max_val * GRAPH_PADDING
	min_val = min_val - min_val * GRAPH_PADDING

	var val_range = max_val - min_val
	if val_range < 1.0:
		val_range = 1.0

	var graph_x = left_margin
	var graph_w = w - left_margin - margin
	var graph_y = margin
	var graph_h = h - margin * 2

	draw_vertical_grid_lines(graph_x, graph_y, graph_w, graph_h)
	draw_horizontal_grid_lines_and_labels(graph_x, graph_y, graph_w, graph_h, min_val, max_val)

	var points = build_points(graph_x, graph_y, graph_w, graph_h, min_val, val_range)
	shade_under_line(points, graph_y + graph_h, fill_color)

	draw_price_line(points, line_color)

	draw_debug_wave(graph_x, graph_y, graph_w, graph_h, min_val, val_range)

	draw_last_point(points)
