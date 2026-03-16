class_name Player
extends CharacterBody2D

signal damaged

const SPEED := 120.0

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D

var movement_enabled: bool = true
var _invincible: bool = false

func _ready() -> void:
	_setup_animations()

func _setup_animations() -> void:
	var texture := preload("res://Assets/Sprite Frames (1).png") as Texture2D
	var frame_w: int = texture.get_width() / 6   # 6 columns
	var frame_h: int = int(texture.get_height() / 3.5)  # 3 rows

	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	# ── Idle — row 0, columns 0-2 ────────────────────────────────────────────
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 5.0)
	for i in 3:
		var atlas := AtlasTexture.new()
		atlas.atlas  = texture
		atlas.region = Rect2(i * frame_w, 0, frame_w, frame_h)
		frames.add_frame("idle", atlas)

	# ── Run — row 1, columns 0-5 ─────────────────────────────────────────────
	frames.add_animation("run")
	frames.set_animation_loop("run", true)
	frames.set_animation_speed("run", 10.0)
	for i in 6:
		var atlas := AtlasTexture.new()
		atlas.atlas  = texture
		atlas.region = Rect2(i * frame_w, frame_h, frame_w, frame_h)
		frames.add_frame("run", atlas)

	_anim.sprite_frames = frames
	_anim.play("idle")

func _physics_process(_delta: float) -> void:
	if not movement_enabled:
		velocity = Vector2.ZERO
		_anim.play("idle")
		return
	var dx: float = 0.0
	var dy: float = 0.0
	if Input.is_key_pressed(KEY_LEFT)  or Input.is_key_pressed(KEY_A): dx -= 1.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D): dx += 1.0
	if Input.is_key_pressed(KEY_UP)    or Input.is_key_pressed(KEY_W): dy -= 1.0
	if Input.is_key_pressed(KEY_DOWN)  or Input.is_key_pressed(KEY_S): dy += 1.0
	velocity = Vector2(dx, dy).normalized() * SPEED
	move_and_slide()
	_update_animation(dx, dy)

func _update_animation(dx: float, dy: float) -> void:
	if dx == 0.0 and dy == 0.0:
		_anim.play("idle")
	else:
		_anim.play("run")
		# Flip sprite to face movement direction (horizontal takes priority)
		if dx != 0.0:
			_anim.flip_h = dx < 0.0

func set_movement_enabled(enabled: bool) -> void:
	movement_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO

func set_camera_limits(l: int, t: int, r: int, b: int) -> void:
	var cam: Camera2D = get_node_or_null("Camera2D")
	if cam:
		cam.limit_left   = l
		cam.limit_top    = t
		cam.limit_right  = r
		cam.limit_bottom = b

func set_camera_zoom(zoom: Vector2) -> void:
	var cam: Camera2D = get_node_or_null("Camera2D")
	if cam:
		cam.zoom = zoom

func take_damage() -> void:
	if _invincible or not movement_enabled:
		return
	_invincible = true
	GameState.lose_life()
	damaged.emit()
	_flash_hit()
	get_tree().create_timer(2.0).timeout.connect(func() -> void: _invincible = false)

func _flash_hit() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 0.15, 0.15, 1.0), 0.06)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.25), 0.10)
	tween.tween_property(self, "modulate", Color(1.0, 0.15, 0.15, 1.0), 0.10)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.25), 0.10)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0),  0.10)
