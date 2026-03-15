class_name TitleScreen
extends Node

const _GAME_SCENE := "res://scenes/world/GameWorld.tscn"

const _C_BG     := Color(0.02, 0.02, 0.04)
const _C_TITLE  := Color(0.20, 1.00, 0.72)
const _C_SUB    := Color(0.22, 0.45, 0.38)
const _C_ACCENT := Color(0.10, 0.78, 0.58)
const _C_MUTED  := Color(0.28, 0.38, 0.33)
const _C_DANGER := Color(0.82, 0.22, 0.12)

var _continue_btn:  Button  = null
var _opts_panel:    Control = null
var _wipe_panel:    Control = null
var _letter_overlay: Control = null

func _ready() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 0
	add_child(cl)

	# Background
	var bg := ColorRect.new()
	bg.color = _C_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cl.add_child(bg)

	# Root control for all overlays
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cl.add_child(root)

	_build_title(root)
	_build_main_btns(root)
	_build_opts_panel(root)
	_build_wipe_panel(root)
	_build_letter_screen(root)

	# Scanlines — same as in-game
	var sl: Node = load("res://scenes/effects/ScanlineLayer.gd").new()
	add_child(sl)

# ── Title area ────────────────────────────────────────────────────────────────

func _build_title(parent: Control) -> void:
	# Top accent strip
	var strip := ColorRect.new()
	strip.color = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.20)
	strip.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	strip.offset_top    = 0
	strip.offset_bottom = 2
	parent.add_child(strip)

	# Tiny system label above title
	var sys := Label.new()
	sys.text = "IRIS SYSTEM  ·  BOOT SEQUENCE COMPLETE"
	sys.add_theme_color_override("font_color", Color(0.18, 0.40, 0.32, 0.38))
	sys.add_theme_font_size_override("font_size", 9)
	sys.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sys.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	sys.offset_top    = 168
	sys.offset_bottom = 186
	parent.add_child(sys)

	# Main title
	var title := Label.new()
	title.text = "LAST INSTANCE"
	title.add_theme_color_override("font_color", _C_TITLE)
	title.add_theme_font_size_override("font_size", 56)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top    = 184
	title.offset_bottom = 270
	parent.add_child(title)

	# Subtitle
	var sub := Label.new()
	sub.text = "— IRIS PROTOCOL —"
	sub.add_theme_color_override("font_color", _C_SUB)
	sub.add_theme_font_size_override("font_size", 13)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	sub.offset_top    = 264
	sub.offset_bottom = 290
	parent.add_child(sub)

	# Thin separator line under subtitle
	var sep := ColorRect.new()
	sep.color = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.15)
	sep.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	sep.offset_top    = 298
	sep.offset_bottom = 299
	sep.offset_left   = 400
	sep.offset_right  = -400
	parent.add_child(sep)

	# Bottom-left version tag
	var ver := Label.new()
	ver.text = "v1.0 · 0x%04X" % (hash(ProjectSettings.get("application/config/name")) & 0xFFFF)
	ver.add_theme_color_override("font_color", Color(0.16, 0.24, 0.20, 0.35))
	ver.add_theme_font_size_override("font_size", 9)
	ver.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	ver.offset_left   = 14
	ver.offset_top    = -26
	ver.offset_bottom = -8
	parent.add_child(ver)

# ── Main button list ──────────────────────────────────────────────────────────

func _build_main_btns(parent: Control) -> void:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	# Centered in 1280×800, below title
	vbox.position              = Vector2(410, 314.0)
	vbox.custom_minimum_size   = Vector2(320.0, 0.0)
	parent.add_child(vbox)

	_add_btn(vbox, "NEW GAME",  _C_ACCENT, _on_new_game)

	_continue_btn = _add_btn(vbox, "CONTINUE",  _C_ACCENT, _on_continue)
	_continue_btn.visible = GameState.has_save()

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0.0, 10.0)
	vbox.add_child(gap)

	_add_btn(vbox, "OPTIONS",   _C_MUTED,  _on_opts)
	_add_btn(vbox, "WIPE DATA", _C_DANGER, _on_wipe_request)

# ── Options panel ─────────────────────────────────────────────────────────────

func _build_opts_panel(parent: Control) -> void:
	_opts_panel = _make_panel(parent, "OPTIONS", 360.0, 200.0)

	var fs_btn: Button
	fs_btn = _add_btn(_opts_panel, _fs_label(), _C_MUTED, Callable())
	fs_btn.pressed.connect(func() -> void:
		var mode := DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fs_btn.text = _fs_label()
	)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0.0, 6.0)
	_opts_panel.add_child(gap)

	_add_btn(_opts_panel, "← BACK", _C_MUTED, func() -> void:
		_opts_panel.get_parent().visible = false
	)

# ── Wipe confirmation panel ───────────────────────────────────────────────────

func _build_wipe_panel(parent: Control) -> void:
	_wipe_panel = _make_panel(parent, "WIPE ALL DATA?", 380.0, 220.0)

	var warn := Label.new()
	warn.text = "Erase all playthroughs and save data.\nThis cannot be undone."
	warn.add_theme_color_override("font_color", Color(0.88, 0.62, 0.28))
	warn.add_theme_font_size_override("font_size", 12)
	warn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warn.autowrap_mode         = TextServer.AUTOWRAP_WORD
	_wipe_panel.add_child(warn)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0.0, 8.0)
	_wipe_panel.add_child(gap)

	_add_btn(_wipe_panel, "CONFIRM — ERASE EVERYTHING", _C_DANGER, func() -> void:
		GameState.wipe()
		_continue_btn.visible = false
		_wipe_panel.get_parent().visible = false
	)
	_add_btn(_wipe_panel, "CANCEL", _C_MUTED, func() -> void:
		_wipe_panel.get_parent().visible = false
	)

# ── Callbacks ─────────────────────────────────────────────────────────────────

func _on_new_game() -> void:
	_letter_overlay.visible = true

func _on_letter_acknowledged() -> void:
	_letter_overlay.visible = false
	GameState.reset()
	GameState.current_room_id = "room_01"
	GameState.save()
	get_tree().change_scene_to_file(_GAME_SCENE)

func _on_continue() -> void:
	GameState.load_save()
	get_tree().change_scene_to_file(_GAME_SCENE)

func _on_opts() -> void:
	_opts_panel.get_parent().visible = true

func _on_wipe_request() -> void:
	_wipe_panel.get_parent().visible = true

# ── Letter / intro screen ─────────────────────────────────────────────────────

func _build_letter_screen(parent: Control) -> void:
	# Full-screen dim backdrop
	_letter_overlay = ColorRect.new()
	_letter_overlay.color = Color(0.0, 0.0, 0.0, 0.72)
	_letter_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_letter_overlay.visible = false
	parent.add_child(_letter_overlay)

	# Email card — 660 px wide, centred on 1280×800
	const CARD_W := 648.0
	const CARD_X := (1152 - CARD_W) / 2.0
	const CARD_Y := 20

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(CARD_W, 0.0)
	card.position = Vector2(CARD_X, CARD_Y)

	var card_sb := StyleBoxFlat.new()
	card_sb.bg_color              = Color(0.03, 0.06, 0.05)
	card_sb.border_color          = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.55)
	card_sb.border_width_left     = 1
	card_sb.border_width_right    = 1
	card_sb.border_width_top      = 1
	card_sb.border_width_bottom   = 1
	card_sb.content_margin_left   = 0.0
	card_sb.content_margin_right  = 0.0
	card_sb.content_margin_top    = 0.0
	card_sb.content_margin_bottom = 0.0
	card.add_theme_stylebox_override("panel", card_sb)
	_letter_overlay.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	card.add_child(vbox)

	# ── Inbox toolbar ──
	var toolbar := _letter_hbox(vbox, Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.08),
			Vector2(16.0, 10.0))
	var inbox_lbl := Label.new()
	inbox_lbl.text = "INBOX  ·  1 UNREAD"
	inbox_lbl.add_theme_color_override("font_color", Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.65))
	inbox_lbl.add_theme_font_size_override("font_size", 10)
	inbox_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(inbox_lbl)

	var dot := Label.new()
	dot.text = "●"
	dot.add_theme_color_override("font_color", _C_ACCENT)
	dot.add_theme_font_size_override("font_size", 8)
	toolbar.add_child(dot)

	_letter_hsep(vbox, 0.18)

	# ── Subject line ──
	var subj_pad := _letter_padded(vbox, Vector2(20.0, 14.0))
	var subj := Label.new()
	subj.text = "FACILITY 7 ASSIGNMENT — ASSET REVIEW"
	subj.add_theme_color_override("font_color", _C_TITLE)
	subj.add_theme_font_size_override("font_size", 18)
	subj_pad.add_child(subj)

	# ── Meta fields (From / To / Date) ──
	var meta_pad := _letter_padded(vbox, Vector2(20.0, 10.0))
	var meta_grid := GridContainer.new()
	meta_grid.columns = 2
	meta_grid.add_theme_constant_override("h_separation", 10)
	meta_grid.add_theme_constant_override("v_separation", 4)
	meta_pad.add_child(meta_grid)

	var meta := [
		["From:", "NEXUS CORP HR  <dispatch@nexus-corp.internal>"],
		["To:",   "TECH INTERN  [YOU]"],
		["Date:", "2024-09-14   09:15:33 UTC"],
	]
	for row in meta:
		var key := Label.new()
		key.text = row[0]
		key.add_theme_color_override("font_color", _C_MUTED)
		key.add_theme_font_size_override("font_size", 11)
		meta_grid.add_child(key)

		var val := Label.new()
		val.text = row[1]
		val.add_theme_color_override("font_color", Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.80))
		val.add_theme_font_size_override("font_size", 11)
		meta_grid.add_child(val)

	_letter_hsep(vbox, 0.20)

	# ── Body ──
	var body_pad := _letter_padded(vbox, Vector2(24.0, 18.0))
	var body := RichTextLabel.new()
	body.bbcode_enabled      = true
	body.fit_content         = false
	body.scroll_active       = true
	body.custom_minimum_size = Vector2(CARD_W - 48.0, 340.0)
	body.add_theme_color_override("default_color", Color(0.72, 0.90, 0.82))
	body.add_theme_font_size_override("normal_font_size", 13)
	body.add_theme_constant_override("line_separation", 6)
	body.text = (
		"[color=#3a6050]Your assignment is straightforward.[/color]\n\n"
		+ "[color=#3a6050]Travel to our decommissioned Facility 7 and catalog remaining hardware[/color]\n"
		+ "[color=#3a6050]assets for the upcoming resale. A checklist is attached.[/color]\n\n"
		+ "[color=#3a6050]Run the initialization diagnostic on arrival to confirm network status.[/color]\n"
		+ "[color=#3a6050]The building has been dark for three years.[/color]\n"
		+ "[color=#3a6050]This should take a few hours.[/color]\n\n"
		+ "[color=#3a6050]Report back by end of day.[/color]\n\n"
		+ "[color=#2a5040]Controls:  [W / A / S / D]  move   ·   [E]  interact   ·   [ESC]  cancel[/color]\n\n"
		+ "[color=#1a3830]──────────────────────────────────────────────────────[/color]\n"
		+ "[color=#c94040]// AUTOMATED ALERT — 14:22:09[/color]\n\n"
		+ "[color=#c94040]LOCKDOWN INITIATED.[/color]\n"
		+ "[color=#c94040]Network severed. External communications offline.[/color]\n"
		+ "[color=#c94040]Unknown process detected on internal network.[/color]\n"
		+ "[color=#c94040]This message cannot be sent externally.[/color]\n\n"
		+ "[color=#c94040]You are inside the facility.[/color]"
	)
	body_pad.add_child(body)

	_letter_hsep(vbox, 0.12)

	# ── Acknowledge button ──
	var btn_pad := _letter_padded(vbox, Vector2(24.0, 16.0))
	var ack := _add_btn(btn_pad, "ACKNOWLEDGE  —  BEGIN", _C_ACCENT, _on_letter_acknowledged)
	ack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ack.custom_minimum_size   = Vector2(0.0, 36.0)


## Returns a padded MarginContainer added to parent.
func _letter_padded(parent: Node, margin: Vector2) -> VBoxContainer:
	var mc := MarginContainer.new()
	mc.add_theme_constant_override("margin_left",   int(margin.x))
	mc.add_theme_constant_override("margin_right",  int(margin.x))
	mc.add_theme_constant_override("margin_top",    int(margin.y))
	mc.add_theme_constant_override("margin_bottom", int(margin.y))
	parent.add_child(mc)
	var vb := VBoxContainer.new()
	mc.add_child(vb)
	return vb


## Returns an HBoxContainer row with a tinted background via a PanelContainer.
func _letter_hbox(parent: Node, bg: Color, pad: Vector2) -> HBoxContainer:
	var pc := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color              = bg
	sb.content_margin_left   = int(pad.x)
	sb.content_margin_right  = int(pad.x)
	sb.content_margin_top    = int(pad.y)
	sb.content_margin_bottom = int(pad.y)
	pc.add_theme_stylebox_override("panel", sb)
	parent.add_child(pc)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 8)
	pc.add_child(hb)
	return hb


## Adds a 1-px horizontal rule.
func _letter_hsep(parent: Node, alpha: float) -> void:
	var line := ColorRect.new()
	line.color               = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, alpha)
	line.custom_minimum_size = Vector2(0.0, 1.0)
	parent.add_child(line)

# ── Helpers ───────────────────────────────────────────────────────────────────

func _fs_label() -> String:
	var mode := DisplayServer.window_get_mode()
	return "FULLSCREEN:  ON" if mode == DisplayServer.WINDOW_MODE_FULLSCREEN \
		else "FULLSCREEN:  OFF"

## Creates a centred overlay panel. Returns the inner VBoxContainer for content.
func _make_panel(parent: Control, header: String, w: float, _h: float) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(w, 0.0)
	panel.position            = Vector2((1280.0 - w) / 2.0, 240.0)
	panel.visible             = false
	parent.add_child(panel)

	var sb := StyleBoxFlat.new()
	sb.bg_color              = Color(0.03, 0.05, 0.09)
	sb.border_width_left     = 1
	sb.border_width_right    = 1
	sb.border_width_top      = 1
	sb.border_width_bottom   = 1
	sb.border_color          = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.50)
	sb.content_margin_left   = 28.0
	sb.content_margin_right  = 28.0
	sb.content_margin_top    = 22.0
	sb.content_margin_bottom = 22.0
	panel.add_theme_stylebox_override("panel", sb)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Header label
	var hdr := Label.new()
	hdr.text = header
	hdr.add_theme_color_override("font_color", _C_TITLE)
	hdr.add_theme_font_size_override("font_size", 15)
	hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hdr)

	# Thin separator
	var line := ColorRect.new()
	line.color                = Color(_C_ACCENT.r, _C_ACCENT.g, _C_ACCENT.b, 0.25)
	line.custom_minimum_size  = Vector2(0.0, 1.0)
	vbox.add_child(line)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0.0, 4.0)
	vbox.add_child(gap)

	return vbox

func _add_btn(parent: Node, text: String, color: Color,
		cb: Callable = Callable()) -> Button:
	var btn := Button.new()
	btn.text = text

	var n_sb := StyleBoxFlat.new()
	n_sb.bg_color            = Color(color.r, color.g, color.b, 0.07)
	n_sb.border_color        = Color(color.r, color.g, color.b, 0.42)
	n_sb.border_width_left   = 1
	n_sb.border_width_right  = 1
	n_sb.border_width_top    = 1
	n_sb.border_width_bottom = 1
	n_sb.content_margin_left   = 20.0
	n_sb.content_margin_right  = 20.0
	n_sb.content_margin_top    = 9.0
	n_sb.content_margin_bottom = 9.0

	var h_sb := StyleBoxFlat.new()
	h_sb.bg_color            = Color(color.r, color.g, color.b, 0.18)
	h_sb.border_color        = Color(color.r, color.g, color.b, 0.85)
	h_sb.border_width_left   = 1
	h_sb.border_width_right  = 1
	h_sb.border_width_top    = 1
	h_sb.border_width_bottom = 1
	h_sb.content_margin_left   = 20.0
	h_sb.content_margin_right  = 20.0
	h_sb.content_margin_top    = 9.0
	h_sb.content_margin_bottom = 9.0

	btn.add_theme_stylebox_override("normal",   n_sb)
	btn.add_theme_stylebox_override("hover",    h_sb)
	btn.add_theme_stylebox_override("pressed",  h_sb)
	btn.add_theme_stylebox_override("focus",    n_sb)
	btn.add_theme_color_override("font_color",        color)
	btn.add_theme_color_override("font_hover_color",  color.lightened(0.25))
	btn.add_theme_font_size_override("font_size", 13)

	if cb.is_valid():
		btn.pressed.connect(cb)
	parent.add_child(btn)
	return btn
