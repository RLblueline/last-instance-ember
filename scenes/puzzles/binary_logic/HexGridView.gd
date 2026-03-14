class_name HexGridView
extends Control

## Renders a hex grid (pointy-top, axial coordinates) and emits hex_clicked.

signal hex_clicked(coord: Vector2i)

const HEX_DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]

const COLORS: Dictionary = {
	"off":     Color(0.08, 0.25, 0.14, 1.0),
	"on":      Color(0.20, 0.90, 0.50, 1.0),
	"powered": Color(0.35, 1.00, 0.80, 1.0),
	"source":  Color(0.90, 0.70, 0.10, 1.0),
	"sink":    Color(0.15, 0.50, 1.00, 1.0),
	"blocked": Color(0.10, 0.10, 0.10, 1.0),
}
const BORDER     := Color(0.0, 0.0, 0.0, 0.65)
const LABEL_CLR  := Color(1.0, 1.0, 1.0, 0.9)

var hex_size: float = 36.0
var _hexes:  Array      = []       # Array[Vector2i]
var _states: Dictionary = {}       # Vector2i -> String
var _offset: Vector2    = Vector2.ZERO

# ── Public API ────────────────────────────────────────────────────────────

func init_grid(p_hexes: Array, p_size: float = 36.0) -> void:
	_hexes = p_hexes
	hex_size = p_size
	_states.clear()
	for h: Vector2i in _hexes:
		_states[h] = "off"
	_recalc_offset()
	queue_redraw()

func set_state(coord: Vector2i, s: String) -> void:
	if _states.has(coord):
		_states[coord] = s
		queue_redraw()

func get_state(coord: Vector2i) -> String:
	return _states.get(coord, "")

# ── Math ──────────────────────────────────────────────────────────────────

func _hex_to_pixel(coord: Vector2i) -> Vector2:
	# Pointy-top axial → pixel
	return Vector2(
		hex_size * (sqrt(3.0) * coord.x + sqrt(3.0) / 2.0 * coord.y),
		hex_size * (1.5 * coord.y)
	)

func _pixel_to_hex(pos: Vector2) -> Vector2i:
	var local := pos - _offset
	var q := (sqrt(3.0) / 3.0 * local.x - 1.0 / 3.0 * local.y) / hex_size
	var r := (2.0 / 3.0 * local.y) / hex_size
	return _axial_round(q, r)

func _axial_round(q: float, r: float) -> Vector2i:
	var s := -q - r
	var rq := roundi(q); var rr := roundi(r); var rs := roundi(s)
	var dq := absf(rq - q); var dr := absf(rr - r); var ds := absf(rs - s)
	if dq > dr and dq > ds:
		rq = -rr - rs
	elif dr > ds:
		rr = -rq - rs
	return Vector2i(rq, rr)

func _hex_corners(center: Vector2) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 6:
		var a := deg_to_rad(60.0 * i - 30.0)   # pointy-top: first vertex at -30°
		pts.append(center + Vector2(hex_size * cos(a), hex_size * sin(a)))
	return pts

func _recalc_offset() -> void:
	if _hexes.is_empty():
		_offset = Vector2.ZERO
		return
	var mn := Vector2(INF, INF)
	var mx := Vector2(-INF, -INF)
	for h: Vector2i in _hexes:
		var p := _hex_to_pixel(h)
		mn = mn.min(p)
		mx = mx.max(p)
	_offset = size / 2.0 - (mn + mx) / 2.0

# ── Rendering ─────────────────────────────────────────────────────────────

func _draw() -> void:
	_recalc_offset()
	var font      := ThemeDB.fallback_font
	var font_size := 11

	for h: Vector2i in _hexes:
		var center  := _hex_to_pixel(h) + _offset
		var corners := _hex_corners(center)
		var s: String = _states.get(h, "off")

		draw_polygon(corners, PackedColorArray([COLORS.get(s, COLORS["off"])]))

		var outline := PackedVector2Array(corners)
		outline.append(corners[0])
		draw_polyline(outline, BORDER, 1.5)

		var label: String = ""
		match s:
			"source":  label = "SRC"
			"sink":    label = "SNK"
			"blocked": label = "✕"
		if label != "":
			draw_string(font, center + Vector2(-12.0, 5.0), label,
					HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, LABEL_CLR)

# ── Input ─────────────────────────────────────────────────────────────────

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		var coord := _pixel_to_hex(event.position)
		if _states.has(coord):
			hex_clicked.emit(coord)
			accept_event()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_recalc_offset()
		queue_redraw()
