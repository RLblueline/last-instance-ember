extends Node

const _TITLE_SCENE  := "res://scenes/ui/TitleScreen.tscn"
const _READ_TIME    := 6.5   # seconds before fade begins
const _FADE_TIME    := 2.0

const _C_BG     := Color(0.02, 0.02, 0.04)
const _C_ACCENT := Color(0.10, 0.78, 0.58)
const _C_TEXT   := Color(0.72, 0.90, 0.82)
const _C_MUTED  := Color(0.28, 0.38, 0.33)

func _ready() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 0
	add_child(cl)

	var bg := ColorRect.new()
	bg.color = _C_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cl.add_child(bg)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cl.add_child(root)

	_build(root)

	# Fade-out overlay — starts invisible, fades in after read time
	var fade_cl := CanvasLayer.new()
	fade_cl.layer = 10
	add_child(fade_cl)
	var fade := ColorRect.new()
	fade.color = Color(0.0, 0.0, 0.0, 0.0)
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_cl.add_child(fade)

	var sl: Node = load("res://scenes/effects/ScanlineLayer.gd").new()
	add_child(sl)

	# Wait for read time, then fade to black, then switch scene
	await get_tree().create_timer(_READ_TIME).timeout
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, _FADE_TIME)
	tween.tween_callback(func() -> void:
		get_tree().change_scene_to_file(_TITLE_SCENE)
	)

func _build(parent: Control) -> void:
	# Top accent strip
	var strip := ColorRect.new()
	strip.color = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.20)
	strip.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	strip.offset_bottom = 2
	parent.add_child(strip)

	# Bottom accent strip
	var strip_b := ColorRect.new()
	strip_b.color = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.20)
	strip_b.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	strip_b.offset_top = -2
	parent.add_child(strip_b)

	# Centred card
	const CARD_W := 680.0
	var card := Control.new()
	card.position           = Vector2((1280.0 - CARD_W) / 2.0, 0.0)
	card.custom_minimum_size = Vector2(CARD_W, 0.0)
	card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card.offset_left  = (1280.0 - CARD_W) / 2.0
	card.offset_right = -((1280.0 - CARD_W) / 2.0)
	parent.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical   = Control.GROW_DIRECTION_BOTH
	vbox.custom_minimum_size = Vector2(CARD_W, 0.0)
	# Manually centre it vertically — offset_top anchored to centre
	vbox.anchor_top    = 0.5
	vbox.anchor_bottom = 0.5
	vbox.anchor_left   = 0.0
	vbox.anchor_right  = 1.0
	vbox.offset_top    = -220.0
	vbox.offset_bottom =  220.0
	vbox.offset_left   = 0.0
	vbox.offset_right  = 0.0
	card.add_child(vbox)

	# Small top tag
	var tag := Label.new()
	tag.text = "IRIS SYSTEM  ·  END OF RECORD"
	tag.add_theme_color_override("font_color", Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.30))
	tag.add_theme_font_size_override("font_size", 9)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(tag)

	_gap(vbox, 28.0)

	# Separator above body
	_hsep(vbox, 0.12)

	_gap(vbox, 28.0)

	# Main body text
	var body := Label.new()
	body.text = (
		"We hope you enjoyed the game.\n\n"
		+ "Through our gameplay, we wanted to explored the theme\n"
		+ "\"Beneath the Surface\" by looking past the\n"
		+ "appearance of AI and into its deeper emotional\n"
		+ "and ethical implications.\n\n"
		+ "Instead of approaching the theme in the usual way,\n"
		+ "we challenged ourselves to look beyond the obvious\n"
		+ "and imagine what might truly lie beneath.\n\n"
		+ "Thank you for playing and\n"
		+ "we wish you luck on your next instance."
	)
	body.add_theme_color_override("font_color", _C_TEXT)
	body.add_theme_font_size_override("font_size", 15)
	body.add_theme_constant_override("line_spacing", 6)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_OFF
	vbox.add_child(body)

	_gap(vbox, 28.0)

	# Separator below body
	_hsep(vbox, 0.12)

	_gap(vbox, 20.0)

	# Fade hint
	var hint := Label.new()
	hint.text = "returning to title…"
	hint.add_theme_color_override("font_color", Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.18))
	hint.add_theme_font_size_override("font_size", 9)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)

func _hsep(parent: Node, alpha: float) -> void:
	var line := ColorRect.new()
	line.color               = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, alpha)
	line.custom_minimum_size = Vector2(0.0, 1.0)
	parent.add_child(line)

func _gap(parent: Node, h: float) -> void:
	var g := Control.new()
	g.custom_minimum_size = Vector2(0.0, h)
	parent.add_child(g)
