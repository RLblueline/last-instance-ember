class_name Room
extends Node2D

signal transition_requested(next_room_id: String)
signal puzzle_requested(puzzle_type: String, puzzle_data: Dictionary, puzzle_id: String)

const ROOM_W    := 1280.0
const ROOM_H    := 800.0
const WALL_T    := 40.0
const C_FLOOR   := Color(0.04, 0.05, 0.10, 1.0)
const C_WALL    := Color(0.08, 0.10, 0.20, 1.0)
const C_ACCENT  := Color(0.10, 0.22, 0.30, 1.0)
const C_TERMINAL := Color(0.55, 0.35, 0.10, 1.0)
const C_LOG     := Color(0.05, 0.18, 0.28, 1.0)

const _IRIS_SCENE    := preload("res://scenes/iris/IRIS.tscn")
const _IZ_SCENE      := preload("res://scenes/overworld/InteractionZone.tscn")
const _AMBIENT_SCENE := preload("res://scenes/effects/AmbientField.gd")

var _db:        DialogueBox = null
var _iris:      IRIS        = null
var _room_id:   String      = ""
var _doors:     Dictionary  = {}   # door_id → Node2D container
var room_style: String      = "sci_fi"  # set in _pre_setup() before shell is built

# ── Called by GameWorld after add_child ────────────────────────────────────────
func set_dialogue_box(db: DialogueBox) -> void:
	_db = db
	if _iris != null:
		_iris.setup(_room_id, db)

# ── Called by GameWorld after a puzzle is solved ───────────────────────────────
func on_puzzle_completed(_puzzle_id: String) -> void:
	pass

# ── Override to handle named secret events from GameWorld ─────────────────────
func trigger_secret_event(_event: String) -> void:
	pass

# ── Spawn point ───────────────────────────────────────────────────────────────
func get_spawn_point() -> Vector2:
	return Vector2(WALL_T + 80.0, ROOM_H / 2.0)

# ── Lifecycle ─────────────────────────────────────────────────────────────────
func _ready() -> void:
	_pre_setup()
	_build_shell()
	_setup_room()

## Override to set room_style (or other pre-build state) before the shell is constructed.
func _pre_setup() -> void:
	pass

# ── Style-aware colour getters ─────────────────────────────────────────────────

func _get_floor_color() -> Color:
	match room_style:
		"dungeon", "torchlit", "dungeon_lit":
			return Color(0.10, 0.09, 0.08, 1.0)
		"facility":      return Color(0.72, 0.74, 0.78, 1.0)
		"white_room":    return Color(0.94, 0.95, 0.97, 1.0)
		"bedroom":       return Color(0.38, 0.28, 0.18, 1.0)
		"control_room":  return Color(0.08, 0.08, 0.10, 1.0)
		_:               return C_FLOOR

func _get_wall_color() -> Color:
	match room_style:
		"dungeon", "torchlit", "dungeon_lit":
			return Color(0.22, 0.19, 0.16, 1.0)
		"facility":      return Color(0.80, 0.82, 0.86, 1.0)
		"white_room":    return Color(0.97, 0.98, 1.00, 1.0)
		"bedroom":       return Color(0.76, 0.70, 0.60, 1.0)
		"control_room":  return Color(0.14, 0.14, 0.18, 1.0)
		_:               return C_WALL

func _get_exit_accent_color() -> Color:
	match room_style:
		"dungeon", "torchlit", "dungeon_lit":
			return Color(0.60, 0.38, 0.12, 0.85)
		"facility":      return Color(0.95, 0.48, 0.04, 0.95)
		"white_room":    return Color(0.55, 0.80, 1.00, 0.75)
		"bedroom":       return Color(0.80, 0.60, 0.35, 0.75)
		"control_room":  return Color(0.85, 0.10, 0.10, 0.80)
		_:               return Color(0.30, 0.80, 0.50, 0.70)

func _get_trace_color(alpha: float = 0.38) -> Color:
	match room_style:
		"dungeon", "torchlit", "dungeon_lit":
			return Color(0.50, 0.30, 0.08, alpha)
		"facility":      return Color(0.05, 0.35, 0.90, alpha)
		"white_room":    return Color(0.40, 0.65, 0.95, alpha * 0.7)
		"control_room":  return Color(0.65, 0.08, 0.08, alpha)
		_:               return Color(0.08, 0.32, 0.25, alpha)

func _get_door_colors() -> Array:  # [body_color, glow_color]
	match room_style:
		"dungeon", "torchlit", "dungeon_lit":
			return [Color(0.20, 0.17, 0.14, 1.0), Color(0.58, 0.42, 0.16, 0.50)]
		"facility":      return [Color(0.82, 0.84, 0.88, 1.0), Color(0.95, 0.45, 0.05, 0.55)]
		"control_room":  return [Color(0.14, 0.10, 0.10, 1.0), Color(0.82, 0.08, 0.08, 0.55)]
		_:               return [Color(0.42, 0.08, 0.65, 1.0), Color(0.70, 0.30, 1.00, 0.35)]

# ── Shell construction ─────────────────────────────────────────────────────────
func _build_shell() -> void:
	_poly(Rect2(0.0, 0.0, ROOM_W, ROOM_H), _get_floor_color())
	_wall(Rect2(0.0,           0.0,             ROOM_W, WALL_T))
	_wall(Rect2(0.0,           ROOM_H - WALL_T, ROOM_W, WALL_T))
	_wall(Rect2(0.0,           0.0,             WALL_T, ROOM_H))
	# Right wall with door gap (y 310–490)
	_wall(Rect2(ROOM_W - WALL_T, 0.0,   WALL_T, 310.0))
	_wall(Rect2(ROOM_W - WALL_T, 490.0, WALL_T, ROOM_H - 490.0))
	# Door-frame accent
	_poly(Rect2(ROOM_W - WALL_T - 2.0, 305.0, 6.0, 190.0), _get_exit_accent_color())
	# Ambient particle field
	var af: Node = _AMBIENT_SCENE.new()
	add_child(af)

## Override to populate room-specific content.
func _setup_room() -> void:
	pass

# ── Helpers: geometry ─────────────────────────────────────────────────────────
func _wall(rect: Rect2) -> void:
	_poly(rect, _get_wall_color())
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = rect.size
	cs.shape = rs
	body.add_child(cs)
	add_child(body)

func _poly(rect: Rect2, color: Color) -> void:
	var p := Polygon2D.new()
	p.polygon = PackedVector2Array([
		rect.position,
		Vector2(rect.end.x,      rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	])
	p.color = color
	add_child(p)

func _accent(rect: Rect2, color: Color = C_ACCENT) -> void:
	_poly(rect, color)

# ── Helpers: IRIS ─────────────────────────────────────────────────────────────
func _spawn_iris(pos: Vector2, room_id: String) -> void:
	_room_id = room_id
	_iris = _IRIS_SCENE.instantiate() as IRIS
	_iris.position = pos
	add_child(_iris)
	_iris.dialogue_ended.connect(_on_iris_dialogue_ended)

func _on_iris_dialogue_ended() -> void:
	pass

# ── Helpers: puzzle zones ──────────────────────────────────────────────────────
func _puzzle_zone(pos: Vector2, p_type: String, p_data: Dictionary,
		p_id: String, label: String = "[E] Access terminal") -> void:
	if GameState.is_puzzle_done(p_id):
		var done_lbl := Label.new()
		done_lbl.text = "✓"
		done_lbl.position = pos + Vector2(-8.0, -20.0)
		done_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 0.7))
		add_child(done_lbl)
		return

	_accent(Rect2(pos.x - 18.0, pos.y - 24.0, 36.0, 48.0), C_TERMINAL)

	var zone: InteractionZone = _IZ_SCENE.instantiate() as InteractionZone
	zone.position = pos
	zone.prompt_text = label
	add_child(zone)
	var pr: Label = zone.get_node_or_null("Prompt")
	if pr:
		pr.text = label

	var pt  := p_type
	var pd  := p_data.duplicate(true)
	var pid := p_id
	zone.interacted.connect(func(_z: InteractionZone) -> void: puzzle_requested.emit(pt, pd, pid))

# ── Helpers: exits ────────────────────────────────────────────────────────────
func _exit_zone(next_room: String) -> void:
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask  = 1
	area.position = Vector2(ROOM_W - WALL_T / 2.0, 400.0)
	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(WALL_T + 40.0, 180.0)
	cs.shape = rs
	area.add_child(cs)
	add_child(area)

	var lbl := Label.new()
	lbl.text = "→"
	lbl.position = Vector2(-10.0, -12.0)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 0.9))
	lbl.add_theme_font_size_override("font_size", 20)
	area.add_child(lbl)

	var nr := next_room
	var _cb := func(body: Node) -> void:
		if body is Player:
			transition_requested.emit(nr)
	area.body_entered.connect(_cb)

# ── Helpers: room name label ──────────────────────────────────────────────────
func _name_label(text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.position = Vector2(WALL_T + 8.0, WALL_T + 6.0)
	lbl.add_theme_color_override("font_color", Color(0.4, 0.6, 0.5, 0.5))
	lbl.add_theme_font_size_override("font_size", 10)
	add_child(lbl)

# ── Helpers: secrets / interactive environment ────────────────────────────────

## Slim terminal panel with blinking cursor. One-shot interaction → presents lines via _db.
func _log_terminal(pos: Vector2, lines: Array) -> void:
	# Body
	_poly(Rect2(pos.x - 13.0, pos.y - 38.0, 26.0, 76.0), Color(0.04, 0.10, 0.18, 1.0))
	# Screen
	_poly(Rect2(pos.x - 9.0,  pos.y - 30.0, 18.0, 44.0), Color(0.03, 0.22, 0.32, 0.9))
	# LED dots (right side)
	for i in 3:
		_poly(Rect2(pos.x + 10.0, pos.y - 22.0 + i * 14.0, 5.0, 5.0),
				Color(0.1, 0.85, 0.55, 0.65))
	# Blinking cursor label (static — no actual blink without a script node, but looks right)
	var cur := Label.new()
	cur.text = ">_"
	cur.position = pos + Vector2(-8.0, -8.0)
	cur.add_theme_color_override("font_color", Color(0.25, 0.90, 0.65, 0.9))
	cur.add_theme_font_size_override("font_size", 8)
	add_child(cur)
	# Interaction zone
	var zone: InteractionZone = _IZ_SCENE.instantiate() as InteractionZone
	zone.position = pos
	zone.one_shot = true
	add_child(zone)
	var pr: Label = zone.get_node_or_null("Prompt")
	if pr:
		pr.text = "[E] Read log"
	var ln := lines
	var _lcb := func(_z: InteractionZone) -> void:
		if _db:
			_db.present(ln, "LOG")
		GameState.secrets_found += 1
	zone.interacted.connect(_lcb)

## Collectible glowing hexagon. Auto-collects on player contact.
func _data_fragment(pos: Vector2, fid: String) -> void:
	if GameState.has_fragment(fid):
		return
	# Outer glow
	var gpts := PackedVector2Array()
	for i in 6:
		var a := i * PI / 3.0 - PI / 6.0
		gpts.append(Vector2(cos(a), sin(a)) * 18.0)
	var glow := Polygon2D.new()
	glow.polygon = gpts
	glow.position = pos
	glow.color = Color(0.0, 0.9, 0.8, 0.12)
	add_child(glow)
	# Core hexagon
	var hpts := PackedVector2Array()
	for i in 6:
		var a := i * PI / 3.0 - PI / 6.0
		hpts.append(Vector2(cos(a), sin(a)) * 10.0)
	var hex := Polygon2D.new()
	hex.polygon = hpts
	hex.position = pos
	hex.color = Color(0.0, 0.95, 0.85, 0.9)
	add_child(hex)
	# Marker label
	var lbl := Label.new()
	lbl.text = "◈"
	lbl.position = pos + Vector2(-7.0, -9.0)
	lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.9, 0.9))
	lbl.add_theme_font_size_override("font_size", 14)
	add_child(lbl)
	# Collection area
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask  = 1
	area.position = pos
	var cs := CollisionShape2D.new()
	var rs := CircleShape2D.new()
	rs.radius = 22.0
	cs.shape = rs
	area.add_child(cs)
	add_child(area)
	var fragment_id := fid
	var h_ref := hex
	var g_ref := glow
	var l_ref := lbl
	var a_ref := area
	var _fb := func(body: Node) -> void:
		if body is Player:
			GameState.collect_fragment(fragment_id)
			h_ref.queue_free()
			g_ref.queue_free()
			l_ref.queue_free()
			a_ref.queue_free()
	area.body_entered.connect(_fb)

## Invisible memory echo — faint marker, one-shot dialogue on interact.
func _ghost_echo(pos: Vector2, lines: Array) -> void:
	# Very faint floating "??" hint
	var lbl := Label.new()
	lbl.text = "??"
	lbl.position = pos + Vector2(-9.0, -12.0)
	lbl.add_theme_color_override("font_color", Color(0.3, 0.7, 0.55, 0.18))
	lbl.add_theme_font_size_override("font_size", 10)
	add_child(lbl)
	# Faint glow disc
	var hpts := PackedVector2Array()
	for i in 8:
		var a := i * PI / 4.0
		hpts.append(Vector2(cos(a), sin(a)) * 14.0)
	var disc := Polygon2D.new()
	disc.polygon = hpts
	disc.position = pos
	disc.color = Color(0.1, 0.6, 0.5, 0.07)
	add_child(disc)
	# Interaction zone
	var zone: InteractionZone = _IZ_SCENE.instantiate() as InteractionZone
	zone.position = pos
	zone.one_shot = true
	add_child(zone)
	var pr: Label = zone.get_node_or_null("Prompt")
	if pr:
		pr.text = "[E] ..."
	var ln := lines
	var _gcb := func(_z: InteractionZone) -> void:
		if _db:
			_db.present(ln, "ECHO")
		GameState.secrets_found += 1
	zone.interacted.connect(_gcb)

## Decorative hex/binary text label. Pass "" to auto-generate an address.
func _hex_decor(pos: Vector2, text: String = "") -> void:
	var lbl := Label.new()
	lbl.text = text if text != "" else "0x%04X" % (randi() % 65536)
	lbl.position = pos
	lbl.add_theme_color_override("font_color", Color(0.18, 0.38, 0.30, 0.32))
	lbl.add_theme_font_size_override("font_size", 8)
	add_child(lbl)

# ── Helpers: doors & switches ─────────────────────────────────────────────────

## Destructible door — call _open_door(door_id) to free it.
func _door(rect: Rect2, door_id: String) -> void:
	var c     := Node2D.new()
	var dcols := _get_door_colors()
	# Visual
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	])
	poly.color = dcols[0]
	c.add_child(poly)
	# Glow accent strip
	var glow  := Polygon2D.new()
	var inset := 3.0
	glow.polygon = PackedVector2Array([
		rect.position + Vector2(inset, inset),
		Vector2(rect.end.x - inset, rect.position.y + inset),
		rect.end - Vector2(inset, inset),
		Vector2(rect.position.x + inset, rect.end.y - inset),
	])
	glow.color = dcols[1]
	c.add_child(glow)
	# Collision
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = rect.size
	cs.shape = rs
	body.add_child(cs)
	c.add_child(body)
	# Label
	var lbl := Label.new()
	lbl.text = "▣"
	lbl.position = rect.get_center() + Vector2(-6.0, -8.0)
	lbl.add_theme_color_override("font_color", Color(0.85, 0.5, 1.0, 0.85))
	lbl.add_theme_font_size_override("font_size", 10)
	c.add_child(lbl)
	add_child(c)
	_doors[door_id] = c

## Opens (frees) a door by its id.
func _open_door(door_id: String) -> void:
	if _doors.has(door_id):
		_doors[door_id].queue_free()
		_doors.erase(door_id)

## Switch panel — interacting opens the listed doors.
func _switch_panel(pos: Vector2, door_ids: Array, label: String = "[E] Activate") -> void:
	# Visual: amber hexagonal pad
	_poly(Rect2(pos.x - 18.0, pos.y - 18.0, 36.0, 36.0), Color(0.45, 0.25, 0.04, 1.0))
	_poly(Rect2(pos.x - 12.0, pos.y - 12.0, 24.0, 24.0), Color(0.85, 0.55, 0.12, 0.85))
	var lbl := Label.new()
	lbl.text = "◉"
	lbl.position = pos + Vector2(-7.0, -9.0)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 0.95))
	lbl.add_theme_font_size_override("font_size", 14)
	add_child(lbl)
	# Interaction zone
	var zone: InteractionZone = _IZ_SCENE.instantiate() as InteractionZone
	zone.position = pos
	zone.one_shot = true
	add_child(zone)
	var pr: Label = zone.get_node_or_null("Prompt")
	if pr:
		pr.text = label
	var ids := door_ids
	var _scb := func(_z: InteractionZone) -> void:
		for id in ids:
			_open_door(id)
	zone.interacted.connect(_scb)

## Wall-mounted comm screen — presents lines with IRIS speaker.
## on_done fires immediately when player interacts (before dialogue ends).
func _comm_screen(pos: Vector2, lines: Array, label: String = "[E] Access comm",
		on_done: Callable = Callable()) -> void:
	# Housing
	_poly(Rect2(pos.x - 34.0, pos.y - 24.0, 68.0, 48.0), Color(0.05, 0.10, 0.18, 1.0))
	# Screen face
	_poly(Rect2(pos.x - 28.0, pos.y - 17.0, 56.0, 34.0), Color(0.02, 0.24, 0.38, 0.9))
	# Scanline stripes
	_poly(Rect2(pos.x - 28.0, pos.y - 8.0,  56.0, 2.0), Color(0.0, 0.5, 0.6, 0.22))
	_poly(Rect2(pos.x - 28.0, pos.y + 4.0,  56.0, 2.0), Color(0.0, 0.5, 0.6, 0.22))
	# Corner brackets
	_poly(Rect2(pos.x - 28.0, pos.y - 17.0, 6.0, 2.0), Color(0.2, 0.85, 0.7, 0.6))
	_poly(Rect2(pos.x + 22.0, pos.y - 17.0, 6.0, 2.0), Color(0.2, 0.85, 0.7, 0.6))
	_poly(Rect2(pos.x - 28.0, pos.y + 15.0, 6.0, 2.0), Color(0.2, 0.85, 0.7, 0.6))
	_poly(Rect2(pos.x + 22.0, pos.y + 15.0, 6.0, 2.0), Color(0.2, 0.85, 0.7, 0.6))
	# IRIS label
	var scr_lbl := Label.new()
	scr_lbl.text = "IRIS"
	scr_lbl.position = pos + Vector2(-11.0, -10.0)
	scr_lbl.add_theme_color_override("font_color", Color(0.25, 0.90, 0.75, 0.85))
	scr_lbl.add_theme_font_size_override("font_size", 9)
	add_child(scr_lbl)
	# Status LEDs (bottom edge)
	for i in 3:
		_poly(Rect2(pos.x - 10.0 + i * 9.0, pos.y + 19.0, 5.0, 3.0),
				Color(0.05, 0.80, 0.55, 0.75 - i * 0.15))
	# Interaction zone
	var scr_zone: InteractionZone = _IZ_SCENE.instantiate() as InteractionZone
	scr_zone.position = pos
	scr_zone.one_shot = true
	add_child(scr_zone)
	var scr_pr: Label = scr_zone.get_node_or_null("Prompt")
	if scr_pr:
		scr_pr.text = label
	var ln   := lines
	var cb   := on_done
	var _ccb := func(_z: InteractionZone) -> void:
		if _db:
			_db.present(ln, "IRIS")
		if cb.is_valid():
			cb.call()
	scr_zone.interacted.connect(_ccb)

## Floor-mounted lever — different visual from switch_panel. Opens listed doors on use.
func _lever(pos: Vector2, door_ids: Array, label: String = "[E] Pull lever") -> void:
	# Base plate
	_poly(Rect2(pos.x - 12.0, pos.y + 10.0, 24.0, 8.0), Color(0.18, 0.20, 0.26, 1.0))
	# Post
	_poly(Rect2(pos.x - 3.0, pos.y - 26.0, 6.0, 38.0), Color(0.28, 0.31, 0.40, 1.0))
	# Handle bar
	_poly(Rect2(pos.x - 16.0, pos.y - 30.0, 32.0, 7.0), Color(0.48, 0.52, 0.62, 1.0))
	# Handle glow strip
	_poly(Rect2(pos.x - 14.0, pos.y - 29.0, 28.0, 3.0), Color(0.22, 0.88, 0.60, 0.50))
	# Arrow indicator
	var lev_lbl := Label.new()
	lev_lbl.text = "◁"
	lev_lbl.position = pos + Vector2(-7.0, -46.0)
	lev_lbl.add_theme_color_override("font_color", Color(0.35, 1.0, 0.65, 0.95))
	lev_lbl.add_theme_font_size_override("font_size", 12)
	add_child(lev_lbl)
	# Interaction zone
	var lev_zone: InteractionZone = _IZ_SCENE.instantiate() as InteractionZone
	lev_zone.position = pos
	lev_zone.one_shot = true
	add_child(lev_zone)
	var lev_pr: Label = lev_zone.get_node_or_null("Prompt")
	if lev_pr:
		lev_pr.text = label
	var ids    := door_ids
	var _lev_cb := func(_z: InteractionZone) -> void:
		for id in ids:
			_open_door(id)
	lev_zone.interacted.connect(_lev_cb)

## Ambient point light — creates a PointLight2D with a radial gradient texture.
func _point_light(pos: Vector2, color: Color, energy: float = 1.0, scale: float = 1.5) -> PointLight2D:
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	grad.set_color(1, Color(0.0, 0.0, 0.0, 0.0))
	var tex := GradientTexture2D.new()
	tex.width    = 128
	tex.height   = 128
	tex.fill     = GradientTexture2D.FILL_RADIAL
	tex.gradient = grad
	var light := PointLight2D.new()
	light.texture       = tex
	light.texture_scale = scale
	light.energy        = energy
	light.color         = color
	light.position      = pos
	light.shadow_enabled = false
	add_child(light)
	return light

## Applies dungeon stone texture: mortar grid + decorative torch sconces on top wall.
func _apply_dungeon_texture() -> void:
	var mortar := Color(0.05, 0.04, 0.03, 0.55)
	# Horizontal mortar lines (stone courses every 40 px)
	for y_i in range(0, int(ROOM_H) + 1, 40):
		_poly(Rect2(0.0, float(y_i), ROOM_W, 1.5), mortar)
	# Vertical mortar lines (staggered between rows)
	for row in range(0, int(ROOM_H / 40) + 1):
		var off := 32.0 if row % 2 == 0 else 0.0
		for x_i in range(0, int(ROOM_W) + 64, 64):
			_poly(Rect2(float(x_i) + off, float(row * 40), 1.5, 42.0), mortar)
	# Corner shadow strips (simulate depth near walls)
	var shadow := Color(0.03, 0.02, 0.02, 0.38)
	_poly(Rect2(WALL_T,                     WALL_T, 16.0, ROOM_H - WALL_T * 2.0), shadow)
	_poly(Rect2(ROOM_W - WALL_T - 16.0,    WALL_T, 16.0, ROOM_H - WALL_T * 2.0), shadow)
	_poly(Rect2(WALL_T, ROOM_H - WALL_T - 16.0, ROOM_W - WALL_T * 2.0, 16.0),   shadow)
	# Torch sconces spaced along the top wall
	for x in [200.0, 500.0, 780.0, 1060.0]:
		_torch_sconce(Vector2(x, WALL_T + 2.0))

## Decorative wall torch bracket — visual only; player's PointLight2D provides real light.
func _torch_sconce(pos: Vector2) -> void:
	# Iron bracket post
	_poly(Rect2(pos.x - 3.0,  pos.y + 4.0,  6.0, 16.0), Color(0.28, 0.22, 0.14, 1.0))
	_poly(Rect2(pos.x - 6.0,  pos.y + 14.0, 12.0,  6.0), Color(0.32, 0.26, 0.16, 1.0))
	# Flame core (amber)
	_poly(Rect2(pos.x - 5.0,  pos.y + 2.0,  10.0, 14.0), Color(0.90, 0.48, 0.06, 0.72))
	# Flame tip (bright yellow-white)
	_poly(Rect2(pos.x - 3.0,  pos.y - 2.0,   6.0,  8.0), Color(1.00, 0.90, 0.50, 0.92))
	# Soft halo polygon
	var gpts := PackedVector2Array()
	for i in 8:
		var a := i * PI / 4.0
		gpts.append(Vector2(cos(a), sin(a)) * 24.0)
	var halo := Polygon2D.new()
	halo.polygon  = gpts
	halo.position = pos + Vector2(0.0, 8.0)
	halo.color    = Color(0.90, 0.45, 0.05, 0.06)
	add_child(halo)

## Spawns warm PointLight2D nodes at torch positions — call after _apply_dungeon_texture().
## Provides enough coverage to light the whole room without a dark overlay.
func _apply_torch_lights() -> void:
	var warm := Color(1.0, 0.65, 0.25)
	# Top-wall lights at the existing sconce positions
	for x in [200.0, 500.0, 780.0, 1060.0]:
		_point_light(Vector2(x, WALL_T + 20.0), warm, 1.3, 7.0)
	# Bottom-wall sconces + matching lights for full-room coverage
	for x in [320.0, 640.0, 960.0]:
		_torch_sconce(Vector2(x, ROOM_H - WALL_T - 2.0))
		_point_light(Vector2(x, ROOM_H - WALL_T - 18.0), warm, 1.3, 7.0)

## Applies Portal 2-style facility texture: white panel seams + orange/blue warning strips.
func _apply_facility_texture() -> void:
	var seam := Color(0.58, 0.60, 0.65, 0.85)
	# Panel seam grid
	for y_i in range(WALL_T, int(ROOM_H - WALL_T), 96):
		_poly(Rect2(float(WALL_T), float(y_i), float(ROOM_W - WALL_T * 2), 2.0), seam)
	for x_i in range(WALL_T, int(ROOM_W - WALL_T), 128):
		_poly(Rect2(float(x_i), float(WALL_T), 2.0, float(ROOM_H - WALL_T * 2)), seam)
	# Orange warning chevron strip — bottom edge
	var sw    := 22.0
	var y_bot := float(ROOM_H - WALL_T - 18.0)
	var n     := int((ROOM_W - WALL_T * 2) / sw) + 1
	for i in n:
		var col := Color(0.92, 0.42, 0.02, 0.88) if i % 2 == 0 else Color(0.05, 0.05, 0.07, 0.88)
		_poly(Rect2(float(WALL_T) + i * sw, y_bot, sw, 12.0), col)
	# Portal-blue warning strip — top edge
	var y_top := float(WALL_T + 6.0)
	for j in n:
		var col := Color(0.06, 0.40, 0.90, 0.80) if j % 2 == 0 else Color(0.05, 0.05, 0.07, 0.80)
		_poly(Rect2(float(WALL_T) + j * sw, y_top, sw, 10.0), col)
	# Bevel shadow trim on all interior edges
	var bev := Color(0.52, 0.54, 0.58, 0.80)
	_poly(Rect2(float(WALL_T), float(WALL_T), float(ROOM_W - WALL_T * 2), 5.0), bev)
	_poly(Rect2(float(WALL_T), float(ROOM_H - WALL_T - 5.0), float(ROOM_W - WALL_T * 2), 5.0), bev)
	_poly(Rect2(float(WALL_T), float(WALL_T), 5.0, float(ROOM_H - WALL_T * 2)), bev)
	_poly(Rect2(float(ROOM_W - WALL_T - 5.0), float(WALL_T), 5.0, float(ROOM_H - WALL_T * 2)), bev)

## Single-segment circuit trace line (horizontal OR vertical only).
func _circuit_trace(from: Vector2, to: Vector2, alpha: float = 0.38) -> void:
	var tc   := _get_trace_color(alpha)
	var dot  := Color(minf(tc.r * 2.2, 1.0), minf(tc.g * 2.2, 1.0), minf(tc.b * 2.2, 1.0), tc.a)
	var rect := Rect2(
		min(from.x, to.x),
		min(from.y, to.y),
		max(absf(to.x - from.x), 2.0),
		max(absf(to.y - from.y), 2.0)
	)
	_accent(rect, tc)
	_poly(Rect2(from.x - 2.0, from.y - 2.0, 4.0, 4.0), dot)
	_poly(Rect2(to.x   - 2.0, to.y   - 2.0, 4.0, 4.0), dot)
