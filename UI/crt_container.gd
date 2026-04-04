extends SubViewportContainer

# Must match the shader uniforms on this node's material
const CRT_CURVATURE: float = 4.5
const MARGIN_X: float = 0.055
const MARGIN_Y: float = 0.070

func _crt_curve(uv: Vector2) -> Vector2:
	uv = (uv - Vector2(0.5, 0.5)) * 2.0
	uv.x *= 1.0 + pow(abs(uv.y) / CRT_CURVATURE, 2.0)
	uv.y *= 1.0 + pow(abs(uv.x) / CRT_CURVATURE, 2.0)
	return uv * 0.5 + Vector2(0.5, 0.5)

func _gui_input(event: InputEvent) -> void:
	var sv: SubViewport = get_child(0) as SubViewport
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		var container_uv: Vector2 = event.position / size

		# Ignore clicks in the bezel area — nothing clickable there
		if container_uv.x < MARGIN_X or container_uv.x > 1.0 - MARGIN_X or \
		   container_uv.y < MARGIN_Y or container_uv.y > 1.0 - MARGIN_Y:
			accept_event()
			return

		# Map container UV -> screen-local [0,1] -> apply forward CRT curve
		# -> SubViewport pixel. This mirrors exactly what the shader does when
		# deciding which SubViewport texel to draw at this container position.
		var screen_local: Vector2 = Vector2(
			(container_uv.x - MARGIN_X) / (1.0 - 2.0 * MARGIN_X),
			(container_uv.y - MARGIN_Y) / (1.0 - 2.0 * MARGIN_Y)
		)
		var curved: Vector2 = _crt_curve(screen_local)
		var warped_pos: Vector2 = curved * Vector2(sv.size)

		var new_event: InputEvent = event.duplicate()
		new_event.position = warped_pos
		new_event.global_position = warped_pos
		sv.push_input(new_event)
	else:
		sv.push_input(event)
	accept_event()

