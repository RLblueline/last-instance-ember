extends Control

signal solved(fragment_id: String, reconstructed_text: String)

@onready var _fragments_container: HFlowContainer = %FragmentsContainer
@onready var _slots_container:     HBoxContainer   = %SlotsContainer
@onready var _reset_button:        Button          = %ResetButton

var _fragment_id:      String = ""
var _original_sentence: String = ""
var _target_words:     Array  = []
var _chips:            Array  = []  # Array[FragmentChip]
var _slots:            Array  = []  # Array[AnswerSlot]
var _pending_data:     Dictionary = {}

# ── Interface ─────────────────────────────────────────────────────────────

func configure(puzzle_data: Dictionary) -> void:
	_pending_data = puzzle_data
	if is_node_ready():
		_apply_config()

func reset_puzzle() -> void:
	_build_puzzle()

func set_interaction_enabled(enabled: bool) -> void:
	for chip: FragmentChip in _chips:
		if not chip._used:
			chip.mouse_filter = MOUSE_FILTER_STOP if enabled else MOUSE_FILTER_IGNORE
	for slot: AnswerSlot in _slots:
		slot.mouse_filter = MOUSE_FILTER_STOP if enabled else MOUSE_FILTER_IGNORE
	_reset_button.disabled = not enabled

# ── Lifecycle ─────────────────────────────────────────────────────────────

func _ready() -> void:
	_reset_button.pressed.connect(reset_puzzle)
	if not _pending_data.is_empty():
		_apply_config()

# ── Build ─────────────────────────────────────────────────────────────────

func _apply_config() -> void:
	_fragment_id       = _pending_data["fragment_id"]
	_original_sentence = _pending_data["target_sentence"]
	_target_words      = Array(_original_sentence.split(" "))
	_build_puzzle()

func _build_puzzle() -> void:
	for child in _fragments_container.get_children():
		child.queue_free()
	for child in _slots_container.get_children():
		child.queue_free()
	_chips.clear()
	_slots.clear()

	# Shuffle; guarantee at least one swap so puzzle is never pre-solved.
	var shuffled: Array = _target_words.duplicate()
	shuffled.shuffle()
	if shuffled == _target_words and shuffled.size() > 1:
		var tmp: String = shuffled[0]
		shuffled[0] = shuffled[1]
		shuffled[1] = tmp

	for word: String in shuffled:
		var chip := FragmentChip.new()
		_fragments_container.add_child(chip)
		chip.setup(word)
		_chips.append(chip)

	for _i in _target_words.size():
		var slot := AnswerSlot.new()
		_slots_container.add_child(slot)
		slot.word_placed.connect(_on_word_placed)
		_slots.append(slot)

# ── Handlers ──────────────────────────────────────────────────────────────

func _on_word_placed(_slot: AnswerSlot, _word: String,
		chip: FragmentChip, previous_chip: FragmentChip) -> void:
	if previous_chip != null:
		previous_chip.set_used(false)
	chip.set_used(true)
	_check_solution()

func _check_solution() -> void:
	for i in _slots.size():
		if _slots[i].placed_chip == null:
			return
		if _slots[i].placed_chip.word != _target_words[i]:
			return
	set_interaction_enabled(false)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(0.15, 1.0, 0.55, 1.0), 0.12)
	tween.tween_property(self, "modulate", Color(1.0,  1.0, 1.0,  1.0), 0.22)
	tween.tween_callback(func() -> void: solved.emit(_fragment_id, _original_sentence))
