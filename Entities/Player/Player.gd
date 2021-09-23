extends KinematicBody


onready var head := $Head
onready var headbob_animation := $Head/Camera/HeadBobPlayer

export var mouse_sensitivity := 0.5
export var head_max_pitch := 90.0
export var max_horizontal_speed := 15.0
export var max_falling_speed := 30
export var time_to_max_speed := 0.4
export var time_to_halt := 0.2
export var time_to_halt_air := 1.0
export var max_slope_angle := deg2rad(10.0)
export var jump_height := 1.2
export var distance_to_peak := 3.5
export var distance_after_peak := 2.0

var direction := Vector3()
var h_velocity := Vector3()
var v_velocity := Vector3()
var movement := Vector3()
var snap_vec := Vector3.DOWN
var jump := false
var floor_height := 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	direction = Vector3()
	direction -= transform.basis.z * Input.get_action_strength("move_forwards")
	direction += transform.basis.z * Input.get_action_strength("move_backwards")
	direction -= transform.basis.x * Input.get_action_strength("move_left")
	direction += transform.basis.x * Input.get_action_strength("move_right")
	direction = direction.normalized()
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	jump = Input.is_action_just_pressed("jump")
	
	if direction.length_squared() > 0 and is_on_floor():
		headbob_animation.play("move")
		headbob_animation.playback_speed = lerp(0, 1, h_velocity.length() / max_horizontal_speed)
	else:
		headbob_animation.play("idle")
		headbob_animation.playback_speed = 1.0
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sensitivity * event.relative.x
		head.rotation_degrees.x -= mouse_sensitivity * event.relative.y
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -head_max_pitch, head_max_pitch)

func _physics_process(delta: float) -> void:
	var h_speed = h_velocity.length()
	
	if direction.length_squared() > 0:
		var h_acceleration = max_horizontal_speed / time_to_max_speed
		h_speed = clamp(h_speed + h_acceleration * delta, 0, max_horizontal_speed)
	else:
		var time := time_to_halt if is_on_floor() else time_to_halt_air
		var h_acceleration := max_horizontal_speed / time
		h_speed = max(h_speed - h_acceleration * delta, 0)
	
	if is_on_ceiling():
		v_velocity = Vector3.ZERO
	elif is_on_floor() and jump:
		var jump_speed = 2 * jump_height * max_horizontal_speed / distance_to_peak
		v_velocity = Vector3.UP * jump_speed
	elif is_on_floor():
		v_velocity = -get_floor_normal() * 0.1
		jump = false
		floor_height = transform.origin.y
	else:
		var section_distance = distance_to_peak if v_velocity.y > 0.0 else distance_after_peak
		var gravity = 2 * jump_height * pow(max_horizontal_speed, 2) / pow(section_distance, 2)
		var was_going_up = v_velocity.y > 0.0
		v_velocity += Vector3.DOWN * gravity * delta
		var going_down = v_velocity.y < 0.0
		if was_going_up and going_down:
			print(transform.origin.y - floor_height)
		
	h_velocity = direction * h_speed
	movement.z = h_velocity.z + v_velocity.z
	movement.x = h_velocity.x + v_velocity.x
	movement.y = max(v_velocity.y, -max_falling_speed)
	move_and_slide(movement, Vector3.UP)

