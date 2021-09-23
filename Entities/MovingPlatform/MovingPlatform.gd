extends KinematicBody

export var idle_time := 2.0
export var move_to := Vector3.UP * 4.0
export var speed := 1.0

onready var tween := $Tween

func _ready() -> void:
	_init_tween()

func _init_tween() -> void:
	if Engine.editor_hint:
		return

	var duration = move_to.length() / float(speed)
	tween.interpolate_property(
		self,
		"translation",
		translation,
		translation + move_to,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		idle_time
	)
	tween.interpolate_property(
		self,
		"translation",
		translation + move_to,
		translation,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		idle_time * 2.0 + duration
	)
	tween.start()
