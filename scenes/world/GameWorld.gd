extends Node2D

const ROOM_SCENES: Dictionary = {
	"room_01": "res://scenes/rooms/room_01/Room01.tscn",
	"room_02": "res://scenes/rooms/room_02/Room02.tscn",
	"room_03": "res://scenes/rooms/room_03/Room03.tscn",
	"room_04": "res://scenes/rooms/room_04/Room04.tscn",
	"room_05": "res://scenes/rooms/room_05/Room05.tscn",
	"room_06": "res://scenes/rooms/room_06/Room06.tscn",
	"room_07": "res://scenes/rooms/room_07/Room07.tscn",
	"room_08": "res://scenes/rooms/room_08/Room08.tscn",
}

const PUZZLE_SCENES: Dictionary = {
	"message_reconstruction": "res://scenes/puzzles/message_reconstruction/MessageReconstruction.tscn",
	"binary_logic":           "res://scenes/puzzles/binary_logic/BinaryLogic.tscn",
	"memory_assembly":        "res://scenes/puzzles/memory_assembly/MemoryAssembly.tscn",
	"pattern_lock":           "res://scenes/puzzles/pattern_lock/PatternLock.tscn",
	"sequence_input":         "res://scenes/puzzles/sequence_input/SequenceInput.tscn",
}

@onready var _room_container: Node2D      = %RoomContainer
@onready var _player:         Player      = %Player
@onready var _dialogue_box:   DialogueBox = %DialogueBox
@onready var _puzzle_overlay: CanvasLayer = %PuzzleOverlay
@onready var _hud                         = %HUD

var _current_room       = null
var _lock_count:        int  = 0
var _canvas_modulate:   CanvasModulate = null
var _torch_overlay:     TorchOverlay   = null
var _low_health_warned: bool = false

# ── Konami code tracker ────────────────────────────────────────────────────────
const _KONAMI: Array = [
	KEY_UP, KEY_UP, KEY_DOWN, KEY_DOWN,
	KEY_LEFT, KEY_RIGHT, KEY_LEFT, KEY_RIGHT,
	KEY_Z, KEY_X,
]
var _konami_idx: int = 0

# ── Lifecycle ──────────────────────────────────────────────────────────────────

func _ready() -> void:
	_dialogue_box.dialogue_started.connect(_lock_player)
	_dialogue_box.dialogue_finished.connect(_unlock_player)
	_canvas_modulate = CanvasModulate.new()
	_canvas_modulate.color = Color(1.0, 1.0, 1.0)
	add_child(_canvas_modulate)
	_torch_overlay = load("res://scenes/effects/TorchOverlay.gd").new()
	add_child(_torch_overlay)
	_torch_overlay.setup(_player)
	_player.damaged.connect(_on_player_damaged)
	_load_room(GameState.current_room_id)
	var sl: Node = load("res://scenes/effects/ScanlineLayer.gd").new()
	add_child(sl)

func _unhandled_input(event: InputEvent) -> void:
	# ESC cancels any active puzzle
	if event.is_action_pressed("ui_cancel"):
		if _puzzle_overlay.get_child_count() > 0:
			_close_puzzle_overlay()
			get_viewport().set_input_as_handled()
			return

	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key := (event as InputEventKey).keycode

	# Konami code
	if key == _KONAMI[_konami_idx]:
		_konami_idx += 1
		if _konami_idx >= _KONAMI.size():
			_konami_idx = 0
			_on_konami()
	else:
		_konami_idx = 0

func _on_konami() -> void:
	_dialogue_box.present(IRISData.IRIS_KONAMI, "IRIS")

# ── Room management ───────────────────────────────────────────────────────────

func _load_room(room_id: String) -> void:
	if _current_room != null:
		if _current_room.is_connected("transition_requested", _on_transition):
			_current_room.disconnect("transition_requested", _on_transition)
		if _current_room.is_connected("puzzle_requested", _on_puzzle_requested):
			_current_room.disconnect("puzzle_requested", _on_puzzle_requested)
		_current_room.queue_free()
		_current_room = null

	if not ROOM_SCENES.has(room_id):
		push_error("GameWorld: unknown room '%s'" % room_id)
		return

	var packed: PackedScene = load(ROOM_SCENES[room_id])
	if packed == null:
		push_error("GameWorld: failed to load room '%s'" % room_id)
		return

	_current_room = packed.instantiate()
	_room_container.add_child(_current_room)
	_current_room.connect("transition_requested", _on_transition)
	_current_room.connect("puzzle_requested", _on_puzzle_requested)
	_current_room.set_dialogue_box(_dialogue_box)

	if _current_room.has_method("get_spawn_point"):
		_player.global_position = _current_room.get_spawn_point()

	# Constrain camera to room bounds and lock zoom to prevent seeing outside
	_player.set_camera_limits(0, 0, 1280, 800)
	_player.set_camera_zoom(Vector2(1.0, 1.0))

	GameState.current_room_id = room_id

	if _canvas_modulate:
		_set_atmosphere(_current_room.room_style)

	if _hud != null and _hud.has_method("set_room_name"):
		_hud.set_room_name(room_id)

	_lock_count = 0
	_player.set_movement_enabled(true)

func _on_transition(next_room_id: String) -> void:
	GameState.save()
	if next_room_id == "__title__":
		get_tree().change_scene_to_file.call_deferred("res://scenes/ui/EndingScreen.tscn")
		return
	call_deferred("_load_room", next_room_id)

# ── Puzzle management ─────────────────────────────────────────────────────────

func _on_puzzle_requested(puzzle_type: String, puzzle_data: Dictionary, puzzle_id: String) -> void:
	if GameState.is_puzzle_done(puzzle_id):
		return
	if _puzzle_overlay.get_child_count() > 0:
		return
	if not PUZZLE_SCENES.has(puzzle_type):
		push_error("GameWorld: unknown puzzle type '%s'" % puzzle_type)
		return

	_lock_player()

	var packed: PackedScene = load(PUZZLE_SCENES[puzzle_type])
	if packed == null:
		push_error("GameWorld: failed to load puzzle '%s'" % puzzle_type)
		_unlock_player()
		return

	var puzzle = packed.instantiate()
	_puzzle_overlay.add_child(puzzle)
	(puzzle as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	puzzle.configure(puzzle_data)
	puzzle.set_interaction_enabled(true)

	# Close button — top-right corner, works for all puzzle types
	var close_btn := Button.new()
	close_btn.text = "✕ Close"
	close_btn.anchor_left   = 1.0
	close_btn.anchor_right  = 1.0
	close_btn.anchor_top    = 0.0
	close_btn.anchor_bottom = 0.0
	close_btn.offset_left   = -110.0
	close_btn.offset_right  = -8.0
	close_btn.offset_top    = 8.0
	close_btn.offset_bottom = 38.0
	close_btn.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	_puzzle_overlay.add_child(close_btn)
	close_btn.pressed.connect(_close_puzzle_overlay)

	puzzle.connect("solved", func(_fid: String, _txt: String) -> void:
		_on_puzzle_solved(puzzle, puzzle_id)
	)

func _on_puzzle_solved(puzzle_node: Node, puzzle_id: String) -> void:
	GameState.complete_puzzle(puzzle_id)
	# Green flash then free all overlay children (puzzle + close button)
	var tween := create_tween()
	tween.tween_property(puzzle_node, "modulate", Color(0.2, 1.0, 0.55, 1.0), 0.12)
	tween.tween_property(puzzle_node, "modulate", Color(1.0, 1.0, 1.0,  1.0), 0.22)
	tween.tween_callback(func() -> void:
		for c in _puzzle_overlay.get_children():
			c.queue_free()
		if _current_room != null and _current_room.has_method("on_puzzle_completed"):
			_current_room.on_puzzle_completed(puzzle_id)
		_unlock_player()
		GameState.save()
	)

func _close_puzzle_overlay() -> void:
	for c in _puzzle_overlay.get_children():
		c.queue_free()
	_unlock_player()

# ── Player lock helpers ───────────────────────────────────────────────────────

func _on_player_damaged() -> void:
	_screen_flash(Color(0.75, 0.0, 0.0, 0.50), 0.30)
	if GameState.lives <= 0:
		_show_death_screen()
		return
	if GameState.lives == 1 and not _low_health_warned:
		_low_health_warned = true
		await get_tree().create_timer(0.5).timeout
		_dialogue_box.present(IRISData.IRIS_LOW_HEALTH, "IRIS")

func _show_death_screen() -> void:
	_lock_count = 999
	_player.set_movement_enabled(false)

	const C_RED   := Color(0.85, 0.12, 0.12)
	const C_DARK  := Color(0.40, 0.10, 0.10)

	var cl := CanvasLayer.new()
	cl.layer = 20
	add_child(cl)

	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(bg)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cl.add_child(root)

	var title := Label.new()
	title.text = "SYSTEM TERMINATED"
	title.add_theme_color_override("font_color", C_RED)
	title.add_theme_font_size_override("font_size", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_left = 0.0; title.anchor_right  = 1.0
	title.anchor_top  = 0.0; title.anchor_bottom = 0.0
	title.offset_top  = 210; title.offset_bottom = 270
	title.modulate.a  = 0.0
	root.add_child(title)

	var sub := Label.new()
	sub.text = "iris.exe has stopped running"
	sub.add_theme_color_override("font_color", C_DARK)
	sub.add_theme_font_size_override("font_size", 14)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.anchor_left = 0.0; sub.anchor_right  = 1.0
	sub.anchor_top  = 0.0; sub.anchor_bottom = 0.0
	sub.offset_top  = 278; sub.offset_bottom = 300
	sub.modulate.a  = 0.0
	root.add_child(sub)

	var hint := Label.new()
	hint.text = "returning to title…"
	hint.add_theme_color_override("font_color", Color(C_DARK.r, C_DARK.g, C_DARK.b, 0.55))
	hint.add_theme_font_size_override("font_size", 10)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.anchor_left = 0.0; hint.anchor_right  = 1.0
	hint.anchor_top  = 0.0; hint.anchor_bottom = 0.0
	hint.offset_top  = 350; hint.offset_bottom = 368
	hint.modulate.a  = 0.0
	root.add_child(hint)

	var tween := create_tween()
	tween.tween_property(bg,    "color:a",     1.0, 0.9)
	tween.parallel().tween_property(title, "modulate:a", 1.0, 0.9)
	tween.tween_interval(0.4)
	tween.tween_property(sub,   "modulate:a",  1.0, 0.5)
	tween.tween_interval(0.3)
	tween.tween_property(hint,  "modulate:a",  1.0, 0.4)
	tween.tween_interval(2.2)
	tween.tween_callback(func() -> void:
		GameState.reset()
		get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")
	)

func _screen_flash(color: Color, duration: float) -> void:
	var cl := CanvasLayer.new()
	cl.layer = 12
	add_child(cl)
	var flash := ColorRect.new()
	flash.color = color
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(flash)
	var tween := create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, duration)
	tween.tween_callback(cl.queue_free)

func _set_atmosphere(style: String) -> void:
	match style:
		"dungeon":
			# Dark room, player torch is the only light source
			_canvas_modulate.color = Color(1.0, 1.0, 1.0)
			_torch_overlay.set_radius(160.0)
			_torch_overlay.set_softness(55.0)
			_torch_overlay.set_darkness(0.97)
			_torch_overlay.set_active(true)
		"torchlit":
			# Wall torches provide warm ambient light — PointLight2D nodes live in the room
			_canvas_modulate.color = Color(0.28, 0.21, 0.12)
			_torch_overlay.set_active(false)
		"dungeon_lit":
			# Dungeon aesthetics, no dark overlay
			_canvas_modulate.color = Color(0.80, 0.72, 0.60)
			_torch_overlay.set_active(false)
		"facility":
			# Bright, clinical Portal 2 lighting — no torch
			_canvas_modulate.color = Color(0.90, 0.93, 0.98)
			_torch_overlay.set_active(false)
		"white_room":
			# Fully lit, peaceful
			_canvas_modulate.color = Color(1.0, 1.0, 1.0)
			_torch_overlay.set_active(false)
		"bedroom":
			# Warm ambient candlelight + soft torch circle
			_canvas_modulate.color = Color(0.78, 0.65, 0.48)
			_torch_overlay.set_radius(240.0)
			_torch_overlay.set_softness(80.0)
			_torch_overlay.set_darkness(0.82)
			_torch_overlay.set_active(true)
		"control_room":
			# Near-dark; emergency point lights in the room provide static illumination
			_canvas_modulate.color = Color(0.06, 0.05, 0.07)
			_torch_overlay.set_active(false)
		_:  # sci_fi (rooms 07, 08)
			_canvas_modulate.color = Color(0.65, 0.68, 0.75)
			_torch_overlay.set_active(false)

func _lock_player() -> void:
	_lock_count += 1
	_player.set_movement_enabled(false)

func _unlock_player() -> void:
	_lock_count = maxi(0, _lock_count - 1)
	if _lock_count == 0:
		_player.set_movement_enabled(true)
