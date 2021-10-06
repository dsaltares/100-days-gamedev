extends KinematicBody
class_name Enemy

onready var health := $Health
onready var health_anim_player := $HealthAnimationPlayer
onready var body_mesh := $Graphics/Body

func _ready() -> void:
	body_mesh.set("material/0", body_mesh.get("material/0").duplicate())

func hurt(damage: float, normal: Vector3) -> void:
	health.hurt(damage)


func _on_Health_health_changed(health) -> void:
	health_anim_player.play("hurt")
