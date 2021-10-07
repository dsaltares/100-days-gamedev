tool
extends ViewportContainer
class_name WeaponViewport

export (NodePath) var main_camera_path = null

onready var viewport := $Viewport
onready var camera := $Viewport/Camera

func _get_configuration_warning():
	if not main_camera_path:
		return 'Camera not set'
		
	return ''

func _ready() -> void:
	viewport.size = Vector2(
		ProjectSettings.get_setting("display/window/size/width"),
		ProjectSettings.get_setting("display/window/size/height")
	)
	
func _process(delta: float) -> void:
	if Engine.editor_hint:
		return
		
	var main_camera : Camera = get_node(main_camera_path)
	camera.global_transform = main_camera.global_transform
