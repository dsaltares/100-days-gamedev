extends KinematicBody
class_name Rocket

export var speed := 20.0
export (Shape) var explosion_shape = null
export var rigid_body_hit_strength := 1.5

var damage := 1.0
var Explosion := preload("res://Entities/Weapons/Effects/Explosion.tscn")

func _physics_process(delta: float) -> void:
	var collision := move_and_collide(-global_transform.basis.z * speed * delta)
	
	if not collision:
		return
		
	var explosion_query := PhysicsShapeQueryParameters.new()
	explosion_query.collision_mask = collision_mask
	explosion_query.transform = global_transform
	explosion_query.set_shape(explosion_shape)

	var space_state := get_world().get_direct_space_state()
	var explosion_query_results := space_state.intersect_shape(explosion_query)
	
	for result in explosion_query_results:
		var collider : Node = result["collider"]
		if collider.has_method("hurt"):
			collider.hurt(damage, collider.global_transform.origin - global_transform.origin)
			
		if collider is RigidBody:
			collider.apply_impulse(
				collider.global_transform.origin,
				(collider.global_transform.origin - global_transform.origin) * rigid_body_hit_strength
			)
	
	var explosion := Explosion.instance()
	explosion.global_transform = global_transform
	get_tree().root.add_child(explosion)
	
	queue_free()
