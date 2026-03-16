class_name Hazard
extends Area2D

var _speed: float = 0.0
var _range: float = 0.0
var _dir: float = 1.0
var _start_pos: Vector2
var _axis: String = "x"

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body_entered)

func setup_patrol(range_px: float, speed: float = 55.0, axis: String = "x") -> void:
	_range   = range_px
	_speed   = speed
	_axis    = axis
	_start_pos = position

func _process(delta: float) -> void:
	if _range <= 0.0:
		return
	if _axis == "x":
		position.x += _speed * _dir * delta
		if abs(position.x - _start_pos.x) >= _range:
			_dir *= -1.0
	else:
		position.y += _speed * _dir * delta
		if abs(position.y - _start_pos.y) >= _range:
			_dir *= -1.0

func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.take_damage()
