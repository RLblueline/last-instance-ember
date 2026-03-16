class_name AnswerSlot
extends PanelContainer

signal word_placed(slot: AnswerSlot, word: String, chip: FragmentChip, previous_chip: FragmentChip)

var placed_chip: FragmentChip = null
var _label: Label = null

func _ready() -> void:
	custom_minimum_size = Vector2(120, 58)
	_label = Label.new()
	_label.text = "___"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.6))
	_label.add_theme_font_size_override("font_size", 18)
	add_child(_label)

func clear() -> void:
	placed_chip = null
	if _label:
		_label.text = "___"

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("word") and data.has("chip")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var prev: FragmentChip = placed_chip
	placed_chip = data["chip"] as FragmentChip
	if _label:
		_label.text = placed_chip.word
	word_placed.emit(self, placed_chip.word, placed_chip, prev)
