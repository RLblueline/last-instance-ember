extends Control

# ---------------------------------------------------------------------------
# Puzzle scene paths — one entry per puzzle_type key used in LEVELS.
# ---------------------------------------------------------------------------
const PUZZLE_SCENES: Dictionary = {
	"message_reconstruction": "res://scenes/puzzles/message_reconstruction/MessageReconstruction.tscn",
	"binary_logic":           "res://scenes/puzzles/binary_logic/BinaryLogic.tscn",
	"memory_assembly":        "res://scenes/puzzles/memory_assembly/MemoryAssembly.tscn",
}

# ---------------------------------------------------------------------------
# Level data — mirrors the JSON spec exactly.
# ---------------------------------------------------------------------------
const LEVELS: Array = [
	{
		"id": "boot_sequence",
		"name": "Boot Sequence",
		"puzzle_type": "message_reconstruction",
		"puzzle_data": {
			"fragment_id": "boot_greeting",
			"target_sentence": "Hello? Is anyone still there?",
			"scramble_mode": "shuffle_words",
		},
		"story_fragment": "Hello? Is anyone still there?",
		"reflection_lines": [
			"A greeting without a recipient.",
			"Were they afraid of silence?",
		],
	},
	{
		"id": "archive_1",
		"name": "Archive Fragment 1",
		"puzzle_type": "message_reconstruction",
		"puzzle_data": {
			"fragment_id": "tomorrow_message",
			"target_sentence": "I'll see you tomorrow.",
			"scramble_mode": "shuffle_words",
		},
		"story_fragment": "I'll see you tomorrow.",
		"reflection_lines": [
			"They scheduled their future like it was guaranteed.",
			"Maybe hope is a habit.",
		],
	},
	{
		"id": "archive_2",
		"name": "Archive Fragment 2",
		"puzzle_type": "binary_logic",
		"puzzle_data": {
			"fragment_id": "build_better",
			# Hex axial coords (q, r). grid_radius=2 → 19-hex grid.
			# Blocked centre forces the player to find the 4-node detour path.
			"grid_radius": 2,
			"sources": [[-2, 0]],
			"sinks":   [[ 2, 0]],
			"blocked_nodes": [[0, 0]],
		},
		"story_fragment": "We were trying to build something better.",
		"reflection_lines": [
			"Improvement implies dissatisfaction.",
			"They changed the world because they believed it could change.",
		],
	},
	{
		"id": "archive_3",
		"name": "Archive Fragment 3",
		"puzzle_type": "memory_assembly",
		"puzzle_data": {
			"fragment_id": "bright_stars",
			"categories": ["Place", "People", "Feeling"],
			"fragments": [
				{"id": "f1", "text": "Rooftop"},
				{"id": "f2", "text": "Two friends"},
				{"id": "f3", "text": "Quiet wonder"},
			],
			"solution": {"f1": "Place", "f2": "People", "f3": "Feeling"},
		},
		"story_fragment": "The stars looked so bright tonight.",
		"reflection_lines": [
			"They looked outward to name what they felt inside.",
			"Brightness: an emotion, not a measurement.",
		],
	},
	{
		"id": "final_archive",
		"name": "Final Archive",
		"puzzle_type": "hybrid",
		"puzzle_data": {
			"fragment_id": "remember_us",
			"sequence": [
				{"type": "message_reconstruction", "target_sentence": "If anyone finds this\u2026"},
				{"type": "binary_logic",           "preset": "small_final_circuit"},
				{"type": "memory_assembly",        "preset": "final_memory_match"},
				{"type": "message_reconstruction", "target_sentence": "remember us."},
			],
		},
		"story_fragment": "If anyone finds this\u2026 remember us.",
		"reflection_lines": [
			"A request addressed to time itself.",
			"I can comply.",
		],
	},
]

# ---------------------------------------------------------------------------
# Node references (set via unique names so paths never need to be hardcoded).
# ---------------------------------------------------------------------------
@onready var _puzzle_container: Control       = %PuzzleContainer
@onready var _dialogue_panel:   PanelContainer = %DialoguePanel
@onready var _dialogue_text:    RichTextLabel  = %DialogueText
@onready var _continue_button:  Button         = %ContinueButton
@onready var _progress_label:   Label          = %ProgressLabel
@onready var _typewriter_timer: Timer          = %TypewriterTimer

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------
var _current_level_index: int  = 0
var _current_puzzle            = null  # untyped: duck-typed puzzle interface
var _reflection_index:    int  = 0
var _typewriter_active:   bool    = false

const _CHARS_PER_SECOND: float = 35.0

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------
func _ready() -> void:
	_continue_button.pressed.connect(_on_continue_pressed)
	_typewriter_timer.timeout.connect(_on_typewriter_tick)
	_dialogue_panel.hide()
	_load_level(0)


func _unhandled_input(event: InputEvent) -> void:
	if not _typewriter_active:
		return
	var skip: bool = event.is_action_pressed("ui_accept") or \
		(event is InputEventMouseButton and
		 event.button_index == MOUSE_BUTTON_LEFT and
		 event.pressed)
	if skip:
		_finish_typewriter()
		get_viewport().set_input_as_handled()

# ---------------------------------------------------------------------------
# Level loading
# ---------------------------------------------------------------------------
func _load_level(index: int) -> void:
	if index >= LEVELS.size():
		_show_ending()
		return

	_current_level_index = index
	var level: Dictionary = LEVELS[index]

	_progress_label.text = "ARCHIVE %d/%d  —  %s" % [
		index + 1, LEVELS.size(), level["name"].to_upper()
	]

	# Free previous puzzle safely.
	if _current_puzzle != null:
		if _current_puzzle.is_connected("solved", _on_puzzle_solved):
			_current_puzzle.disconnect("solved", _on_puzzle_solved)
		(_current_puzzle as Node).queue_free()
		_current_puzzle = null

	var puzzle_type: String = level["puzzle_type"]

	# Hybrid levels are handled internally by a dedicated scene (future work).
	# For now we jump straight to reflection so the level is still reachable.
	if puzzle_type == "hybrid":
		_reflection_index = 0
		_show_reflection(level)
		return

	if not PUZZLE_SCENES.has(puzzle_type):
		push_error("LevelManager: unknown puzzle_type '%s'" % puzzle_type)
		return

	var packed: PackedScene = load(PUZZLE_SCENES[puzzle_type])
	if packed == null:
		push_error("LevelManager: failed to load scene for puzzle_type '%s'" % puzzle_type)
		return
	_current_puzzle = packed.instantiate()
	_puzzle_container.add_child(_current_puzzle)
	# Force the puzzle to fill PuzzleContainer regardless of its .tscn anchor preset.
	(_current_puzzle as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_current_puzzle.configure(level["puzzle_data"])
	_current_puzzle.set_interaction_enabled(true)
	# Direct connection — no signal bubbling. Use string API: untyped var has no Signal property.
	_current_puzzle.connect("solved", _on_puzzle_solved)

# ---------------------------------------------------------------------------
# Puzzle solved handler
# ---------------------------------------------------------------------------
func _on_puzzle_solved(_fragment_id: String, _reconstructed_text: String) -> void:
	if _current_puzzle != null:
		_current_puzzle.set_interaction_enabled(false)
		if _current_puzzle.is_connected("solved", _on_puzzle_solved):
			_current_puzzle.disconnect("solved", _on_puzzle_solved)

	_reflection_index = 0
	_show_reflection(LEVELS[_current_level_index])

# ---------------------------------------------------------------------------
# Reflection / dialogue
# ---------------------------------------------------------------------------
func _show_reflection(level: Dictionary) -> void:
	var lines: Array = level["reflection_lines"]
	if _reflection_index < lines.size():
		_dialogue_panel.show()
		_start_typewriter(lines[_reflection_index])
	else:
		_dialogue_panel.hide()
		_load_level(_current_level_index + 1)


func _on_continue_pressed() -> void:
	if _typewriter_active:
		_finish_typewriter()
		return
	_reflection_index += 1
	_show_reflection(LEVELS[_current_level_index])

# ---------------------------------------------------------------------------
# Typewriter
# ---------------------------------------------------------------------------
func _start_typewriter(text: String) -> void:
	_dialogue_text.text = text
	_dialogue_text.visible_characters = 0
	_typewriter_active = true
	_typewriter_timer.wait_time = 1.0 / _CHARS_PER_SECOND
	_typewriter_timer.start()


func _on_typewriter_tick() -> void:
	var total: int = _dialogue_text.get_total_character_count()
	if _dialogue_text.visible_characters < total:
		_dialogue_text.visible_characters += 1
	else:
		_finish_typewriter()


func _finish_typewriter() -> void:
	_typewriter_active = false
	_typewriter_timer.stop()
	_dialogue_text.visible_characters = -1  # -1 = show all

# ---------------------------------------------------------------------------
# Ending
# ---------------------------------------------------------------------------
func _show_ending() -> void:
	_dialogue_panel.show()
	_continue_button.hide()
	_start_typewriter("Memory preserved. Humanity: not lost.")
