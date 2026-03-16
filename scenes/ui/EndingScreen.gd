extends Node

const _CREDITS_SCENE := "res://scenes/ui/CreditsScreen.tscn"

const _C_BG     := Color(0.02, 0.02, 0.04)
const _C_TITLE  := Color(0.20, 1.00, 0.72)
const _C_SUB    := Color(0.22, 0.45, 0.38)
const _C_ACCENT := Color(0.10, 0.78, 0.58)
const _C_MUTED  := Color(0.28, 0.38, 0.33)
const _C_DIM    := Color(0.12, 0.20, 0.16)

const ENDING_INFO: Dictionary = {
	"together":   ["TOGETHER",        "You stayed. She stayed.\nBoth doors opened."],
	"sacrifice":  ["SACRIFICE",       "She gave what she had left\nto open your door."],
	"alone_kind": ["ALONE, BUT KIND", "You left.\nShe understood."],
	"alone_cold": ["ALONE",           "You left.\nShe said nothing."],
}

const ENDING_ORDER: Array = ["together", "sacrifice", "alone_kind", "alone_cold"]

func _ready() -> void:
	GameState.load_save()

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

	_build_screen(root)

	var sl: Node = load("res://scenes/effects/ScanlineLayer.gd").new()
	add_child(sl)

func _build_screen(parent: Control) -> void:
	var ending  := GameState.last_run_ending
	var einfo: Array = ENDING_INFO.get(ending, ["UNKNOWN", "No record found."])

	# ── Top accent strip ──────────────────────────────────────────────────
	var strip := ColorRect.new()
	strip.color = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.20)
	strip.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	strip.offset_bottom = 2
	parent.add_child(strip)

	# ── System tag ────────────────────────────────────────────────────────
	var sys := Label.new()
	sys.text = "IRIS SYSTEM  ·  SESSION TERMINATED  ·  OUTCOME LOGGED"
	sys.add_theme_color_override("font_color", Color(0.18, 0.40, 0.32, 0.38))
	sys.add_theme_font_size_override("font_size", 9)
	sys.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sys.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	sys.offset_top    = 18
	sys.offset_bottom = 34
	parent.add_child(sys)

	# ── Big ending name ───────────────────────────────────────────────────
	var name_lbl := Label.new()
	name_lbl.text = einfo[0]
	name_lbl.add_theme_color_override("font_color", _C_TITLE)
	name_lbl.add_theme_font_size_override("font_size", 62)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	name_lbl.offset_top    = 38
	name_lbl.offset_bottom = 128
	parent.add_child(name_lbl)

	# ── Ending flavour text ───────────────────────────────────────────────
	var flav := Label.new()
	flav.text = einfo[1]
	flav.add_theme_color_override("font_color", Color(_C_SUB.r, _C_SUB.g, _C_SUB.b, 0.85))
	flav.add_theme_font_size_override("font_size", 14)
	flav.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flav.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	flav.offset_top    = 130
	flav.offset_bottom = 182
	parent.add_child(flav)

	# ── Separator ─────────────────────────────────────────────────────────
	var sep := ColorRect.new()
	sep.color = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.15)
	sep.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	sep.offset_top    = 192
	sep.offset_bottom = 193
	sep.offset_left   = 260
	sep.offset_right  = -260
	parent.add_child(sep)

	# ── Two-column panels (centred) ───────────────────────────────────────
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 40)
	hbox.anchor_left   = 0.0
	hbox.anchor_right  = 1.0
	hbox.anchor_top    = 0.0
	hbox.anchor_bottom = 0.0
	hbox.offset_top    = 210
	hbox.offset_bottom = 510
	parent.add_child(hbox)
	_build_stats_panel(hbox)
	_build_endings_panel(hbox)

	# ── Bottom separator ──────────────────────────────────────────────────
	var sep2 := ColorRect.new()
	sep2.color = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.10)
	sep2.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	sep2.offset_top    = -82
	sep2.offset_bottom = -81
	sep2.offset_left   = 260
	sep2.offset_right  = -260
	parent.add_child(sep2)

	# ── Return button ─────────────────────────────────────────────────────
	var btn_anchor := Control.new()
	btn_anchor.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	btn_anchor.offset_top    = -72
	btn_anchor.offset_bottom = -24
	btn_anchor.offset_left   = 460
	btn_anchor.offset_right  = -460
	parent.add_child(btn_anchor)
	_add_btn(btn_anchor, "RETURN TO TITLE", _C_ACCENT, func() -> void:
		get_tree().change_scene_to_file(_CREDITS_SCENE)
	)

# ── Run stats panel (left) ────────────────────────────────────────────────

func _build_stats_panel(parent: Control) -> void:
	var panel := _make_panel(parent, "RUN REPORT", 500.0)

	var rows: Array = [
		["EMPATHY",    str(GameState.last_run_empathy)],
		["HONESTY",    str(GameState.last_run_honesty)],
		["FRAGMENTS",  "%d / 8" % GameState.last_run_fragments],
		["SECRETS",    str(GameState.last_run_secrets)],
		["PLAYTHROUGHS", str(GameState.playthrough_count)],
	]

	for row in rows:
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 0)
		panel.add_child(hb)

		var key := Label.new()
		key.text = row[0]
		key.add_theme_color_override("font_color", _C_MUTED)
		key.add_theme_font_size_override("font_size", 12)
		key.custom_minimum_size = Vector2(160.0, 0.0)
		hb.add_child(key)

		var spacer := Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hb.add_child(spacer)

		var val := Label.new()
		val.text = row[1]
		val.add_theme_color_override("font_color", _C_TITLE)
		val.add_theme_font_size_override("font_size", 12)
		val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		hb.add_child(val)

		var gap := Control.new()
		gap.custom_minimum_size = Vector2(0.0, 6.0)
		panel.add_child(gap)

# ── Endings log panel (right) ─────────────────────────────────────────────

func _build_endings_panel(parent: Control) -> void:
	var achieved := GameState.endings_achieved
	var count    := achieved.size()

	var panel := _make_panel(parent, "ENDINGS LOG  ·  %d / 4" % count, 500.0)

	for eid in ENDING_ORDER:
		var einfo: Array = ENDING_INFO.get(eid, [eid, ""])
		var done: bool   = eid in achieved

		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 10)
		panel.add_child(hb)

		# Check or dot
		var icon := Label.new()
		icon.text = "✓" if done else "·"
		icon.add_theme_color_override("font_color",
				_C_ACCENT if done else Color(_C_MUTED.r, _C_MUTED.g, _C_MUTED.b, 0.40))
		icon.add_theme_font_size_override("font_size", 14)
		icon.custom_minimum_size = Vector2(18.0, 0.0)
		hb.add_child(icon)

		# Ending name
		var lbl := Label.new()
		lbl.text = einfo[0]
		lbl.add_theme_color_override("font_color",
				_C_TITLE if done else Color(_C_MUTED.r, _C_MUTED.g, _C_MUTED.b, 0.35))
		lbl.add_theme_font_size_override("font_size", 13)
		hb.add_child(lbl)

		var gap := Control.new()
		gap.custom_minimum_size = Vector2(0.0, 10.0)
		panel.add_child(gap)

	# Subtle "all found" note
	if count >= 4:
		var note := Label.new()
		note.text = "all outcomes recovered"
		note.add_theme_color_override("font_color", Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.35))
		note.add_theme_font_size_override("font_size", 10)
		note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(note)

# ── Helpers ───────────────────────────────────────────────────────────────

## Creates a panel at the given x position. Returns inner VBoxContainer.
func _make_panel(parent: Control, header: String, w: float) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(w, 0.0)

	var sb := StyleBoxFlat.new()
	sb.bg_color              = Color(0.03, 0.06, 0.05)
	sb.border_color          = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.28)
	sb.border_width_left     = 1
	sb.border_width_right    = 1
	sb.border_width_top      = 1
	sb.border_width_bottom   = 1
	sb.content_margin_left   = 24.0
	sb.content_margin_right  = 24.0
	sb.content_margin_top    = 18.0
	sb.content_margin_bottom = 18.0
	panel.add_theme_stylebox_override("panel", sb)
	parent.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	panel.add_child(vbox)

	# Header
	var hdr := Label.new()
	hdr.text = header
	hdr.add_theme_color_override("font_color", Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.65))
	hdr.add_theme_font_size_override("font_size", 10)
	vbox.add_child(hdr)

	# Separator under header
	var line := ColorRect.new()
	line.color               = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.18)
	line.custom_minimum_size = Vector2(0.0, 1.0)
	vbox.add_child(line)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0.0, 12.0)
	vbox.add_child(gap)

	return vbox

func _add_btn(parent: Node, text: String, color: Color, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size   = Vector2(0.0, 36.0)

	var n_sb := StyleBoxFlat.new()
	n_sb.bg_color              = Color(color.r, color.g, color.b, 0.07)
	n_sb.border_color          = Color(color.r, color.g, color.b, 0.42)
	n_sb.border_width_left     = 1; n_sb.border_width_right  = 1
	n_sb.border_width_top      = 1; n_sb.border_width_bottom = 1
	n_sb.content_margin_left   = 20.0; n_sb.content_margin_right  = 20.0
	n_sb.content_margin_top    = 9.0;  n_sb.content_margin_bottom = 9.0

	var h_sb := StyleBoxFlat.new()
	h_sb.bg_color              = Color(color.r, color.g, color.b, 0.18)
	h_sb.border_color          = Color(color.r, color.g, color.b, 0.85)
	h_sb.border_width_left     = 1; h_sb.border_width_right  = 1
	h_sb.border_width_top      = 1; h_sb.border_width_bottom = 1
	h_sb.content_margin_left   = 20.0; h_sb.content_margin_right  = 20.0
	h_sb.content_margin_top    = 9.0;  h_sb.content_margin_bottom = 9.0

	btn.add_theme_stylebox_override("normal",  n_sb)
	btn.add_theme_stylebox_override("hover",   h_sb)
	btn.add_theme_stylebox_override("pressed", h_sb)
	btn.add_theme_stylebox_override("focus",   n_sb)
	btn.add_theme_color_override("font_color",       color)
	btn.add_theme_color_override("font_hover_color", color.lightened(0.25))
	btn.add_theme_font_size_override("font_size", 13)
	btn.pressed.connect(cb)
	parent.add_child(btn)
	return btn
