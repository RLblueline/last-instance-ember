extends Room
# Boot Build — IRIS is hidden behind a containment barrier.
# Player must activate 3 comm screens + solve the boot puzzle to trigger the reveal.

const PUZZLE_DATA: Dictionary = {
	"fragment_id":     "boot_greeting",
	"target_sentence": "I am here. I am IRIS.",
	"scramble_mode":   "shuffle_words",
	"story_fragment":  "I am here. I am IRIS.",
}

var _screens_done: int  = 0
var _puzzle_done:  bool = false

func _pre_setup() -> void:
	room_style = "torchlit"

func _setup_room() -> void:
	_name_label("SCENE 01 · BOOT BUILD")
	_apply_dungeon_texture()
	_apply_torch_lights()

	# ── SHARD hazard — introduces danger system ───────────────────────────────
	# Slow patrol near the mid-gate so the player learns to dodge
	_patrol_enemy(Vector2(310.0, 520.0), 70.0, "x", 42.0)

	# ── Containment doors ────────────────────────────────────────────────────
	# Mid-gate: blocks passage to comm screens B/C and puzzle until lever pulled
	_door(Rect2(420.0, 40.0, 36.0, 720.0), "door_mid")
	# Iris barrier: seals IRIS zone until reveal conditions met
	# (blocks exit too — player must trigger reveal to progress)
	_door(Rect2(800.0, 40.0, 36.0, 720.0), "iris_barrier")

	# ── Left zone (spawn side) ───────────────────────────────────────────────
	# Comm screen A — first contact with IRIS voice
	_comm_screen(Vector2(220.0, 320.0), IRISData.R01_BOOT_SCREEN_A,
			"[E] Boot module A", _on_screen_done)
	_guide_arrow(Vector2(220.0, 320.0), "START HERE")
	# Cool teal glow to contrast against the warm torchlight and draw the player's eye
	_point_light(Vector2(220.0, 310.0), Color(0.15, 0.90, 0.75), 0.7, 1.8)

	# Lever — pulls open the mid-gate
	_lever(Vector2(180.0, 640.0), ["door_mid"], "[E] Disengage mid-gate")
	_guide_arrow(Vector2(180.0, 640.0), "UNLOCK DOOR")

	# Collectible fragment — tucked in upper-left, rewards exploration
	_data_fragment(Vector2(100.0, 180.0), "frag_01")

	# Boot-init hex decor
	_hex_decor(Vector2(60.0,  68.0), "BOOT · seq[0x01]")
	_hex_decor(Vector2(60.0,  78.0), "init: OK · mem: OK")
	_hex_decor(Vector2(210.0, 68.0), "IRIS · v1.0.0-alpha")
	_hex_decor(Vector2(210.0, 78.0), "personality_core: loading")

	# Circuit traces — left zone
	# Full path from left wall to comm screen A so it reads as a connected terminal
	_circuit_trace(Vector2(55.0,  210.0), Vector2(130.0, 210.0))
	_circuit_trace(Vector2(130.0, 210.0), Vector2(130.0, 335.0))
	_circuit_trace(Vector2(130.0, 335.0), Vector2(190.0, 335.0))
	_circuit_trace(Vector2(190.0, 295.0), Vector2(190.0, 335.0))
	_circuit_trace(Vector2(55.0,  640.0), Vector2(145.0, 640.0))

	# ── Mid zone (accessible after lever) ───────────────────────────────────
	# Comm screen B — memory core partial boot
	_comm_screen(Vector2(570.0, 300), IRISData.R01_BOOT_SCREEN_B,
			"[E] Boot module B", _on_screen_done)

	# Comm screen C — personality matrix calibration
	_comm_screen(Vector2(680.0, 580.0), IRISData.R01_BOOT_SCREEN_C,
			"[E] Boot module C", _on_screen_done)

	# Puzzle — reconstruct the boot greeting
	_puzzle_zone(Vector2(730.0, 380.0), "message_reconstruction", PUZZLE_DATA,
			"boot_greeting", "[E] Reconstruct boot message")
	if not GameState.is_puzzle_done("boot_greeting"):
		_guide_arrow(Vector2(730.0, 380.0), "PUZZLE")
	# Softlock guard: if this puzzle was already done in a saved run, treat it as done
	if GameState.is_puzzle_done("boot_greeting"):
		_puzzle_done = true

	# Secret log terminal — hidden in lower-left of mid zone
	_log_terminal(Vector2(500.0, 690.0), IRISData.LOG_R01)

	# Hex decor — mid zone
	_hex_decor(Vector2(475.0, 68.0),  "VOICE.MOD · OK")
	_hex_decor(Vector2(475.0, 78.0),  "MEM.CORE  · 38%")
	_hex_decor(Vector2(620.0, 755.0), "PERS.MATRIX · calibrate")
	_hex_decor(Vector2(620.0, 765.0), "delta: 0.004 · stable")
	_hex_decor(Vector2(740.0, 68.0),  "boot_greeting · PENDING")

	# Circuit traces — mid zone
	_circuit_trace(Vector2(475.0, 295.0), Vector2(565.0, 295.0))
	_circuit_trace(Vector2(565.0, 215.0), Vector2(565.0, 295.0))
	_circuit_trace(Vector2(690.0, 510.0), Vector2(770.0, 510.0))
	_circuit_trace(Vector2(770.0, 380.0), Vector2(770.0, 510.0))
	_circuit_trace(Vector2(500.0, 690.0), Vector2(700.0, 690.0))

	# Admin terminal — only visible on replay, shows how many times booted
	if GameState.playthrough_count >= 1:
		_log_terminal(Vector2(630.0, 165.0),
				IRISData.admin_log_r01(GameState.playthrough_count))

	# ── IRIS zone (behind barrier — decor visible through gap) ───────────────
	_hex_decor(Vector2(858.0,  68.0), "IRIS · CONTAINMENT · ACTIVE")
	_hex_decor(Vector2(858.0,  78.0), "status: forming · ETA: pending")
	_hex_decor(Vector2(858.0, 755.0), "handshake: await · uptime: 00:00:00")

	# Circuit traces — IRIS zone (these are visible to hint something is behind the barrier)
	_circuit_trace(Vector2(860.0, 280.0), Vector2(1060.0, 280.0))
	_circuit_trace(Vector2(1060.0, 280.0), Vector2(1060.0, 480.0))
	_circuit_trace(Vector2(960.0,  480.0), Vector2(1060.0, 480.0))
	_circuit_trace(Vector2(1110.0, 560.0), Vector2(1200.0, 560.0))

	_exit_zone("room_02")

# ── Screen and puzzle tracking ───────────────────────────────────────────────

func _on_screen_done() -> void:
	_screens_done += 1
	_check_reveal()

func on_puzzle_completed(puzzle_id: String) -> void:
	if puzzle_id != "boot_greeting" or _db == null:
		return
	_puzzle_done = true
	_db.present(IRISData.R01_POST_PUZZLE)
	await _db.dialogue_finished
	_check_reveal()

func _check_reveal() -> void:
	if _screens_done < 3 or not _puzzle_done or _iris != null:
		return
	# Wait for any in-progress dialogue to finish before revealing
	if _db != null and _db.is_busy:
		await _db.dialogue_finished
	_reveal_iris()

# ── IRIS reveal ──────────────────────────────────────────────────────────────

func _reveal_iris() -> void:
	_open_door("iris_barrier")
	_iris = _IRIS_SCENE.instantiate() as IRIS
	_iris.position = Vector2(960.0, 380.0)
	add_child(_iris)
	_iris.dialogue_ended.connect(_on_iris_dialogue_ended)
	if _db != null:
		_iris.setup("room_01", _db)
	# Brief pause, then glitch flash, then first words
	await get_tree().create_timer(0.4).timeout
	_iris.trigger_glitch()
	await get_tree().create_timer(0.2).timeout
	if _db != null:
		_db.present(IRISData.R01_TRUE_FORM, "IRIS")

func get_spawn_point() -> Vector2:
	return Vector2(100.0, 400.0)
