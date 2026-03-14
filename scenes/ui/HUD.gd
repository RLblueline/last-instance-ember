extends CanvasLayer

@onready var _room_label: Label = %RoomLabel
@onready var _stat_label: Label = %StatLabel

const ROOM_NAMES: Dictionary = {
	"room_01": "01 · Boot Build",
	"room_02": "02 · Archive Hub",
	"room_03": "03 · Memory Chamber",
	"room_04": "04 · Debug Space",
	"room_05": "05 · Confrontation Layer",
	"room_06": "06 · Final Build",
	"room_07": "07 · The Lockdown",
	"room_08": "08 · The Override",
}

func _ready() -> void:
	set_room_name("room_01")

func set_room_name(room_id: String) -> void:
	if _room_label:
		_room_label.text = ROOM_NAMES.get(room_id, room_id)

func _process(_delta: float) -> void:
	if _stat_label:
		var frags := GameState.collected_fragments.size()
		_stat_label.text = "E:%d  H:%d  O:%d    ◈ %d/8" % [
			GameState.empathy_score,
			GameState.honesty_score,
			GameState.obedience_score,
			frags,
		]
