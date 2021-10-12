extends Spatial
class_name PathFollower

var navigation : Navigation = null
var target_position : Vector3 = Vector3.ZERO
var path := [] setget _set_path
var path_index := 0
var move_vec : Vector3 = Vector3.ZERO

const arrive_threshold := 0.1

func _physics_process(delta: float) -> void:
	if target_position == Vector3.ZERO:
		return
		
	if not navigation:
		return
	
	PathfindManager.find_path(self, navigation)
	
	if path_index >= path.size():
		return
	
	var our_position = global_transform.origin
	our_position.y = 0.0
	
	var next_path_position = path[path_index]
	next_path_position.y = 0.0
	
	while our_position.distance_squared_to(next_path_position) < arrive_threshold * arrive_threshold and path_index < path.size() - 1:
		path_index += 1
		next_path_position = path[path_index]
		next_path_position.y = 0.0
	
	move_vec = our_position.direction_to(next_path_position)

func _process(delta: float) -> void:
	_debug_draw()
	
func _set_path(new_path : Array) -> void:
	path = new_path
	path_index = 0

func _debug_draw() -> void:
	for i in range(path.size() - 1):		
		DebugDraw.draw_line_3d(path[i], path[i + 1], Color.red)
