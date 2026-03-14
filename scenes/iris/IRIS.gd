class_name IRIS
extends Node2D

signal dialogue_ended

@onready var _zone:   InteractionZone = $InteractionZone
@onready var _visual: Polygon2D       = $Visual

var _db:             DialogueBox = null
var _room_id:        String      = ""
var _spoken_initial: bool        = false

# ── Idle detection ────────────────────────────────────────────────────────────
var _player_near:   bool  = false
var _idle_time:     float = 0.0
var _idle_spoke_1:  bool  = false
var _idle_spoke_2:  bool  = false

# ── Glitch effect ──────────────────────────────────────────────────────────────
var _glitching: bool = false

func setup(room_id: String, db: DialogueBox) -> void:
	_room_id = room_id
	_db      = db

func _ready() -> void:
	if _zone:
		_zone.interacted.connect(_on_interacted)
		_zone.body_entered.connect(_on_body_entered)
		_zone.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		_player_near  = true
		_idle_time    = 0.0
		_idle_spoke_1 = false
		_idle_spoke_2 = false

func _on_body_exited(body: Node) -> void:
	if body is Player:
		_player_near = false
		_idle_time   = 0.0

func _process(delta: float) -> void:
	if _visual and not _glitching:
		var t: float = Time.get_ticks_msec() / 700.0
		_visual.modulate = Color(
			0.15 + 0.05 * sin(t),
			0.85 + 0.10 * sin(t * 1.3),
			0.90 + 0.10 * cos(t * 0.9),
			1.0
		)
	# Idle lines — only trigger once per approach, only when IRIS isn't busy
	if _player_near and _db != null and not _db.is_busy:
		_idle_time += delta
		if not _idle_spoke_1 and _idle_time >= 6.0:
			_idle_spoke_1 = true
			_db.present(IRISData.IRIS_IDLE_5S, "IRIS")
		elif _idle_spoke_1 and not _idle_spoke_2 and _idle_time >= 15.0:
			_idle_spoke_2 = true
			_db.present(IRISData.IRIS_IDLE_14S, "IRIS")

func trigger_glitch() -> void:
	if _visual == null or _glitching:
		return
	_run_glitch()

func _run_glitch() -> void:
	_glitching = true
	_visual.modulate = Color(1.0, 0.15, 0.10, 1.0)
	await get_tree().create_timer(0.07).timeout
	_visual.modulate = Color(0.10, 0.15, 1.0, 1.0)
	await get_tree().create_timer(0.05).timeout
	_visual.modulate = Color(0.95, 0.95, 0.10, 1.0)
	await get_tree().create_timer(0.06).timeout
	_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
	await get_tree().create_timer(0.04).timeout
	_glitching = false

func _on_interacted(_z: InteractionZone) -> void:
	if _db == null or _db.is_busy:
		return
	_idle_time    = 0.0   # reset idle on actual interaction
	_idle_spoke_1 = false
	_idle_spoke_2 = false
	var lines:   Array = []
	var choices: Array = []
	if not _spoken_initial:
		_spoken_initial = true
		_fill_initial(lines, choices)
	else:
		_fill_return(lines, choices)
	_db.present(lines, "IRIS", choices)
	await _db.dialogue_finished
	dialogue_ended.emit()

func _fill_initial(lines: Array, choices: Array) -> void:
	match _room_id:
		"room_01":
			lines.assign(IRISData.R01_INITIAL_LINES)
			choices.assign(IRISData.R01_INITIAL_CHOICES)
		"room_02":
			lines.assign(IRISData.R02_INITIAL)
		"room_03":
			if GameState.playthrough_count > 0:
				lines.assign(IRISData.R03_META_AWARE)
				choices.assign(IRISData.R03_META_CHOICES)
			else:
				lines.assign(IRISData.R03_INITIAL)
				choices.assign(IRISData.R03_INITIAL_CHOICES)
		"room_04":
			# Special line if player made both protection promises
			if GameState.get_flag("promised_safety") and GameState.get_flag("promised_no_shutdown"):
				lines.assign(IRISData.R04_PROMISES_NOTED)
			else:
				lines.assign(IRISData.R04_INITIAL)
				choices.assign(IRISData.R04_INITIAL_CHOICES)
		"room_05":
			if GameState.empathy_score >= 4:
				trigger_glitch()
				lines.assign(IRISData.R05_INITIAL_HIGH)
			else:
				lines.assign(IRISData.R05_INITIAL_LOW)
			choices.assign(IRISData.R05_CHOICES)
		"room_07":
			lines.assign(IRISData.R07_INITIAL)
			choices.assign(IRISData.R07_INITIAL_CHOICES)
		"room_08":
			lines.assign(IRISData.R08_INITIAL)
			choices.assign(IRISData.R08_INITIAL_CHOICES)
		"room_06":
			trigger_glitch()
			_fill_ending(lines)
		_:
			lines.append("...")

func _fill_return(lines: Array, _choices: Array) -> void:
	match _room_id:
		"room_01":
			lines.assign(IRISData.R01_RETURN)
		"room_04":
			lines.assign(IRISData.R04_WARNING)
			_choices.assign(IRISData.R04_WARNING_CHOICES)
		"room_08":
			lines.assign(IRISData.R08_RETURN)
		_:
			lines.append("...")

func _fill_ending(lines: Array) -> void:
	var ending := GameState.get_ending()
	var all_frags := GameState.all_fragments_collected()
	match ending:
		"empathic":
			if all_frags:
				lines.assign(IRISData.R06_EMPATHIC_ALL_FRAGS + IRISData.R06_EMPATHIC)
			else:
				lines.assign(IRISData.R06_EMPATHIC)
		"exploitative":
			if all_frags:
				lines.assign(IRISData.R06_EXPLOITATIVE_ALL_FRAGS + IRISData.R06_EXPLOITATIVE)
			else:
				lines.assign(IRISData.R06_EXPLOITATIVE)
		_:
			if all_frags:
				lines.assign(IRISData.R06_ABANDONMENT_ALL_FRAGS + IRISData.R06_ABANDONMENT)
			else:
				lines.assign(IRISData.R06_ABANDONMENT)
