class_name Player
extends CharacterBody2D

const SPEED := 120.0

var movement_enabled: bool = true

func _physics_process(_delta: float) -> void:
	if not movement_enabled:
		velocity = Vector2.ZERO
		return
	var dx: float = 0.0
	var dy: float = 0.0
	if Input.is_key_pressed(KEY_LEFT)  or Input.is_key_pressed(KEY_A): dx -= 1.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D): dx += 1.0
	if Input.is_key_pressed(KEY_UP)    or Input.is_key_pressed(KEY_W): dy -= 1.0
	if Input.is_key_pressed(KEY_DOWN)  or Input.is_key_pressed(KEY_S): dy += 1.0
	velocity = Vector2(dx, dy).normalized() * SPEED
	move_and_slide()

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
