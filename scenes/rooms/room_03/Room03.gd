extends Room
# Memory Chamber — horizontal wall (left side only) forces player to find the gap
# on the right before doubling back left to reach IRIS in the upper-left area.

const PUZZLE_DATA: Dictionary = {
	"fragment_id":     "tomorrow_message",
	"target_sentence": "I'll see you tomorrow.",
	"scramble_mode":   "shuffle_words",
	"story_fragment":  "I'll see you tomorrow.",
}

func _pre_setup() -> void:
	room_style = "dungeon_lit"

func _setup_room() -> void:
	_name_label("SCENE 03 · MEMORY CHAMBER")
	_apply_dungeon_texture()

	# ── Walls ──────────────────────────────────────────────────────────────
	_wall(Rect2(40.0,  430.0, 680.0, 35.0))   # horizontal: left side only
	_wall(Rect2(820.0, 190.0,  35.0, 240.0))  # vertical pillar upper area
	_wall(Rect2(450.0, 550.0,  35.0, 210.0))  # lower blocker
	_accent(Rect2(40.0,  427.0, 680.0, 3.0), Color(0.1, 0.4, 0.5, 0.5))
	_accent(Rect2(819.0, 190.0,   3.0, 240.0), Color(0.1, 0.4, 0.5, 0.5))

	# ── Circuit traces ──────────────────────────────────────────────────────
	_circuit_trace(Vector2(760.0,  55.0), Vector2(760.0, 170.0))
	_circuit_trace(Vector2(760.0, 170.0), Vector2(900.0, 170.0))
	_circuit_trace(Vector2(55.0,  600.0), Vector2(180.0, 600.0))
	_circuit_trace(Vector2(180.0, 600.0), Vector2(180.0, 755.0))

	# ── Memory-themed hex decor ──────────────────────────────────────────────
	_hex_decor(Vector2(80.0,  395.0), "MEM[0x03] · INTACT")
	_hex_decor(Vector2(80.0,  405.0), "timestamp: 2024-03-13 · 22:41")
	_hex_decor(Vector2(760.0, 755.0), "0xDEAD · ECHO[+1]")
	_hex_decor(Vector2(760.0, 765.0), "residue · unindexed")
	_hex_decor(Vector2(860.0,  55.0), "I'll see you tomorrow.")
	_hex_decor(Vector2(860.0,  65.0), "→ parse: scheduled hope")

	# ── IRIS & puzzle ────────────────────────────────────────────────────────
	_spawn_iris(Vector2(260.0, 240.0), "room_03")
	# ── Hazard — laser across lower corridor ─────────────────────────────────
	_laser_h(40.0, 320.0, 560.0)
	_puzzle_zone(Vector2(1050.0, 240.0), "message_reconstruction", PUZZLE_DATA,
			"tomorrow_message", "[E] Decode memory fragment")
	if not GameState.is_puzzle_done("tomorrow_message"):
		_guide_arrow(Vector2(1050.0, 240.0), "PUZZLE")

	# ── Secrets ─────────────────────────────────────────────────────────────
	# Log terminal: lower-right, accessible from below the wall
	_log_terminal(Vector2(650.0, 700.0), IRISData.LOG_R03)

	# Ghost echo: floats in the middle of the gap — player stumbles into it
	_ghost_echo(Vector2(650.0, 340.0), IRISData.LOG_R03_ECHO)

	# Data fragment: upper-left near IRIS — reward for reaching her
	_data_fragment(Vector2(160.0, 160.0), "frag_03")

	if not GameState.is_puzzle_done("tomorrow_message"):
		_door(Rect2(ROOM_W - WALL_T, 310.0, WALL_T, 180.0), "exit_gate")
	_exit_zone("room_04")

func on_puzzle_completed(puzzle_id: String) -> void:
	if puzzle_id == "tomorrow_message" and _db != null:
		_db.present(IRISData.R03_POST_PUZZLE)
		await _db.dialogue_finished
		_open_door("exit_gate")

func get_spawn_point() -> Vector2:
	return Vector2(100.0, 620.0)
