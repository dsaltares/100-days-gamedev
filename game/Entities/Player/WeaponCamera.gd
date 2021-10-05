extends Camera


export (NodePath) var main_camera_path = null

func _process(delta: float) -> void:
	global_transform = get_node(main_camera_path).global_transform
