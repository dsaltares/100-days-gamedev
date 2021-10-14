extends KinematicBody
class_name Enemy

export (NodePath) var navigation_path = null
export (NodePath) var target_path = null

export var speed_max := 10.0
export var acceleration_max := 100.0
export var angular_speed_max := 360
export var angular_acceleration_max := 1000

var h_velocity := Vector3.ZERO
var v_velocity := Vector3.ZERO
var angular_velocity := 0.0
var linear_drag := 0
var angular_drag := 0.1

onready var health := $Health
onready var health_anim_player := $HealthAnimationPlayer
onready var body_mesh := $Graphics/Body
onready var vision := $Vision

var agent := GSAISteeringAgent.new()
var acceleration := GSAITargetAcceleration.new()
var follow_path := GSAIFollowPath.new(agent, GSAIPath.new([]))
var look := GSAILookWhereYouGo.new(agent)
var follow_blend := GSAIBlend.new(agent)
var priority := GSAIPriority.new(agent)
var target_position := Vector3.ZERO
var path := [] setget _set_path

func hurt(damage: float, normal: Vector3) -> void:
	health.hurt(damage)


func _ready() -> void:
	body_mesh.set("material/0", body_mesh.get("material/0").duplicate())
	
	agent.linear_speed_max = speed_max
	agent.linear_acceleration_max = acceleration_max
	agent.angular_speed_max = deg2rad(angular_speed_max)
	agent.angular_acceleration_max = deg2rad(angular_acceleration_max)
	agent.bounding_radius = 1.0

	
	follow_blend.add(follow_path, 1)
	follow_blend.add(look, 1)
	
	priority.add(follow_blend)
	
func _process(delta: float) -> void:
	_debug_draw()

func _physics_process(delta: float) -> void:
	follow_path.is_arrive_enabled = true
	follow_path.arrival_tolerance = 0.3
	follow_path.deceleration_radius = 2.0
	follow_path.path_offset = 0.1
	follow_path.prediction_time = 0.1
	
	look.use_z = true
	look.deceleration_radius = deg2rad(15.0)
	look.alignment_tolerance = deg2rad(5.0)
	look.time_to_reach = 0.1
	
	
	var target_agent : GSAISteeringAgent = get_node(target_path).agent
	target_position = target_agent.position
	
	PathfindManager.find_path(self, get_node(navigation_path))

	follow_blend.is_enabled = path.size() >= 2
	
	_update_agent()
	
	priority.calculate_steering(acceleration)
	
	h_velocity = h_velocity + Vector3(acceleration.linear.x, 0.0, acceleration.linear.z) * delta
	if h_velocity.length_squared() > agent.linear_speed_max * agent.linear_speed_max:
		h_velocity = h_velocity.normalized() * agent.linear_speed_max

	# This applies drag on the agent's motion, helping it to slow down naturally.
#	h_velocity = h_velocity.linear_interpolate(Vector3.ZERO, linear_drag)
	
	if is_on_ceiling():
		v_velocity = Vector3.ZERO
	elif is_on_floor():
		v_velocity = -get_floor_normal() * 0.1
	else:
		v_velocity += Vector3.DOWN * 9.8 * delta

	# And since we're using a KinematicBody2D, we use Godot's excellent move_and_slide to actually
	# apply the final movement, and record any change in velocity the physics engine discovered.
	
	var movement := Vector3(
		h_velocity.x + v_velocity.x,
		v_velocity.y,
		h_velocity.z + v_velocity.z
	)
	movement = move_and_slide(movement, Vector3.UP)
#	h_velocity = movement
#	h_velocity.y = 0.0

	# We then do something similar to apply our agent's rotational speed.
	angular_velocity = clamp(
		angular_velocity + acceleration.angular * delta, -agent.angular_speed_max, agent.angular_speed_max
	)
	# This applies drag on the agent's rotation, helping it slow down naturally.
	angular_velocity = lerp(angular_velocity, 0, angular_drag)
	rotation.y += angular_velocity * delta
	
	

func _set_path(new_path : Array) -> void:
	path = new_path
	follow_path.path = GSAIPath.new(new_path)
	follow_path.path.is_open = true


func _on_Health_health_changed(health) -> void:
	health_anim_player.play("hurt")


func _on_Vision_seen(node) -> void:
	print(name + " saw " + node.name)


func _on_Vision_lost(node) -> void:
	print(name + " lost " + node.name)

func _update_agent() -> void:
	var transform := global_transform
	var basis := transform.basis
	agent.position = global_transform.origin
	agent.orientation = rotation.y + deg2rad(180)
	agent.linear_velocity = h_velocity
	agent.angular_velocity = angular_velocity

func _debug_draw() -> void:
	for i in range(path.size() - 1):
		DebugDraw.draw_line_3d(path[i], path[i + 1], Color.red)
		DebugDraw.draw_box(path[i + 1], Vector3(0.05, 0.05, 0.05), Color.purple)
