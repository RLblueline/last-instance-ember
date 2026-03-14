class_name TitleScreen
extends Node

const _GAME_SCENE := "res://scenes/world/GameWorld.tscn"

const _C_BG     := Color(0.02, 0.02, 0.04)
const _C_TITLE  := Color(0.20, 1.00, 0.72)
const _C_SUB    := Color(0.22, 0.45, 0.38)
const _C_ACCENT := Color(0.10, 0.78, 0.58)
const _C_MUTED  := Color(0.28, 0.38, 0.33)
const _C_DANGER := Color(0.82, 0.22, 0.12)

var _continue_btn: Button  = null
var _opts_panel:   Control = null
var _wipe_panel:   Control = null

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
	vbox.position              = Vector2(480.0, 314.0)
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
