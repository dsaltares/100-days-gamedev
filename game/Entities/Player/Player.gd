extends KinematicBody


onready var head := $Head
onready var headbob_animation := $Head/Camera/HeadBobPlayer
onready var mover := $CharacterMover

export var mouse_sensitivity := 0.5
export var head_max_pitch := 90.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	var direction := Vector3()
	direction -= transform.basis.z * Input.get_action_strength("move_forwards")
	direction += transform.basis.z * Input.get_action_strength("move_backwards")
	direction -= transform.basis.x * Input.get_action_strength("move_left")
	direction += transform.basis.x * Input.get_action_strength("move_right")
	direction = direction.normalized()
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	var jump := Input.is_action_just_pressed("jump")
	
	if direction.length_squared() > 0 and is_on_floor():
		headbob_animation.play("move")
		headbob_animation.playback_speed = lerp(0, 1, mover.h_velocity.length() / mover.max_horizontal_speed)
	else:
		headbob_animation.play("idle")
		headbob_animation.playback_speed = 1.0
		
	mover.direction = direction
	mover.jump = jump
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sensitivity * event.relative.x
		head.rotation_degrees.x -= mouse_sensitivity * event.relative.y
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -head_max_pitch, head_max_pitch)
