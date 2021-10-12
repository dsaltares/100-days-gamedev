extends Spatial
class_name Vision

signal seen(node)
signal lost(node)

export var vision_cone_arc := 60.0
export var max_distance := 50.0
export (Array, String) var groups := []
export (int, LAYERS_3D_PHYSICS) var collision_mask := 1

var vision_map := {}

func can_see(node: Spatial) -> bool:
	return vision_map.has(node)

func _process(delta: float) -> void:
	var visited := {}
	for group in groups:
		var nodes = get_tree().get_nodes_in_group(group)
		for node in nodes:
			if visited.has(node):
				continue
			
			var point : Vector3 = node.global_transform.origin
			if node.has_method("get_aim_at_position"):
				point = node.get_aim_at_position()
			
			var prev_state : bool = vision_map.get(node, false)
			var new_state := _close_enough(point) and _in_vision_cone(point) and _has_los(point)
			
			if new_state and not prev_state:
				emit_signal("seen", node)
			elif prev_state and not new_state:
				emit_signal("lost", node)
			
			vision_map[node] = new_state
			visited[node] = true

func _close_enough(point: Vector3) -> bool:
	var our_position := global_transform.origin
	var to_point := point - our_position
	return to_point.length_squared() <= max_distance * max_distance

func _in_vision_cone(point: Vector3) -> bool:
	var forward := -global_transform.basis.z
	var our_position := global_transform.origin
	var dir_to_point := point - our_position
	return rad2deg(dir_to_point.angle_to(forward)) <= vision_cone_arc * 0.5

func _has_los(point: Vector3) -> bool:
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(global_transform.origin, point, [], collision_mask)
	return !result
