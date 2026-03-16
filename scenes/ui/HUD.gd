extends CanvasLayer

@onready var _room_label: Label = %RoomLabel
@onready var _stat_label: Label = %StatLabel

const ROOM_NAMES: Dictionary = {
	"room_01": "01 · Arrival",
	"room_02": "02 · First Fragments",
	"room_03": "03 · Echo",
	"room_04": "04 · The Weight",
	"room_05": "05 · Confession",
	"room_06": "06 · The Choice",
	"room_07": "07 · The Surge",
	"room_08": "08 · Nexus",
}

func _ready() -> void:
	set_room_name("room_01")

func set_room_name(room_id: String) -> void:
	if _room_label:
		_room_label.text = ROOM_NAMES.get(room_id, room_id)

func _process(_delta: float) -> void:
	if _stat_label:
		var frags := GameState.collected_fragments.size()
		var full  := "♥".repeat(GameState.lives)
		var empty := "♡".repeat(GameState.MAX_LIVES - GameState.lives)
		_stat_label.text = "%s%s    ◈ %d/8" % [full, empty, frags]
