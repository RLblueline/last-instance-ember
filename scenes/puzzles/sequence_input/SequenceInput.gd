class_name SequenceInput
extends Control

signal solved(fragment_id: String, story_text: String)

var _fragment_id:    String   = ""
var _story_fragment: String   = ""
var _answer:         String   = ""
var _enabled:        bool     = false
var _status_label:   Label    = null
var _input_field:    LineEdit = null

func configure(data: Dictionary) -> void:
	_fragment_id    = data.get("fragment_id",    "")
	_story_fragment = data.get("story_fragment", "")
	_answer         = (data.get("answer", "") as String).to_upper().strip_edges()
	_build_ui(data)

func set_interaction_enabled(enabled: bool) -> void:
	_enabled = enabled
	if _input_field:
		_input_field.editable = enabled

func _ready() -> void:
	pass   # UI built in configure()

func _build_ui(data: Dictionary) -> void:
	var prompt: String = data.get("prompt", "ENTER ACCESS CODE")
	var clue:   String = data.get("clue",   "")

	# Fullscreen dark bg
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.05, 0.11, 0.95)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Scanline accents (3 horizontal stripes across the panel area)
	for i in 3:
		var stripe := ColorRect.new()
		stripe.color = Color(0.1, 0.5, 0.35, 0.04)
		stripe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(stripe)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 300)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Blinking cursor title
	var title := Label.new()
	title.text = ">> TERMINAL ACCESS >_"
	title.add_theme_color_override("font_color", Color(0.3, 0.9, 0.65, 1.0))
	title.add_theme_font_size_override("font_size", 18)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	# Prompt
	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.add_theme_color_override("font_color", Color(0.75, 0.85, 0.75, 0.95))
	prompt_lbl.add_theme_font_size_override("font_size", 14)
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(prompt_lbl)

	# Clue
	if clue != "":
		var clue_lbl := Label.new()
		clue_lbl.text = "CLUE: " + clue
		clue_lbl.add_theme_color_override("font_color", Color(0.5, 0.65, 0.5, 0.78))
		clue_lbl.add_theme_font_size_override("font_size", 10)
		clue_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		clue_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(clue_lbl)

	var sep2 := HSeparator.new()
	vbox.add_child(sep2)

	# Input row
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox)

	var prefix := Label.new()
	prefix.text = ">>"
	prefix.add_theme_color_override("font_color", Color(0.3, 0.9, 0.65, 0.9))
	prefix.add_theme_font_size_override("font_size", 14)
	hbox.add_child(prefix)

	_input_field = LineEdit.new()
	_input_field.placeholder_text = "type code here..."
	_input_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_input_field.add_theme_font_size_override("font_size", 14)
	_input_field.editable = false   # enabled by set_interaction_enabled
	_input_field.text_submitted.connect(func(_t: String) -> void: _on_submit())
	hbox.add_child(_input_field)

	var submit_btn := Button.new()
	submit_btn.text = "SUBMIT"
	submit_btn.pressed.connect(_on_submit)
	hbox.add_child(submit_btn)

	# Status line
	_status_label = Label.new()
	_status_label.text = ""
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 0.9))
	_status_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_status_label)

	var hint := Label.new()
	hint.text = "[ESC] Cancel"
	hint.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35, 0.7))
	hint.add_theme_font_size_override("font_size", 9)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)

func _on_submit() -> void:
	if not _enabled or _input_field == null:
		return
	var entered := _input_field.text.to_upper().strip_edges()
	if entered == _answer:
		solved.emit(_fragment_id, _story_fragment)
	else:
		if _status_label:
			_status_label.text = ">> ACCESS DENIED — incorrect code"
		_input_field.text = ""
		_input_field.grab_focus()
