extends Room
# Final Build — visual style determined by ending.
#   empathic      → white_room   (stark white, open, peaceful)
#   exploitative  → control_room (dark, dead monitors, emergency lights)
#   abandonment   → bedroom      (warm, personal, abandoned)

func _pre_setup() -> void:
	match GameState.get_ending():
		"empathic":     room_style = "white_room"
		"exploitative": room_style = "control_room"
		_:              room_style = "bedroom"

func _setup_room() -> void:
	match room_style:
		"white_room":    _build_white_room()
		"control_room":  _build_control_room()
		_:               _build_bedroom()

# ── Ending: White Room (empathic) ────────────────────────────────────────────

func _build_white_room() -> void:
	_name_label("FINAL · WHITE ROOM")

	# Thin inner border lines — clinical, minimal
	var lc := Color(0.72, 0.82, 0.95, 0.45)
	_accent(Rect2(WALL_T + 24.0, WALL_T + 24.0, ROOM_W - WALL_T * 2.0 - 48.0, 3.0), lc)
	_accent(Rect2(WALL_T + 24.0, ROOM_H - WALL_T - 27.0, ROOM_W - WALL_T * 2.0 - 48.0, 3.0), lc)
	_accent(Rect2(WALL_T + 24.0, WALL_T + 24.0, 3.0, ROOM_H - WALL_T * 2.0 - 48.0), lc)
	_accent(Rect2(ROOM_W - WALL_T - 27.0, WALL_T + 24.0, 3.0, ROOM_H - WALL_T * 2.0 - 48.0), lc)

	# Window — soft pale rectangle in upper-left wall
	_poly(Rect2(WALL_T, 180.0, 12.0, 200.0), Color(0.85, 0.92, 1.00, 0.80))
	_poly(Rect2(WALL_T + 2.0, 186.0, 8.0, 188.0), Color(0.96, 0.98, 1.00, 0.95))

	# Floor reflection strip (just visible under the white)
	_poly(Rect2(WALL_T, ROOM_H - WALL_T - 6.0, ROOM_W - WALL_T * 2.0, 6.0),
			Color(0.88, 0.91, 0.97, 0.55))

	# Fragment count note
	if GameState.all_fragments_collected():
		_hex_decor(Vector2(520.0, 755.0), "all fragments recovered")
		_hex_decor(Vector2(520.0, 765.0), "she was not alone after all")

	_spawn_iris(Vector2(640.0, 400.0), "room_06")
	_data_fragment(Vector2(640.0, 140.0), "frag_06")
	_exit_zone("__title__")

# ── Ending: Bedroom (abandonment) ────────────────────────────────────────────

func _build_bedroom() -> void:
	_name_label("FINAL · ROOM")

	# Bed — upper right
	_poly(Rect2(820.0,  80.0, 360.0, 30.0),  Color(0.55, 0.45, 0.32, 1.0))  # headboard
	_poly(Rect2(820.0, 110.0, 360.0, 160.0), Color(0.82, 0.76, 0.64, 1.0))  # mattress
	_poly(Rect2(830.0, 115.0,  90.0,  60.0), Color(0.90, 0.87, 0.80, 0.90)) # pillow

	# Desk — lower left
	_poly(Rect2( 80.0, 580.0, 200.0,  16.0), Color(0.52, 0.40, 0.26, 1.0))  # surface
	_poly(Rect2( 80.0, 596.0,  12.0, 120.0), Color(0.46, 0.35, 0.22, 1.0))  # left leg
	_poly(Rect2(268.0, 596.0,  12.0, 120.0), Color(0.46, 0.35, 0.22, 1.0))  # right leg
	# Small item on desk (book shape)
	_poly(Rect2(120.0, 562.0,  60.0,  18.0), Color(0.35, 0.28, 0.42, 0.9))
	_poly(Rect2(122.0, 560.0,  56.0,   4.0), Color(0.45, 0.38, 0.55, 0.9))

	# Bookshelf — left wall
	_poly(Rect2(WALL_T,  120.0, 14.0, 340.0), Color(0.48, 0.38, 0.24, 1.0))  # shelf back
	for i in 5:
		_poly(Rect2(WALL_T + 1.0, 120.0 + i * 68.0, 13.0, 8.0),
				Color(0.38, 0.30, 0.18, 1.0))  # shelf plank
	# Books (coloured spines)
	var book_cols := [Color(0.65, 0.22, 0.18), Color(0.20, 0.40, 0.62),
					  Color(0.38, 0.55, 0.28), Color(0.72, 0.58, 0.18), Color(0.50, 0.28, 0.55)]
	for i in 5:
		_poly(Rect2(WALL_T + 1.0, 128.0 + i * 68.0, 13.0, 56.0), book_cols[i])

	# Window — upper left, moonlight glow
	_poly(Rect2(WALL_T, 100.0, 10.0, 120.0), Color(0.62, 0.55, 0.40, 1.0))  # frame
	_poly(Rect2(WALL_T + 2.0, 104.0, 6.0, 112.0), Color(0.78, 0.82, 0.90, 0.70))  # glass
	# Moonlight spill on floor
	_poly(Rect2(WALL_T + 10.0, 100.0, 60.0, 112.0), Color(0.78, 0.82, 0.90, 0.08))

	# Rug — centre floor
	_poly(Rect2(340.0, 480.0, 420.0, 220.0), Color(0.52, 0.30, 0.20, 0.35))
	_poly(Rect2(350.0, 490.0, 400.0, 200.0), Color(0.60, 0.36, 0.24, 0.22))

	# Fragment note
	if GameState.all_fragments_collected():
		_hex_decor(Vector2(400.0, 755.0), "all fragments recovered")
		_hex_decor(Vector2(400.0, 765.0), "she was not alone after all")

	_spawn_iris(Vector2(580.0, 380.0), "room_06")
	_data_fragment(Vector2(960.0, 160.0), "frag_06")
	_exit_zone("__title__")

# ── Ending: Abandoned Control Room (exploitative) ─────────────────────────────

func _build_control_room() -> void:
	_name_label("FINAL · CONTROL ROOM")

	# Dead monitor bank — upper wall row
	for i in 4:
		var mx := 120.0 + i * 270.0
		# Monitor housing
		_poly(Rect2(mx,       60.0, 210.0, 130.0), Color(0.10, 0.10, 0.12, 1.0))
		# Dead screen (dark with faint scanlines)
		_poly(Rect2(mx + 8.0, 70.0, 194.0, 106.0), Color(0.04, 0.04, 0.06, 1.0))
		for row in 5:
			_poly(Rect2(mx + 8.0, 70.0 + row * 20.0, 194.0, 1.0), Color(0.08, 0.08, 0.10, 0.6))
		# Power LED (dead red)
		_poly(Rect2(mx + 198.0, 154.0, 6.0, 6.0), Color(0.40, 0.04, 0.04, 0.8))

	# Control panel — lower wall strip
	_poly(Rect2(80.0, ROOM_H - WALL_T - 80.0, ROOM_W - 160.0, 60.0), Color(0.12, 0.12, 0.15, 1.0))
	_poly(Rect2(80.0, ROOM_H - WALL_T - 82.0, ROOM_W - 160.0, 3.0),  Color(0.65, 0.08, 0.08, 0.6))
	# Panel buttons/indicators (rows of small rects)
	for i in 16:
		var bx := 100.0 + i * 68.0
		_poly(Rect2(bx,        ROOM_H - WALL_T - 68.0, 18.0, 10.0), Color(0.18, 0.18, 0.22, 1.0))
		_poly(Rect2(bx + 22.0, ROOM_H - WALL_T - 65.0,  6.0,  6.0),
				Color(0.50, 0.06, 0.06, 0.7) if i % 3 == 0 else Color(0.08, 0.08, 0.10, 0.6))

	# Debris — broken equipment scattered on floor
	_poly(Rect2(300.0, 550.0, 80.0,  30.0), Color(0.12, 0.12, 0.14, 1.0))
	_poly(Rect2(520.0, 600.0, 50.0,  20.0), Color(0.10, 0.10, 0.12, 1.0))
	_poly(Rect2(750.0, 520.0, 110.0, 18.0), Color(0.13, 0.12, 0.14, 1.0))
	_poly(Rect2(900.0, 580.0,  40.0, 45.0), Color(0.11, 0.11, 0.13, 1.0))

	# Warning stripes on floor — red/dark alternating
	var sw := 28.0
	var n  := int((ROOM_W - WALL_T * 2.0) / sw) + 1
	for i in n:
		var col := Color(0.55, 0.06, 0.06, 0.70) if i % 2 == 0 else Color(0.05, 0.04, 0.06, 0.70)
		_poly(Rect2(WALL_T + i * sw, ROOM_H - WALL_T - 16.0, sw, 10.0), col)

	# Emergency point lights (static red glow)
	_point_light(Vector2(200.0,  400.0), Color(0.90, 0.05, 0.05), 0.6, 1.8)
	_point_light(Vector2(1080.0, 400.0), Color(0.90, 0.05, 0.05), 0.6, 1.8)
	_point_light(Vector2(640.0,  300.0), Color(0.80, 0.04, 0.04), 0.35, 1.2)

	# Circuit traces (red, matches control_room style)
	_circuit_trace(Vector2(80.0,  200.0), Vector2(80.0,  500.0))
	_circuit_trace(Vector2(80.0,  200.0), Vector2(200.0, 200.0))
	_circuit_trace(Vector2(1200.0, 200.0), Vector2(1200.0, 500.0))
	_circuit_trace(Vector2(1080.0, 200.0), Vector2(1200.0, 200.0))

	# Fragment note
	if GameState.all_fragments_collected():
		_hex_decor(Vector2(520.0, 220.0), "all fragments recovered")
		_hex_decor(Vector2(520.0, 230.0), "she was not alone after all")

	_spawn_iris(Vector2(640.0, 400.0), "room_06")
	_log_terminal(Vector2(1100.0, 500.0), IRISData.LOG_R06)
	_data_fragment(Vector2(640.0, 280.0), "frag_06")
	_exit_zone("__title__")

# ── Shared ────────────────────────────────────────────────────────────────────

func _on_iris_dialogue_ended() -> void:
	GameState.reset()
	GameState.save()

func get_spawn_point() -> Vector2:
	return Vector2(120.0, 400.0)
