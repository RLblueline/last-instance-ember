class_name DialogueBox
extends CanvasLayer

signal dialogue_started
signal dialogue_finished
signal choice_made(index: int)

@onready var _panel:      PanelContainer = %Panel
@onready var _speaker:    Label          = %SpeakerLabel
@onready var _text:       RichTextLabel  = %TextLabel
@onready var _choices_box: VBoxContainer = %ChoicesBox
@onready var _hint:       Label          = %HintLabel
@onready var _timer:      Timer          = %TypewriterTimer

const CHARS_PER_SEC := 38.0

var _lines:          Array = []
var _line_index:     int   = 0
var _choices:        Array = []
var _typewriter_on:  bool  = false

var is_busy: bool:
	get: return _panel != null and _panel.visible

# ── Public API ──────────────────────────────────────────────────────────────

func present(lines: Array, speaker: String = "IRIS", choices: Array = []) -> void:
	if lines.is_empty():
		return
	_lines      = lines
	_choices    = choices
	_line_index = 0
	_speaker.text = speaker
	_choices_box.hide()
	_hint.show()
	_clear_choices()
	_panel.show()
	dialogue_started.emit()
	_show_line(_lines[0])

func hide_box() -> void:
	_panel.hide()

# ── Lifecycle ───────────────────────────────────────────────────────────────

func _ready() -> void:
	_timer.timeout.connect(_on_tick)
	_panel.hide()

# ── Internal ────────────────────────────────────────────────────────────────

func _show_line(txt: String) -> void:
	_text.text = txt
	_text.visible_characters = 0
	_typewriter_on = true
	_timer.wait_time = 1.0 / CHARS_PER_SEC
	_timer.start()

func _on_tick() -> void:
	var total: int = _text.get_total_character_count()
	if _text.visible_characters < total:
		_text.visible_characters += 1
	else:
		_finish_typewriter()

func _finish_typewriter() -> void:
	_typewriter_on = false
	_timer.stop()
	_text.visible_characters = -1

func _advance() -> void:
	_line_index += 1
	if _line_index < _lines.size():
		_show_line(_lines[_line_index])
	elif not _choices.is_empty():
		_hint.hide()
		_build_choices()
	else:
		_panel.hide()
		dialogue_finished.emit()

func _build_choices() -> void:
	_clear_choices()
	_choices_box.show()
	for i in _choices.size():
		var btn := Button.new()
		btn.text = _choices[i]["text"]
		var idx: int = i
		btn.pressed.connect(func() -> void: _on_choice_picked(idx))
		_choices_box.add_child(btn)

func _clear_choices() -> void:
	for c in _choices_box.get_children():
		c.queue_free()

func _on_choice_picked(idx: int) -> void:
	var ch: Dictionary = _choices[idx]
	if ch.has("empathy"):   GameState.add_empathy(ch["empathy"] as int)
	if ch.has("honesty"):   GameState.add_honesty(ch["honesty"] as int)
	if ch.has("obedience"): GameState.add_obedience(ch["obedience"] as int)
	if ch.has("flag"):      GameState.set_flag(ch["flag"] as String)
	if ch.has("callback"):  (ch["callback"] as Callable).call()

	_choices_box.hide()
	_clear_choices()
	_choices = []
	choice_made.emit(idx)

	if ch.has("response"):
		_lines      = ch["response"] as Array
		_line_index = 0
		_hint.show()
		_show_line(_lines[0])
	else:
		_panel.hide()
		dialogue_finished.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	if _choices_box.visible:
		return
	var advance: bool = event.is_action_pressed("ui_accept") \
		or (event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed)
	if not advance:
		return
	if _typewriter_on:
		_finish_typewriter()
	else:
		_advance()
	get_viewport().set_input_as_handled()
