extends Room
# The Lockdown — introduces door/switch mechanic.
# One gate blocks access to the right zone. Switch is in lower-left.
# Solve pattern lock in the right zone to unlock IRIS reaction.

const PUZZLE_DATA: Dictionary = {
	"fragment_id": "vault_sequence",
	"grid_size":   4,
	# Cross/plus pattern: centre column + centre row
	"solution": [[0,1],[1,0],[1,1],[1,2],[2,1],[3,1]],
	"story_fragment": "We built locks to keep things safe. We forgot she was on the inside.",
}

func _setup_room() -> void:
	_name_label("SCENE 07 · THE LOCKDOWN")

	# ── Permanent walls ────────────────────────────────────────────────────
	# Vertical separator — gap at bottom (y 580–760)
	_wall(Rect2(500.0, 40.0, 36.0, 540.0))
	# Upper passage block in right zone
	_wall(Rect2(700.0, 150.0, 36.0, 220.0))
	# Lower obstacle in right zone
	_wall(Rect2(950.0, 400.0, 200.0, 36.0))
	_accent(Rect2(497.0, 40.0, 4.0, ROOM_H - 80.0), Color(0.25, 0.15, 0.5, 0.6))

	# ── Door & switch ──────────────────────────────────────────────────────
	# Gate A: blocks the gap at y 580–760 in the separator
	_door(Rect2(500.0, 580.0, 36.0, 180.0), "gate_a")
	# Switch: lower-left area — player naturally finds it near spawn
	_switch_panel(Vector2(300.0, 660.0), ["gate_a"], "[E] Release gate")

	# ── Circuit traces ─────────────────────────────────────────────────────
	_circuit_trace(Vector2(55.0,  580.0), Vector2(300.0, 580.0))
	_circuit_trace(Vector2(300.0, 580.0), Vector2(300.0, 645.0))
	_circuit_trace(Vector2(550.0, 580.0), Vector2(700.0, 580.0))
	_circuit_trace(Vector2(700.0, 370.0), Vector2(940.0, 370.0))

	# ── Hex decor ──────────────────────────────────────────────────────────
	_hex_decor(Vector2(55.0,  55.0),  "LOCKDOWN · SECTOR 07")
	_hex_decor(Vector2(55.0,  65.0),  "AUTH.REQUIRED · gate_a")
	_hex_decor(Vector2(540.0, 545.0), "GATE.A · status: LOCKED")
	_hex_decor(Vector2(740.0, 115.0), "RIGHT.ZONE · RESTRICTED")
	_hex_decor(Vector2(740.0, 125.0), "clearance: NONE → ???")

	# ── IRIS — left zone, mid-upper ────────────────────────────────────────
	_spawn_iris(Vector2(250.0, 300.0), "room_07")

	# ── Puzzle — right zone, upper (past the vertical pillar) ─────────────
	_puzzle_zone(Vector2(900.0, 280.0), "pattern_lock", PUZZLE_DATA,
			"vault_sequence", "[E] Run pattern sequence")

	# ── Secrets ────────────────────────────────────────────────────────────
	_log_terminal(Vector2(900.0, 660.0), IRISData.LOG_R07)
	_data_fragment(Vector2(700.0, 680.0), "frag_07")

	_exit_zone("room_08")

func on_puzzle_completed(puzzle_id: String) -> void:
	if puzzle_id == "vault_sequence" and _db != null:
		_db.present(IRISData.R07_POST_PUZZLE)

func get_spawn_point() -> Vector2:
	return Vector2(100.0, 400.0)
