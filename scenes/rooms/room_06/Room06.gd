extends Room
# The Choice — final room. IRIS presents the situation and the player decides.
# Ending is determined by empathy_score + the choice made in dialogue.

func _pre_setup() -> void:
	room_style = "white_room"

func _setup_room() -> void:
	_name_label("SCENE 08 · THE CHOICE")

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

func set_dialogue_box(db: DialogueBox) -> void:
	super.set_dialogue_box(db)
	_play_entry()

func _play_entry() -> void:
	# Fade in from black as player arrives from room 07
	var cl := CanvasLayer.new()
	cl.layer = 30
	add_child(cl)
	var black := ColorRect.new()
	black.color = Color(0.0, 0.0, 0.0, 1.0)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(black)
	var fade := create_tween()
	fade.tween_property(black, "modulate:a", 0.0, 1.8)
	fade.tween_callback(cl.queue_free)
	# Auto-trigger IRIS ending while room fades in — player never needs to press E
	await get_tree().create_timer(0.5).timeout
	if _db == null or _iris == null:
		return
	if _iris._spoken_initial:
		return
	_iris._spoken_initial = true
	_iris.trigger_glitch()
	await get_tree().create_timer(0.3).timeout
	if _db == null:
		return
	var choices: Array = IRISData.R06_CHOICES_HIGH if GameState.empathy_score >= 4 \
			else IRISData.R06_CHOICES_LOW
	_db.present(IRISData.R06_SETUP_LINES, "IRIS", choices)
	await _db.dialogue_finished
	_iris.dialogue_ended.emit()

func _on_iris_dialogue_ended() -> void:
	if _db == null:
		GameState.record_ending(GameState.get_ending())
		GameState.reset()
		GameState.save()
		return
	var ending := GameState.get_ending()
	var epilogue: Array
	match ending:
		"together":     epilogue = IRISData.R06_EPILOGUE_TOGETHER
		"sacrifice":    epilogue = IRISData.R06_EPILOGUE_SACRIFICE
		"alone_kind":   epilogue = IRISData.R06_EPILOGUE_ALONE_KIND
		_:              epilogue = IRISData.R06_EPILOGUE_ALONE_COLD
	_db.present(epilogue, "IRIS")
	await _db.dialogue_finished
	GameState.record_ending(ending)
	GameState.reset()
	GameState.save()

func get_spawn_point() -> Vector2:
	return Vector2(120.0, 400.0)
