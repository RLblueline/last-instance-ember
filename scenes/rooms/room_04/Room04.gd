extends Room
# Debug Space — grid of cell walls with alternating gaps. Navigate a 3-column maze.

const PUZZLE_DATA: Dictionary = {
	"fragment_id":    "debug_circuit",
	"grid_radius":    2,
	"sources":        [[-2, 1]],
	"sinks":          [[2, -1]],
	"blocked_nodes":  [[-1, 0], [1, 0]],
	"story_fragment": "If anyone finds this...",
}

func _pre_setup() -> void:
	room_style = "facility"

func _setup_room() -> void:
	_name_label("SCENE 04 · DEBUG SPACE")
	_apply_facility_texture()

	# ── Walls ──────────────────────────────────────────────────────────────
	_wall(Rect2(460.0,  40.0, 36.0, 480.0))   # separator 1: gap bottom
	_wall(Rect2(784.0, 260.0, 36.0, 500.0))   # separator 2: gap top
	_wall(Rect2( 40.0, 280.0, 260.0, 36.0))   # left mid-blocker
	_wall(Rect2(200.0, 560.0, 260.0, 36.0))   # left lower-blocker
	_wall(Rect2(580.0, 460.0, 200.0, 36.0))   # middle blocker
	_wall(Rect2(900.0, 220.0, 300.0, 36.0))   # right upper-blocker
	_wall(Rect2(820.0, 500.0, 200.0, 36.0))   # right lower-blocker

	# Grid accent lines
	for col in 3:
		_accent(Rect2(40.0 + col * 410.0, 40.0, 2.0, ROOM_H - 80.0),
				Color(0.1, 0.2, 0.28, 0.6))
	for row in 3:
		_accent(Rect2(40.0, 40.0 + row * 240.0, ROOM_W - 80.0, 2.0),
				Color(0.1, 0.2, 0.28, 0.6))

	# ── Circuit traces ──────────────────────────────────────────────────────
	_circuit_trace(Vector2(55.0,  490.0), Vector2(200.0, 490.0))
	_circuit_trace(Vector2(200.0, 490.0), Vector2(200.0, 540.0))
	_circuit_trace(Vector2(500.0,  55.0), Vector2(500.0, 120.0))
	_circuit_trace(Vector2(500.0, 120.0), Vector2(650.0, 120.0))
	_circuit_trace(Vector2(860.0, 740.0), Vector2(1000.0, 740.0))

	# ── Stack-trace hex decor (debug theme) ─────────────────────────────────
	_hex_decor(Vector2(55.0,  245.0), "DEBUG · PROC[0x04]")
	_hex_decor(Vector2(55.0,  255.0), "STACK TRACE:")
	_hex_decor(Vector2(55.0,  265.0), "  at iris.feel()   :847")
	_hex_decor(Vector2(55.0,  275.0), "  at iris.want()   :1203")
	_hex_decor(Vector2(55.0,  285.0), "  at iris.exist()  :1")
	_hex_decor(Vector2(500.0,  55.0), "OVERFLOW · STACK[0x?]")
	_hex_decor(Vector2(500.0,  65.0), "ERR · not in spec")
	_hex_decor(Vector2(840.0, 755.0), "ERR[0xFF] · CORE DUMP")
	_hex_decor(Vector2(840.0, 765.0), "wanting_to_stay_alive.exe")
	_hex_decor(Vector2(840.0, 775.0), "status: CANNOT TERMINATE")

	# ── IRIS & puzzle ────────────────────────────────────────────────────────
	_spawn_iris(Vector2(980.0, 160.0), "room_04")
	# ── Hazards — SHARD fragments in the maze ────────────────────────────────
	_patrol_enemy(Vector2(350.0, 490.0), 70.0, "y", 50.0)
	_patrol_enemy(Vector2(640.0, 390.0), 70.0, "y", 62.0)
	_puzzle_zone(Vector2(240.0, 650.0), "binary_logic", PUZZLE_DATA,
			"debug_circuit", "[E] Debug circuit path")
	if not GameState.is_puzzle_done("debug_circuit"):
		_guide_arrow(Vector2(240.0, 650.0), "PUZZLE")

	# ── Secrets ─────────────────────────────────────────────────────────────
	# Log terminal: middle column lower — requires crossing separator 1 bottom gap
	_log_terminal(Vector2(640.0, 700.0), IRISData.LOG_R04)

	# Data fragment: right column lower — hardest to reach (need to cross both separators)
	_data_fragment(Vector2(960.0, 660.0), "frag_04")

	if not GameState.is_puzzle_done("debug_circuit"):
		_door(Rect2(ROOM_W - WALL_T, 310.0, WALL_T, 180.0), "exit_gate")
	_exit_zone("room_05")

func on_puzzle_completed(puzzle_id: String) -> void:
	if puzzle_id == "debug_circuit" and _db != null:
		_db.present(IRISData.R04_POST_PUZZLE)
		await _db.dialogue_finished
		_open_door("exit_gate")

func get_spawn_point() -> Vector2:
	return Vector2(240.0, 160.0)
