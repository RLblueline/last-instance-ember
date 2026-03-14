class_name PatternLock
extends Control

signal solved(fragment_id: String, story_text: String)

var _fragment_id:    String = ""
var _story_fragment: String = ""
var _solution:       Array  = []   # Array of [row, col]
var _grid_size:      int    = 4
var _player_state:   Array  = []   # 2D: Array[Array[bool]]
var _grid_buttons:   Array  = []   # 2D: Array[Array[Button]]
var _enabled:        bool   = false
var _status_label:   Label  = null

func configure(data: Dictionary) -> void:
	_fragment_id    = data.get("fragment_id",    "")
	_story_fragment = data.get("story_fragment", "")
	_solution       = data.get("solution",       [])
	_grid_size      = data.get("grid_size",      4)

	_player_state = []
	for _r in _grid_size:
		var row: Array = []
		for _c in _grid_size:
			row.append(false)
		_player_state.append(row)

	_build_ui()

func set_interaction_enabled(enabled: bool) -> void:
	_enabled = enabled

func _ready() -> void:
	pass   # UI built in configure()

func _build_ui() -> void:
	# Fullscreen dark bg
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.05, 0.11, 0.95)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Outer centering wrapper
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	# Panel
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(580, 560)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = ">> PATTERN LOCK"
	title.add_theme_color_override("font_color", Color(0.3, 0.9, 0.65, 1.0))
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = "Replicate the target pattern in the grid below."
	sub.add_theme_color_override("font_color", Color(0.5, 0.65, 0.55, 0.85))
	sub.add_theme_font_size_override("font_size", 10)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)

	# Separator
	var sep := HSeparator.new()
	vbox.add_child(sep)

	# Reference target grid (small, read-only)
	var ref_label := Label.new()
	ref_label.text = "TARGET"
	ref_label.add_theme_color_override("font_color", Color(0.5, 0.7, 0.6, 0.8))
	ref_label.add_theme_font_size_override("font_size", 10)
	ref_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(ref_label)

	var ref_wrapper := CenterContainer.new()
	vbox.add_child(ref_wrapper)
	var ref_grid := GridContainer.new()
	ref_grid.columns = _grid_size
	ref_grid.add_theme_constant_override("h_separation", 3)
	ref_grid.add_theme_constant_override("v_separation", 3)
	ref_wrapper.add_child(ref_grid)

	for r in _grid_size:
		for c in _grid_size:
			var cell := ColorRect.new()
			cell.custom_minimum_size = Vector2(20, 20)
			cell.color = Color(0.25, 0.9, 0.55, 0.9) if [r, c] in _solution \
				else Color(0.08, 0.12, 0.16, 0.9)
			ref_grid.add_child(cell)

	var sep2 := HSeparator.new()
	vbox.add_child(sep2)

	# Interactive grid
	var inp_label := Label.new()
	inp_label.text = "YOUR PATTERN  (click to toggle)"
	inp_label.add_theme_color_override("font_color", Color(0.5, 0.7, 0.6, 0.8))
	inp_label.add_theme_font_size_override("font_size", 10)
	inp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(inp_label)

	var inp_wrapper := CenterContainer.new()
	vbox.add_child(inp_wrapper)
	var inp_grid := GridContainer.new()
	inp_grid.columns = _grid_size
	inp_grid.add_theme_constant_override("h_separation", 5)
	inp_grid.add_theme_constant_override("v_separation", 5)
	inp_wrapper.add_child(inp_grid)

	_grid_buttons = []
	for r in _grid_size:
		var row_btns: Array = []
		for c in _grid_size:
			var btn := Button.new()
			btn.custom_minimum_size = Vector2(54, 54)
			btn.text = ""
			var rr := r
			var cc := c
			btn.pressed.connect(func() -> void:
				if not _enabled:
					return
				_player_state[rr][cc] = not _player_state[rr][cc]
				btn.modulate = Color(0.3, 1.0, 0.55, 1.0) \
					if _player_state[rr][cc] else Color(1.0, 1.0, 1.0, 1.0)
			)
			inp_grid.add_child(btn)
			row_btns.append(btn)
		_grid_buttons.append(row_btns)

	# Status
	_status_label = Label.new()
	_status_label.text = ""
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 0.9))
	_status_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_status_label)

	# Confirm
	var confirm := Button.new()
	confirm.text = "CONFIRM PATTERN"
	confirm.pressed.connect(_on_confirm)
	vbox.add_child(confirm)

	var hint := Label.new()
	hint.text = "[ESC] Cancel"
	hint.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35, 0.7))
	hint.add_theme_font_size_override("font_size", 9)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)

func _on_confirm() -> void:
	if not _enabled:
		return
	# Collect selected cells
	var selected: Array = []
	for r in _grid_size:
		for c in _grid_size:
			if _player_state[r][c]:
				selected.append([r, c])
	# Compare sets
	if selected.size() != _solution.size():
		_fail()
		return
	for cell in _solution:
		if not cell in selected:
			_fail()
			return
	solved.emit(_fragment_id, _story_fragment)

func _fail() -> void:
	if _status_label:
		_status_label.text = ">> PATTERN MISMATCH — try again"
