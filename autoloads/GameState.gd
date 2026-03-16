extends Node

# ── Relationship stats ────────────────────────────────────────────────────
var empathy_score:   int = 0
var honesty_score:   int = 0
var obedience_score: int = 0

var lives:     int = 3
const MAX_LIVES: int = 3

# ── Progress ─────────────────────────────────────────────────────────────
var dialogue_flags:    Dictionary = {}
var completed_puzzles: Array      = []
var current_room_id:   String     = "room_01"
var playthrough_count: int        = 0

# ── Secrets ───────────────────────────────────────────────────────────────
var collected_fragments: Array = []   # frag_01 … frag_08
var secrets_found:       int   = 0   # log terminals + ghost echoes read

# ── Cross-run persistence (survives reset, cleared by wipe) ───────────────
var endings_achieved:  Array  = []   # ["together", "sacrifice", …]
var last_run_ending:   String = ""
var last_run_empathy:  int    = 0
var last_run_honesty:  int    = 0
var last_run_fragments: int   = 0
var last_run_secrets:  int    = 0

# ── Helpers ───────────────────────────────────────────────────────────────
func set_flag(key: String, value: bool = true) -> void:
	dialogue_flags[key] = value

func get_flag(key: String) -> bool:
	return dialogue_flags.get(key, false)

func complete_puzzle(puzzle_id: String) -> void:
	if puzzle_id not in completed_puzzles:
		completed_puzzles.append(puzzle_id)

func is_puzzle_done(puzzle_id: String) -> bool:
	return puzzle_id in completed_puzzles

func add_empathy(delta: int) -> void:
	empathy_score += delta

func add_honesty(delta: int) -> void:
	honesty_score += delta

func add_obedience(delta: int) -> void:
	obedience_score += delta

func heal() -> void:
	lives = mini(lives + 1, MAX_LIVES)

func lose_life() -> void:
	lives = maxi(0, lives - 1)

# ── Fragment helpers ───────────────────────────────────────────────────────
func collect_fragment(fid: String) -> void:
	if fid not in collected_fragments:
		collected_fragments.append(fid)

func has_fragment(fid: String) -> bool:
	return fid in collected_fragments

func all_fragments_collected() -> bool:
	return collected_fragments.size() >= 8

# ── Ending recording ──────────────────────────────────────────────────────
func record_ending(ending: String) -> void:
	last_run_ending    = ending
	last_run_empathy   = empathy_score
	last_run_honesty   = honesty_score
	last_run_fragments = collected_fragments.size()
	last_run_secrets   = secrets_found
	if ending not in endings_achieved:
		endings_achieved.append(ending)

# ── Ending logic ──────────────────────────────────────────────────────────
func get_ending() -> String:
	var together := get_flag("chose_together")
	if together and empathy_score >= 4:
		return "together"
	elif together:
		return "sacrifice"
	elif empathy_score >= 4:
		return "alone_kind"
	else:
		return "alone_cold"

# ── Save / Load ───────────────────────────────────────────────────────────
const SAVE_PATH := "user://iris_save.json"

func save() -> void:
	var data := {
		"empathy_score":      empathy_score,
		"honesty_score":      honesty_score,
		"obedience_score":    obedience_score,
		"dialogue_flags":     dialogue_flags,
		"completed_puzzles":  completed_puzzles,
		"current_room_id":    current_room_id,
		"playthrough_count":  playthrough_count,
		"collected_fragments": collected_fragments,
		"secrets_found":      secrets_found,
		"lives":              lives,
		"endings_achieved":   endings_achieved,
		"last_run_ending":    last_run_ending,
		"last_run_empathy":   last_run_empathy,
		"last_run_honesty":   last_run_honesty,
		"last_run_fragments": last_run_fragments,
		"last_run_secrets":   last_run_secrets,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return false
	var data: Dictionary = json.get_data() as Dictionary
	empathy_score       = data.get("empathy_score",      0)
	honesty_score       = data.get("honesty_score",      0)
	obedience_score     = data.get("obedience_score",    0)
	dialogue_flags      = data.get("dialogue_flags",     {})
	completed_puzzles   = data.get("completed_puzzles",  [])
	current_room_id     = data.get("current_room_id",    "room_01")
	playthrough_count   = data.get("playthrough_count",  0) + 1
	collected_fragments = data.get("collected_fragments", [])
	secrets_found       = data.get("secrets_found",      0)
	lives               = data.get("lives",              3)
	endings_achieved    = data.get("endings_achieved",   [])
	last_run_ending     = data.get("last_run_ending",    "")
	last_run_empathy    = data.get("last_run_empathy",   0)
	last_run_honesty    = data.get("last_run_honesty",   0)
	last_run_fragments  = data.get("last_run_fragments", 0)
	last_run_secrets    = data.get("last_run_secrets",   0)
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func reset() -> void:
	empathy_score       = 0
	honesty_score       = 0
	obedience_score     = 0
	dialogue_flags      = {}
	completed_puzzles   = []
	current_room_id     = "room_01"
	collected_fragments = []
	secrets_found       = 0
	lives               = 3

func wipe() -> void:
	var dir := DirAccess.open("user://")
	if dir != null:
		dir.remove("iris_save.json")
	reset()
	playthrough_count  = 0
	endings_achieved   = []
	last_run_ending    = ""
	last_run_empathy   = 0
	last_run_honesty   = 0
	last_run_fragments = 0
	last_run_secrets   = 0
