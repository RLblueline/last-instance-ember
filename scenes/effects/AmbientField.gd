class_name AmbientField
extends Node2D

const _COUNT  := 22
const _ROOM_W := 1280.0
const _ROOM_H := 800.0

var _particles: Array = []

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for _i in _COUNT:
		var size: float = rng.randf_range(1.8, 4.5)
		var pts := PackedVector2Array()
		pts.append(Vector2(0.0,  -size))
		pts.append(Vector2(size,  0.0))
		pts.append(Vector2(0.0,   size))
		pts.append(Vector2(-size, 0.0))
		var poly := Polygon2D.new()
		poly.polygon = pts
		poly.color = Color(
			rng.randf_range(0.0, 0.05),
			rng.randf_range(0.5, 0.85),
			rng.randf_range(0.65, 0.95),
			0.0
		)
		poly.position = Vector2(rng.randf() * _ROOM_W, rng.randf() * _ROOM_H)
		add_child(poly)
		_particles.append({
			"poly":  poly,
			"vel":   Vector2(rng.randf_range(-14.0, 14.0), rng.randf_range(-7.0, 7.0)),
			"phase": rng.randf() * TAU,
		})

func _process(delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	for p in _particles:
		var poly: Polygon2D = p["poly"]
		poly.position += (p["vel"] as Vector2) * delta
		if poly.position.x < 0.0:    poly.position.x += _ROOM_W
		if poly.position.x > _ROOM_W: poly.position.x -= _ROOM_W
		if poly.position.y < 0.0:    poly.position.y += _ROOM_H
		if poly.position.y > _ROOM_H: poly.position.y -= _ROOM_H
		poly.color.a = 0.10 + 0.13 * sin(t * 1.4 + p["phase"])
