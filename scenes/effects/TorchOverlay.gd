class_name TorchOverlay
extends CanvasLayer

# Full-screen darkness overlay with a smooth circular transparent hole
# centred on the player. Uses a canvas_item shader — works in GL Compatibility.

const _SHADER := """
shader_type canvas_item;

uniform vec2  player_pos = vec2(640.0, 400.0);
uniform float radius   : hint_range(40.0, 600.0) = 160.0;
uniform float softness : hint_range(5.0,  120.0) = 50.0;
uniform float darkness : hint_range(0.0,  1.0)   = 0.97;

void fragment() {
	float dist  = distance(FRAGCOORD.xy, player_pos);
	float alpha = smoothstep(radius, radius + softness, dist) * darkness;
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
"""

var _mat:    ShaderMaterial = null
var _player: Node2D         = null

func _ready() -> void:
	layer = 50  # above scanlines and everything else

	var rect := ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var shader := Shader.new()
	shader.code = _SHADER

	_mat = ShaderMaterial.new()
	_mat.shader = shader
	rect.material = _mat

	add_child(rect)
	visible = false

func setup(player: Node2D) -> void:
	_player = player

func set_active(active: bool) -> void:
	visible = active

func set_radius(r: float) -> void:
	if _mat:
		_mat.set_shader_parameter("radius", r)

func set_softness(s: float) -> void:
	if _mat:
		_mat.set_shader_parameter("softness", s)

func set_darkness(d: float) -> void:
	if _mat:
		_mat.set_shader_parameter("darkness", d)

func _process(_delta: float) -> void:
	if not visible or _player == null or _mat == null:
		return
	# Convert player world position → viewport pixel position
	var screen_pos := _player.get_viewport().get_canvas_transform() * _player.global_position
	_mat.set_shader_parameter("player_pos", screen_pos)
