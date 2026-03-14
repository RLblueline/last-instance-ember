class_name ScanlineLayer
extends CanvasLayer

func _ready() -> void:
	layer = 48

	# 1×4 tile: one dark row, three transparent — tiles across the whole screen
	var img := Image.create(1, 4, false, Image.FORMAT_RGBA8)
	img.set_pixel(0, 0, Color(0.0, 0.0, 0.0, 0.045))
	img.set_pixel(0, 1, Color(0.0, 0.0, 0.0, 0.018))
	img.set_pixel(0, 2, Color(0.0, 0.0, 0.0, 0.0))
	img.set_pixel(0, 3, Color(0.0, 0.0, 0.0, 0.0))
	var tex := ImageTexture.create_from_image(img)

	var rect := TextureRect.new()
	rect.texture = tex
	rect.stretch_mode = TextureRect.STRETCH_TILE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)

	# Subtle dark vignette corners via four gradient-ish ColorRects
	for corner in [
		Rect2(0, 0, 260, 200),
		Rect2(1020, 0, 260, 200),
		Rect2(0, 600, 260, 200),
		Rect2(1020, 600, 260, 200),
	]:
		var v := ColorRect.new()
		v.color = Color(0.0, 0.0, 0.0, 0.10)
		v.position = corner.position
		v.size     = corner.size
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(v)
