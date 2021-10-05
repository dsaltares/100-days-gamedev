extends BulletEmitter
class_name PelletBulletEmitter


export var num_pellets := 5
export var min_spread_angle := 2.5
export var max_spread_angle := 5.0

var HitScanBulletEmitter = preload("res://Entities/Weapons/Emitters/HitScanBulletEmitter.tscn")
var hit_scan_emitter : BulletEmitter

func _ready() -> void:
	hit_scan_emitter = HitScanBulletEmitter.instance()
	hit_scan_emitter.damage = damage
	add_child(hit_scan_emitter)

func attack(fire_point: Position3D, collision_mask: int) -> void:
	if num_pellets <= 0:
		return
	
	hit_scan_emitter.rotation_degrees = Vector3.ZERO
	hit_scan_emitter.attack(fire_point, collision_mask)
	
	if num_pellets <= 1:
		return
	
	for i in range(num_pellets - 1):
		hit_scan_emitter.rotation_degrees = _random_pellet_rotation()
		hit_scan_emitter.attack(fire_point, collision_mask)
			
func _random_pellet_rotation() -> Vector3:
	var spread_diff := max_spread_angle - min_spread_angle
	var theta := randf() * 2 * PI
	return Vector3(
		(min_spread_angle + spread_diff) * cos(theta),
		(min_spread_angle + spread_diff) * sin(theta),
		0.0
	)
