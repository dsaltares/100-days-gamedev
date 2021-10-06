tool
extends Node
class_name CharacterMover

export(NodePath) var body_path
export var max_horizontal_speed := 15.0
export var max_falling_speed := 30
export var time_to_max_speed := 0.4
export var time_to_halt := 0.2
export var time_to_halt_air := 1.0
export var max_slope_angle := deg2rad(10.0)
export var jump_height := 1.2
export var distance_to_peak := 3.5
export var distance_after_peak := 2.0

onready var coyote_timer := $CoyoteTimer

var direction := Vector3()
var jump := false

var h_velocity := Vector3()
var v_velocity := Vector3()
var can_jump := false

func _get_configuration_warning():
	if not body_path:
		return 'Body to move path not set'
	return ''

func _physics_process(delta: float) -> void:
	if not body_path:
		return
		
	if Engine.editor_hint:
		return
		
	var h_speed := h_velocity.length()
	var body : KinematicBody = get_node(body_path)
	var is_on_floor := body.is_on_floor()
	var is_on_ceiling := body.is_on_ceiling()
	var floor_normal := body.get_floor_normal()
	
	if direction.length_squared() > 0:
		var h_acceleration = max_horizontal_speed / time_to_max_speed
		h_speed = clamp(h_speed + h_acceleration * delta, 0, max_horizontal_speed)
	else:
		var time := time_to_halt if is_on_floor else time_to_halt_air
		var h_acceleration := max_horizontal_speed / time
		h_speed = max(h_speed - h_acceleration * delta, 0)	
	
	if is_on_floor:
		can_jump = true
	elif coyote_timer.is_stopped():
		coyote_timer.start()
	
	if is_on_ceiling:
		v_velocity = Vector3.ZERO
	elif can_jump and jump:
		var jump_speed = 2 * jump_height * max_horizontal_speed / distance_to_peak
		v_velocity = Vector3.UP * jump_speed
	elif is_on_floor:
		v_velocity = -floor_normal * 0.1
	else:
		var section_distance = distance_to_peak if v_velocity.y > 0.0 else distance_after_peak
		var gravity = 2 * jump_height * pow(max_horizontal_speed, 2) / pow(section_distance, 2)
		v_velocity += Vector3.DOWN * gravity * delta
		
	h_velocity = direction * h_speed
	var movement := Vector3(
		h_velocity.x + v_velocity.x,
		max(v_velocity.y, -max_falling_speed),
		h_velocity.z + v_velocity.z
	)
	body.move_and_slide(movement, Vector3.UP)

func _on_CoyoteTimer_timeout() -> void:
	if not body_path:
		return
		
	var body : KinematicBody = get_node(body_path)
		
	can_jump = body.is_on_floor()
