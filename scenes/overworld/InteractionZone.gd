class_name InteractionZone
extends Area2D

signal interacted(zone: InteractionZone)

@export var prompt_text: String = "[E] Interact"
@export var one_shot:    bool   = false

var _player_inside: bool = false
var _used:          bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_prompt_label()

func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside:
		return
	if one_shot and _used:
		return
	if event is InputEventKey and event.pressed and not event.echo \
			and event.keycode == KEY_E:
		_used = true
		interacted.emit(self)
		get_viewport().set_input_as_handled()

func reset_use() -> void:
	_used = false

func _on_body_entered(body: Node) -> void:
	if body is Player:
		_player_inside = true
		_update_prompt_label()

func _on_body_exited(body: Node) -> void:
	if body is Player:
		_player_inside = false
		_update_prompt_label()

func _update_prompt_label() -> void:
	var lbl: Label = get_node_or_null("Prompt")
	if lbl == null:
		return
	lbl.visible = _player_inside and not (one_shot and _used)
