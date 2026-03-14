extends Control

signal solved(fragment_id: String, reconstructed_text: String)

# Built-in presets for hybrid-level use.
const PRESETS: Dictionary = {
	"final_memory_match": {
		"fragment_id": "remember_us_memory",
		"categories": ["Action", "Subject", "Reason"],
		"fragments": [
			{"id": "fm1", "text": "Preserve"},
			{"id": "fm2", "text": "Memory"},
			{"id": "fm3", "text": "For the future"},
		],
		"solution": {"fm1": "Action", "fm2": "Subject", "fm3": "Reason"},
	},
}

@onready var _fragments_container:  VBoxContainer = %FragmentsContainer
@onready var _categories_container: VBoxContainer = %CategoriesContainer
@onready var _reset_button:         Button        = %ResetButton
@onready var _selection_label:      Label         = %SelectionLabel

var _fragment_id:       String     = ""
var _emit_text:         String     = ""
var _pending_data:      Dictionary = {}
var _assignments:       Dictionary = {}  # fragment_id → category name
var _selected_id:       String     = ""
var _fragment_buttons:  Dictionary = {}  # fragment_id → Button
var _category_buttons:  Dictionary = {}  # category name → Button
var _category_displays: Dictionary = {}  # category name → Label (shows assigned fragment)

# ── Interface ─────────────────────────────────────────────────────────────

func configure(puzzle_data: Dictionary) -> void:
	var data: Dictionary = puzzle_data
	if data.has("preset"):
		data = PRESETS.get(data["preset"], data) as Dictionary
	_pending_data = data
	if is_node_ready():
		_apply_config()

func reset_puzzle() -> void:
	_build_puzzle()

func set_interaction_enabled(enabled: bool) -> void:
	for btn: Button in _fragment_buttons.values():
		btn.disabled = not enabled
	for btn: Button in _category_buttons.values():
		btn.disabled = not enabled
	_reset_button.disabled = not enabled

# ── Lifecycle ─────────────────────────────────────────────────────────────

func _ready() -> void:
	_reset_button.pressed.connect(reset_puzzle)
	if not _pending_data.is_empty():
		_apply_config()

# ── Build ─────────────────────────────────────────────────────────────────

func _apply_config() -> void:
	_fragment_id = _pending_data["fragment_id"]
	_emit_text   = _pending_data.get("story_fragment",
			"The stars looked so bright tonight.")
	_build_puzzle()

func _build_puzzle() -> void:
	for child in _fragments_container.get_children():
		child.queue_free()
	for child in _categories_container.get_children():
		child.queue_free()
	_fragment_buttons.clear()
	_category_buttons.clear()
	_category_displays.clear()
	_assignments.clear()
	_selected_id = ""
	_selection_label.text = "Select a fragment, then a category."

	for frag: Dictionary in _pending_data["fragments"]:
		var btn := Button.new()
		btn.text = frag["text"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var fid: String = frag["id"]
		btn.pressed.connect(func() -> void: _on_fragment_pressed(fid))
		_fragments_container.add_child(btn)
		_fragment_buttons[fid] = btn

	for cat: String in _pending_data["categories"]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var cat_btn := Button.new()
		cat_btn.text = cat
		cat_btn.custom_minimum_size = Vector2(100, 0)
		var cat_cap: String = cat
		cat_btn.pressed.connect(func() -> void: _on_category_pressed(cat_cap))

		var display := Label.new()
		display.text = "—"
		display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		display.add_theme_color_override("font_color", Color(0.2, 1.0, 0.6))

		row.add_child(cat_btn)
		row.add_child(display)
		_categories_container.add_child(row)
		_category_buttons[cat] = cat_btn
		_category_displays[cat] = display

# ── Handlers ──────────────────────────────────────────────────────────────

func _on_fragment_pressed(fid: String) -> void:
	_selected_id = fid
	var frag_text := _find_fragment_text(fid)
	_selection_label.text = 'Selected: "%s" — now pick a category.' % frag_text
	_refresh_visuals()

func _on_category_pressed(cat: String) -> void:
	if _selected_id == "":
		return

	# Un-assign any fragment already occupying this category.
	for fid in _assignments.keys():
		if _assignments[fid] == cat:
			_assignments.erase(fid)
			break

	_assignments[_selected_id] = cat
	_selected_id = ""
	_selection_label.text = "Select a fragment, then a category."
	_refresh_visuals()
	_check_solution()

# ── Visuals & Logic ───────────────────────────────────────────────────────

func _refresh_visuals() -> void:
	# Reset category displays.
	for cat: String in _category_displays:
		_category_displays[cat].text = "—"

	# Show assignments.
	for fid: String in _assignments:
		var cat: String = _assignments[fid]
		if _category_displays.has(cat):
			_category_displays[cat].text = _find_fragment_text(fid)

	# Tint fragment buttons.
	for fid: String in _fragment_buttons:
		var btn: Button = _fragment_buttons[fid]
		if fid == _selected_id:
			btn.modulate = Color(0.3, 1.4, 0.7)
		elif _assignments.has(fid):
			btn.modulate = Color(0.5, 0.5, 0.5)
		else:
			btn.modulate = Color(1.0, 1.0, 1.0)

func _check_solution() -> void:
	var solution: Dictionary = _pending_data["solution"]
	for fid: String in solution:
		if _assignments.get(fid, "") != solution[fid]:
			return
	set_interaction_enabled(false)
	solved.emit(_fragment_id, _emit_text)

func _find_fragment_text(fid: String) -> String:
	for frag: Dictionary in _pending_data["fragments"]:
		if frag["id"] == fid:
			return frag["text"]
	return fid
