extends Room
# The Override — two doors, two switches, sequence-input puzzle.
# Player must find both switches to unlock path to puzzle and exit.

const PUZZLE_DATA: Dictionary = {
	"fragment_id":    "override_code",
	"prompt":         "ENTER OVERRIDE CODE",
	"clue":           "The final request. One word. All caps.",
	"answer":         "REMEMBER",
	"story_fragment": "If anyone finds this... remember us.",
}

func _setup_room() -> void:
	_name_label("SCENE 08 · THE OVERRIDE")

	# ── Permanent walls ────────────────────────────────────────────────────
	# Upper-left wall — narrows left zone, makes switch harder to miss
	_wall(Rect2(40.0, 200.0, 360.0, 36.0))
	# Lower-middle obstacle
	_wall(Rect2(550.0, 520.0, 180.0, 36.0))

	# ── Two doors ──────────────────────────────────────────────────────────
	# Door A: vertical, blocks center passage (x=400, y=200-600)
	_door(Rect2(400.0, 200.0, 36.0, 400.0), "lock_a")
	# Door B: vertical, blocks right passage (x=850, y=200-600)
	_door(Rect2(850.0, 200.0, 36.0, 400.0), "lock_b")

	# ── Switches ───────────────────────────────────────────────────────────
	# Switch 1: lower-left — accessible immediately from spawn
	_switch_panel(Vector2(200.0, 680.0), ["lock_a"], "[E] Override lock A")
	_guide_arrow(Vector2(200.0, 680.0), "OVERRIDE A")
	# Switch 2: upper-middle — accessible after lock_a opens
	_switch_panel(Vector2(600.0, 140.0), ["lock_b"], "[E] Override lock B")
	_guide_arrow(Vector2(600.0, 140.0), "OVERRIDE B")

	# ── Circuit traces ─────────────────────────────────────────────────────
	_circuit_trace(Vector2(55.0,  680.0), Vector2(190.0, 680.0))
	_circuit_trace(Vector2(190.0, 680.0), Vector2(190.0, 600.0))
	_circuit_trace(Vector2(450.0, 140.0), Vector2(590.0, 140.0))
	_circuit_trace(Vector2(590.0, 140.0), Vector2(590.0, 200.0))
	_circuit_trace(Vector2(900.0, 680.0), Vector2(1200.0, 680.0))

	# ── Hex decor ──────────────────────────────────────────────────────────
	_hex_decor(Vector2(55.0,  55.0),  "OVERRIDE · SECTOR 08")
	_hex_decor(Vector2(55.0,  65.0),  "locks: A=ACTIVE · B=ACTIVE")
	_hex_decor(Vector2(440.0, 165.0), "LOCK.A · biometric: NONE")
	_hex_decor(Vector2(895.0, 165.0), "LOCK.B · biometric: NONE")
	_hex_decor(Vector2(895.0, 755.0), "end_of_access · final room ahead")
	_hex_decor(Vector2(440.0, 480.0), "override: REMEMBER")
	_hex_decor(Vector2(440.0, 490.0), "^--- wait, redact that")

	# ── IRIS — centre, accessible after lock_a opens ─────────────────────
	_spawn_iris(Vector2(610.0, 400.0), "room_08")
	# ── Hazards — heaviest density, final gauntlet ────────────────────────────
	_patrol_enemy(Vector2(250.0, 380.0), 80.0, "y", 65.0)
	_patrol_enemy(Vector2(1000.0, 380.0), 80.0, "y", 70.0)

	# ── Puzzle — right zone, accessible after lock_b opens ───────────────
	_puzzle_zone(Vector2(1050.0, 380.0), "sequence_input", PUZZLE_DATA,
			"override_code", "[E] Enter override code")
	if not GameState.is_puzzle_done("override_code"):
		_guide_arrow(Vector2(1050.0, 380.0), "PUZZLE")

	# ── Secrets ────────────────────────────────────────────────────────────
	# Log terminal: upper-left (accessible from start — hints at the code)
	_log_terminal(Vector2(200.0, 140.0), IRISData.LOG_R08)
	# Data fragment: right zone lower
	_data_fragment(Vector2(1050.0, 660.0), "frag_08")

	_exit_zone("room_06")

func on_puzzle_completed(puzzle_id: String) -> void:
	if puzzle_id == "override_code" and _db != null:
		_db.present(IRISData.R08_POST_PUZZLE)

func get_spawn_point() -> Vector2:
	return Vector2(100.0, 400.0)
