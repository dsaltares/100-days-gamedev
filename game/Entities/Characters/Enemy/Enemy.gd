extends KinematicBody
class_name Enemy

export (NodePath) var navigation_path = null
export (NodePath) var target_path = null

onready var health := $Health
onready var health_anim_player := $HealthAnimationPlayer
onready var body_mesh := $Graphics/Body
onready var vision := $Vision
onready var path_follower := $PathFollower
onready var mover := $CharacterMover

func _ready() -> void:
	body_mesh.set("material/0", body_mesh.get("material/0").duplicate())
	path_follower.navigation = get_node(navigation_path)
	
	
func _physics_process(delta: float) -> void:
	path_follower.target_position = get_node(target_path).global_transform.origin
	mover.direction = path_follower.move_vec

func hurt(damage: float, normal: Vector3) -> void:
	health.hurt(damage)


func _on_Health_health_changed(health) -> void:
	health_anim_player.play("hurt")


func _on_Vision_seen(node) -> void:
	print(name + " saw " + node.name)


func _on_Vision_lost(node) -> void:
	print(name + " lost " + node.name)
