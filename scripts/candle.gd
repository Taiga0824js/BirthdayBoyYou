extends Node3D

@export var flicker_speed: float = 7.0
@export var flicker_amount: float = 0.10
@export var phase_offset: float = 0.0

@onready var flame: Node3D = $Flame
@onready var flame_mesh: MeshInstance3D = $Flame/FlameMesh
@onready var flame_light: OmniLight3D = $Flame/FlameLight

var base_scale := Vector3.ONE
var base_position := Vector3.ZERO
var is_lit := true

func _ready() -> void:
	base_scale = flame.scale
	base_position = flame.position

func _process(delta: float) -> void:
	if not is_lit:
		return

	var t := Time.get_ticks_msec() / 1000.0
	var wave := sin((t + phase_offset) * flicker_speed)
	var wave2 := sin((t + phase_offset * 1.7) * flicker_speed * 1.63)

	flame.scale = base_scale * Vector3(
		1.0 + wave2 * flicker_amount * 0.45,
		1.0 + wave * flicker_amount,
		1.0 + wave2 * flicker_amount * 0.45
	)
	flame.position = base_position + Vector3(
		wave2 * 0.012,
		wave * 0.008,
		0.0
	)
	flame_light.light_energy = 1.4 + wave * 0.18

func extinguish() -> void:
	if not is_lit:
		return
	is_lit = false
	flame.visible = false
