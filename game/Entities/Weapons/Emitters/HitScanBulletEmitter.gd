extends BulletEmitter
class_name HitScanBulletEmitter

const DISTANCE := 10000

var HitEffect := preload("res://Entities/Weapons/Effects/BulletHitEffect.tscn")

func attack(fire_point: Position3D, collision_mask: int) -> void:
	var space_state = get_world().get_direct_space_state()
	var pos := fire_point.global_transform.origin
	var result = space_state.intersect_ray(
		pos,
		pos - fire_point.global_transform.basis.z * DISTANCE, 
		[], 
		collision_mask,
		true,
		true
	)
	
	if result and result.collider.has_method("hurt"):
		result.collider.hurt(damage, result.normal)
	elif result:
		var hit_effect = HitEffect.instance()
		get_tree().get_root().add_child(hit_effect)
		hit_effect.global_transform.origin = result.position
		
		if result.normal.angle_to(Vector3.UP) < 0.00005:
			return
		if result.normal.angle_to(Vector3.DOWN) < 0.00005:
			hit_effect.rotate(Vector3.RIGHT, PI)
			return
		
		var y = result.normal
		var x = y.cross(Vector3.UP)
		var z = x.cross(y)
		
		hit_effect.global_transform.basis = Basis(x, y, z)
