extends Room
# Confrontation Layer — zigzag corridor. Two offset horizontal walls force
# the player to weave back and forth across the full room to reach IRIS.

const PUZZLE_MEMORY: Dictionary = {
	"fragment_id": "remember_us_memory",
	"categories":  ["Action", "Subject", "Reason"],
	"fragments": [
		{"id": "fm1", "text": "Preserve"},
		{"id": "fm2", "text": "Memory"},
		{"id": "fm3", "text": "For the future"},
	],
	"solution":       {"fm1": "Action", "fm2": "Subject", "fm3": "Reason"},
	"story_fragment": "Remember us.",
}

const PUZZLE_MSG: Dictionary = {
	"fragment_id":     "final_message",
	"target_sentence": "If anyone finds this REMEMBER us.",
	"scramble_mode":   "shuffle_words",
	"story_fragment":  "If anyone finds this... REMEMBER us.",
}

var _puzzles_done: int = 0

func _pre_setup() -> void:
	room_style = "facility"

func _setup_room() -> void:
	_name_label("SCENE 05 · CONFRONTATION LAYER")
	_apply_facility_texture()

	# ── Zigzag walls ──────────────────────────────────────────────────────
	_wall(Rect2( 40.0, 260.0, 820.0, 36.0))   # Wall A: open right
	_wall(Rect2(420.0, 500.0, 820.0, 36.0))   # Wall B: open left
	_wall(Rect2( 40.0, 620.0, 300.0, 36.0))   # bottom-left alcove
	_wall(Rect2(940.0, 140.0,  36.0, 120.0))  # top-right alcove blocker
	_accent(Rect2(40.0, 258.0, ROOM_W - 80.0, 4.0), Color(0.15, 0.3, 0.45, 0.6))
	_accent(Rect2(40.0, 498.0, ROOM_W - 80.0, 4.0), Color(0.15, 0.3, 0.45, 0.6))

	# ── Circuit traces ──────────────────────────────────────────────────────
	_circuit_trace(Vector2(55.0,  220.0), Vector2(300.0, 220.0))
	_circuit_trace(Vector2(300.0, 220.0), Vector2(300.0, 140.0))
	_circuit_trace(Vector2(900.0, 540.0), Vector2(1200.0, 540.0))
	_circuit_trace(Vector2(900.0, 540.0), Vector2(900.0,  650.0))

	# ── Confrontation hex decor ──────────────────────────────────────────────
	_hex_decor(Vector2(55.0,  225.0), "CONF.LAYER · 0x05")
	_hex_decor(Vector2(55.0,  235.0), "FINAL.EVAL · in progress")
	_hex_decor(Vector2(900.0, 755.0), "FINAL.PROC · RUN")
	_hex_decor(Vector2(900.0, 765.0), "outcome: [ REDACTED ]")
	_hex_decor(Vector2(460.0, 395.0), "recommend: ARCHIVE")
	_hex_decor(Vector2(460.0, 405.0), "dissent: she is a person")
	_hex_decor(Vector2(460.0, 415.0), "decision: [ REDACTED ]")

	# ── IRIS & puzzles ────────────────────────────────────────────────────
	_spawn_iris(Vector2(640.0, 400.0), "room_05")
	# ── Hazards ───────────────────────────────────────────────────────────────
	_laser_h(40.0, 280.0, 310.0)
	_patrol_enemy(Vector2(900.0, 630.0), 90.0, "x", 55.0)
	_patrol_enemy(Vector2(200.0, 390.0), 70.0, "y", 50.0)
	# Guard puzzle 2 in upper-right (hardest to reach)
	_patrol_enemy(Vector2(1050.0, 260.0), 60.0, "x", 52.0)
	_puzzle_zone(Vector2(200.0, 680.0), "memory_assembly", PUZZLE_MEMORY,
			"remember_us_memory", "[E] Sort final memory")
	if not GameState.is_puzzle_done("remember_us_memory"):
		_guide_arrow(Vector2(200.0, 680.0), "PUZZLE 1")
	_puzzle_zone(Vector2(1050.0, 160.0), "message_reconstruction", PUZZLE_MSG,
			"final_message", "[E] Reconstruct final message")
	if not GameState.is_puzzle_done("final_message"):
		_guide_arrow(Vector2(1050.0, 160.0), "PUZZLE 2")

	# ── Secrets ──────────────────────────────────────────────────────────
	# Log terminal: upper zone above Wall A (through right gap) — hard to reach
	_log_terminal(Vector2(640.0, 180.0), IRISData.LOG_R05)

	# Data fragment: left zone between the two walls — needs Wall B left gap
	_data_fragment(Vector2(200.0, 390.0), "frag_05")

	if not (GameState.is_puzzle_done("remember_us_memory") and GameState.is_puzzle_done("final_message")):
		_door(Rect2(ROOM_W - WALL_T, 310.0, WALL_T, 180.0), "exit_gate")
	_exit_zone("room_07")

func on_puzzle_completed(_puzzle_id: String) -> void:
	if _db == null:
		return
	_puzzles_done += 1
	if _puzzles_done >= 2 and not GameState.get_flag("room_05_done"):
		GameState.set_flag("room_05_done")
		_db.present(IRISData.R05_POST_PUZZLE)
		await _db.dialogue_finished
		_open_door("exit_gate")

func get_spawn_point() -> Vector2:
	return Vector2(100.0, 680.0)
