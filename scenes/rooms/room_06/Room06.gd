extends Room
# The Choice — final room. IRIS presents the situation and the player decides.
# Ending is determined by empathy_score + the choice made in dialogue.

func _pre_setup() -> void:
	room_style = "white_room"

func _setup_room() -> void:
	_name_label("FINAL · EXIT CORRIDOR")

	# Minimal clinical space — emotional weight carried entirely by dialogue
	var lc := Color(0.72, 0.82, 0.95, 0.35)
	_accent(Rect2(WALL_T + 16.0, WALL_T + 16.0, ROOM_W - WALL_T * 2.0 - 32.0, 2.0), lc)
	_accent(Rect2(WALL_T + 16.0, ROOM_H - WALL_T - 18.0, ROOM_W - WALL_T * 2.0 - 32.0, 2.0), lc)
	_accent(Rect2(WALL_T + 16.0, WALL_T + 16.0, 2.0, ROOM_H - WALL_T * 2.0 - 32.0), lc)
	_accent(Rect2(ROOM_W - WALL_T - 18.0, WALL_T + 16.0, 2.0, ROOM_H - WALL_T * 2.0 - 32.0), lc)

	# Soft window — left wall, lets in the idea of outside
	_poly(Rect2(WALL_T, 200.0, 10.0, 160.0), Color(0.85, 0.92, 1.00, 0.80))
	_poly(Rect2(WALL_T + 2.0, 206.0, 6.0, 148.0), Color(0.96, 0.98, 1.00, 0.95))
	# Moonlight spill
	_poly(Rect2(WALL_T + 10.0, 200.0, 50.0, 160.0), Color(0.78, 0.82, 0.90, 0.06))

	# Floor reflection strip
	_poly(Rect2(WALL_T, ROOM_H - WALL_T - 6.0, ROOM_W - WALL_T * 2.0, 6.0),
			Color(0.88, 0.91, 0.97, 0.40))

	if GameState.all_fragments_collected():
		_hex_decor(Vector2(520.0, 755.0), "all fragments recovered")
		_hex_decor(Vector2(520.0, 765.0), "she was not alone after all")

	_spawn_iris(Vector2(640.0, 400.0), "room_06")
	_data_fragment(Vector2(200.0, 200.0), "frag_06")
	_log_terminal(Vector2(1050.0, 580.0), IRISData.LOG_R06)
	_exit_zone("__title__")

func _on_iris_dialogue_ended() -> void:
	GameState.reset()
	GameState.save()

func get_spawn_point() -> Vector2:
	return Vector2(120.0, 400.0)
