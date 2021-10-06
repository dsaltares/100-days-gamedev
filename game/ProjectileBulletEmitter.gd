extends BulletEmitter
class_name ProjectileBulletEmitter

export (PackedScene) var Projectile = null
export var damage := 1.0

func attack(fire_point: Position3D, collision_mask: int):
	var projectile = Projectile.instance()
	projectile.global_transform = fire_point.global_transform
	projectile.collision_mask = collision_mask
	projectile.damage = damage
	get_tree().root.add_child(projectile)
