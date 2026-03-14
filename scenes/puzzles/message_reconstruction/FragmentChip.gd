class_name FragmentChip
extends PanelContainer

var word: String = ""
var _used: bool = false

func setup(p_word: String) -> void:
	word = p_word
	custom_minimum_size = Vector2(64, 36)
	var lbl := Label.new()
	lbl.text = p_word
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.6))
	add_child(lbl)

func set_used(value: bool) -> void:
	_used = value
	modulate.a = 0.35 if value else 1.0
	mouse_filter = MOUSE_FILTER_IGNORE if value else MOUSE_FILTER_STOP

func _get_drag_data(_at_position: Vector2) -> Variant:
	if _used:
		return null
	var preview := Label.new()
	preview.text = word
	preview.add_theme_color_override("font_color", Color(0.2, 1.0, 0.6))
	set_drag_preview(preview)
	return {"word": word, "chip": self}
