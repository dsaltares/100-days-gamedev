tool
extends Spatial
class_name Weapon

export (Resource) var weapon_data

var can_attack := true
var current_ammo := 0
var bullet_emitter

func _get_configuration_warning():
	if not weapon_data:
		return 'Weapon data not set'
	if not weapon_data.BulletEmitter:
		return 'Bullet emitter not set'
	return ''

func _ready() -> void:
	current_ammo = weapon_data.max_ammo

func attack(fire_point: Position3D, attack_just_pressed: bool) -> void:
	if not can_attack:
		return
	
	if not weapon_data.automatic and not attack_just_pressed:
		return

	if current_ammo <= 0:
		return
		
	current_ammo -= 1
	_get_emitter().attack(fire_point, weapon_data.collision_mask)

func _get_emitter() -> BulletEmitter:
	if not bullet_emitter:
		bullet_emitter = weapon_data.BulletEmitter.instance()
		add_child(bullet_emitter)
	
	return bullet_emitter
