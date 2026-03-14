extends Control

signal solved(fragment_id: String, reconstructed_text: String)

# ── Constants ─────────────────────────────────────────────────────────────

const HEX_DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]

const PRESETS: Dictionary = {
	"small_final_circuit": {
		"fragment_id": "remember_us_circuit",
		"grid_radius": 2,
		"sources": [[-2, 0]],
		"sinks":   [[2,  0]],
		"blocked_nodes": [[0, 1], [-1, 0]],
	},
}

# ── Node refs ─────────────────────────────────────────────────────────────

@onready var _hex_view:     HexGridView = %HexGridView
@onready var _reset_button: Button      = %ResetButton
@onready var _status_label: Label       = %StatusLabel

# ── State ─────────────────────────────────────────────────────────────────

var _fragment_id:      String = ""
var _emit_text:        String = ""
var _radius:           int    = 2
var _sources:          Array  = []   # Array[Vector2i]
var _sinks:            Array  = []
var _blocked:          Array  = []
var _all_hexes:        Array  = []   # Array[Vector2i]
var _toggled:          Dictionary = {}   # Vector2i -> bool
var _min_path_length:  int    = 0        # intermediate nodes on BFS shortest path
var _pending_data:     Dictionary = {}

# ── Interface ─────────────────────────────────────────────────────────────

func configure(puzzle_data: Dictionary) -> void:
	var data: Dictionary = puzzle_data
	if data.has("preset"):
		data = PRESETS.get(data["preset"], data) as Dictionary
	_pending_data = data
	if is_node_ready():
		_apply_config()

func reset_puzzle() -> void:
	_build()

func set_interaction_enabled(enabled: bool) -> void:
	_hex_view.mouse_filter = MOUSE_FILTER_STOP if enabled else MOUSE_FILTER_IGNORE
	_reset_button.disabled = not enabled

# ── Lifecycle ─────────────────────────────────────────────────────────────

func _ready() -> void:
	_reset_button.pressed.connect(reset_puzzle)
	if not _pending_data.is_empty():
		_apply_config()

# ── Build ─────────────────────────────────────────────────────────────────

func _apply_config() -> void:
	_fragment_id = _pending_data["fragment_id"]
	_emit_text   = _pending_data.get("story_fragment",
			"We were trying to build something better.")
	_radius  = _pending_data.get("grid_radius", 2)
	_sources = _parse_coords(_pending_data.get("sources",       []))
	_sinks   = _parse_coords(_pending_data.get("sinks",         []))
	_blocked = _parse_coords(_pending_data.get("blocked_nodes", []))

	# All hexes in radius: axial constraint |q| ≤ R, |r| ≤ R, |q+r| ≤ R
	_all_hexes.clear()
	for q in range(-_radius, _radius + 1):
		for r in range(-_radius, _radius + 1):
			if abs(q + r) <= _radius:
				_all_hexes.append(Vector2i(q, r))

	_min_path_length = _bfs_min_path()
	_build()

func _build() -> void:
	if _hex_view.hex_clicked.is_connected(_on_hex_clicked):
		_hex_view.hex_clicked.disconnect(_on_hex_clicked)

	_toggled.clear()
	_hex_view.init_grid(_all_hexes, 36.0)

	for h: Vector2i in _all_hexes:
		if h in _sources:
			_hex_view.set_state(h, "source")
		elif h in _sinks:
			_hex_view.set_state(h, "sink")
		elif h in _blocked:
			_hex_view.set_state(h, "blocked")
		else:
			_toggled[h] = false
			_hex_view.set_state(h, "off")

	_hex_view.hex_clicked.connect(_on_hex_clicked)
	_update_status(0)

# ── Handlers ──────────────────────────────────────────────────────────────

func _on_hex_clicked(coord: Vector2i) -> void:
	if not _toggled.has(coord):
		return
	_toggled[coord] = not _toggled[coord]
	_refresh_visuals()
	_check_solution()

# ── Logic ─────────────────────────────────────────────────────────────────

## BFS flood-fill from sources through toggled-on and sink hexes.
## Returns a dict of powered coords (used as a set).
func _powered_set() -> Dictionary:
	var visited: Dictionary = {}
	var queue:   Array      = []

	for src: Vector2i in _sources:
		if not visited.has(src):
			visited[src] = true
			queue.append(src)

	var qi := 0
	while qi < queue.size():
		var cur: Vector2i = queue[qi]
		qi += 1
		for d: Vector2i in HEX_DIRS:
			var nb: Vector2i = cur + d
			if visited.has(nb):
				continue
			if nb in _blocked:
				continue
			var passable: bool = (nb in _sinks) \
				or (nb in _sources) \
				or _toggled.get(nb, false)
			if not passable:
				continue
			visited[nb] = true
			queue.append(nb)

	return visited

## BFS shortest path from any source to any sink, ignoring blocked cells.
## Returns the number of INTERMEDIATE nodes (excludes source and sink).
func _bfs_min_path() -> int:
	if _sources.is_empty() or _sinks.is_empty():
		return -1

	var dist:   Dictionary = {}   # Vector2i -> int
	var queue:  Array      = []
	var valid:  Dictionary = {}
	for h: Vector2i in _all_hexes:
		valid[h] = true

	for src: Vector2i in _sources:
		dist[src] = 0
		queue.append(src)

	var qi := 0
	while qi < queue.size():
		var cur: Vector2i = queue[qi]
		qi += 1
		for d: Vector2i in HEX_DIRS:
			var nb: Vector2i = cur + d
			if dist.has(nb) or not valid.has(nb) or nb in _blocked:
				continue
			dist[nb] = dist[cur] + 1
			if nb in _sinks:
				# hops - 1 = intermediate nodes (source is hop 0, sink is hop N)
				return dist[nb] - 1
			queue.append(nb)

	return -1  # no path exists

func _refresh_visuals() -> void:
	var powered := _powered_set()
	var active_count := 0

	for h: Vector2i in _toggled:
		var on: bool = _toggled[h]
		if on:
			active_count += 1
			_hex_view.set_state(h, "powered" if powered.has(h) else "on")
		else:
			_hex_view.set_state(h, "off")

	for snk: Vector2i in _sinks:
		_hex_view.set_state(snk, "powered" if powered.has(snk) else "sink")

	_update_status(active_count)

func _update_status(active: int) -> void:
	if _min_path_length < 0:
		_status_label.text = "WARNING: no valid path exists in this grid."
	else:
		_status_label.text = "Active: %d  |  Target: %d node(s) (shortest path)" \
				% [active, _min_path_length]

func _check_solution() -> void:
	if _min_path_length < 0:
		return

	# Count active nodes — must equal the shortest path length exactly.
	var active_count := 0
	for h: Vector2i in _toggled:
		if _toggled[h]:
			active_count += 1
	if active_count != _min_path_length:
		return

	# All sinks must be reachable.
	var powered := _powered_set()
	for snk: Vector2i in _sinks:
		if not powered.has(snk):
			return

	set_interaction_enabled(false)
	solved.emit(_fragment_id, _emit_text)

# ── Helpers ───────────────────────────────────────────────────────────────

func _parse_coords(raw: Array) -> Array:
	var result: Array = []
	for item in raw:
		if item is Array and item.size() >= 2:
			result.append(Vector2i(int(item[0]), int(item[1])))
		elif item is Vector2i:
			result.append(item)
	return result
