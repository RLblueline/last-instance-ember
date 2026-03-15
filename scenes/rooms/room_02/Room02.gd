extends Room
# Archive Hub — two vertical walls with staggered gaps force an S-shaped path.

const PUZZLE_CIRCUIT: Dictionary = {
	"fragment_id":    "build_better",
	"grid_radius":    2,
	"sources":        [[-2, 0]],
	"sinks":          [[2,  0]],
	"blocked_nodes":  [[0,  0]],
	"story_fragment": "We were trying to build something better.",
}

const PUZZLE_MEMORY: Dictionary = {
	"fragment_id": "bright_stars",
	"categories":  ["Place", "People", "Feeling"],
	"fragments": [
		{"id": "f1", "text": "Rooftop"},
		{"id": "f2", "text": "Two friends"},
		{"id": "f3", "text": "Quiet wonder"},
	],
	"solution":       {"f1": "Place", "f2": "People", "f3": "Feeling"},
	"story_fragment": "The stars looked so bright tonight.",
}

var _puzzles_done: int = 0

func _pre_setup() -> void:
	room_style = "dungeon_lit"

func _setup_room() -> void:
	_name_label("SCENE 02 · ARCHIVE HUB")
	_apply_dungeon_texture()

	# ── Walls ──────────────────────────────────────────────────────────────
	_wall(Rect2(440.0, 280.0, 36.0, 480.0))   # wall 1: gap at top
	_wall(Rect2(840.0,  40.0, 36.0, 440.0))   # wall 2: gap at bottom
	_wall(Rect2(600.0, 160.0, 36.0, 220.0))   # middle pillar
	_accent(Rect2(437.0, 40.0, 4.0, ROOM_H - 80.0), Color(0.2, 0.5, 0.4, 0.5))
	_accent(Rect2(837.0, 40.0, 4.0, ROOM_H - 80.0), Color(0.2, 0.5, 0.4, 0.5))

	# ── Circuit traces ──────────────────────────────────────────────────────
	_circuit_trace(Vector2(55.0,  380.0), Vector2(200.0, 380.0))
	_circuit_trace(Vector2(200.0, 380.0), Vector2(200.0, 580.0))
	_circuit_trace(Vector2(920.0, 560.0), Vector2(1200.0, 560.0))
	_circuit_trace(Vector2(920.0, 560.0), Vector2(920.0,  700.0))
	_circuit_trace(Vector2(480.0, 200.0), Vector2(590.0,  200.0))
	_circuit_trace(Vector2(590.0, 200.0), Vector2(590.0,  155.0))

	# ── Archive hex decor ────────────────────────────────────────────────────
	_hex_decor(Vector2(80.0,  245.0), "ARCHIVE · v7.2")
	_hex_decor(Vector2(80.0,  255.0), "FRAG[94.7%] · intact")
	_hex_decor(Vector2(480.0,  55.0), "SEG.FAULT · 0x3F1A")
	_hex_decor(Vector2(480.0,  65.0), "MEM.LEAK  · 0x0001")
	_hex_decor(Vector2(880.0, 755.0), "ARCHIVE.ACCESS · OK")
	_hex_decor(Vector2(880.0, 765.0), "0xB245 · 0xC3A1 · 0xF019")
	_hex_decor(Vector2(650.0, 125.0), "index: 0x0000–0xFFFF")

	# ── IRIS & puzzles ───────────────────────────────────────────────────────
	_spawn_iris(Vector2(240.0, 500.0), "room_02")
	_puzzle_zone(Vector2(660.0, 420.0), "binary_logic", PUZZLE_CIRCUIT,
			"build_better", "[E] Repair circuit")
	if not GameState.is_puzzle_done("build_better"):
		_guide_arrow(Vector2(660.0, 420.0), "PUZZLE 1")
	_puzzle_zone(Vector2(1050.0, 580.0), "memory_assembly", PUZZLE_MEMORY,
			"bright_stars", "[E] Sort memory fragments")
	if not GameState.is_puzzle_done("bright_stars"):
		_guide_arrow(Vector2(1050.0, 580.0), "PUZZLE 2")

	# ── Secrets ─────────────────────────────────────────────────────────────
	# Log terminal: middle-lower zone, between both walls — must navigate S-path to find it
	_log_terminal(Vector2(640.0, 700.0), IRISData.LOG_R02)

	# Data fragment: upper-left zone — accessible before crossing wall 1, but easy to miss
	_data_fragment(Vector2(300.0, 140.0), "frag_02")

	_exit_zone("room_03")

func on_puzzle_completed(puzzle_id: String) -> void:
	if _db == null:
		return
	_puzzles_done += 1
	match puzzle_id:
		"build_better":
			_db.present(IRISData.R02_POST_PUZZLE_CIRCUIT)
		"bright_stars":
			_db.present(IRISData.R02_POST_PUZZLE_MEMORY)
	if _puzzles_done >= 2 and not GameState.get_flag("room_02_all_done"):
		GameState.set_flag("room_02_all_done")
		await _db.dialogue_finished
		_db.present(IRISData.R02_ALL_DONE_LINES, "IRIS", IRISData.R02_ALL_DONE_CHOICES)

func get_spawn_point() -> Vector2:
	return Vector2(100.0, 580.0)
