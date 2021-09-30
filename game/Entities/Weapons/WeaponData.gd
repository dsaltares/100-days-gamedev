extends Resource
class_name WeaponData

export (PackedScene) var BulletEmitter = null
export var automatic := false
export var max_ammo := 1
export var attack_rate := 0.2
export (int, LAYERS_3D_PHYSICS) var collision_mask := 1
