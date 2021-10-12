tool
extends Spatial
class_name Weapon

export var automatic := false
export var max_ammo := 1
export var attack_rate := 0.2
export (int, LAYERS_3D_PHYSICS) var collision_mask := 1 + 2

var can_attack := true
var attack_timer := Timer.new()
var current_ammo := 0
var bullet_emitter

onready var graphics := $Graphics
onready var muzzle_flash := $Graphics/MuzzleFlash
onready var animation_player := $AnimationPlayer

func _get_configuration_warning():
	if _get_emitter() == null:
		return 'Bullet emitter not set'
		
	return ''

func _ready() -> void:
	current_ammo = max_ammo
	
	attack_timer.wait_time = attack_rate
	attack_timer.one_shot = true
	attack_timer.connect("timeout", self, "_on_AttackTimer_timeout")
	add_child(attack_timer)

func attack(fire_point: Position3D, attack_just_pressed: bool) -> void:
	if not can_attack:
		return
	
	if not automatic and not attack_just_pressed:
		return

	if current_ammo <= 0:
		return
		
	current_ammo -= 1
	can_attack = false
	attack_timer.start()
	_get_emitter().attack(fire_point, collision_mask)
	muzzle_flash.flash()
	
	if animation_player.has_animation("attack"):
		animation_player.stop()
		animation_player.play("attack")

func set_active():
	show()
	$Crosshair.show()

func set_inactive():
	hide()
	$Crosshair.hide()

func _get_emitter() -> BulletEmitter:
	for child in get_children():
		if child is BulletEmitter:
			return child
	
	return null

func _on_AttackTimer_timeout() -> void:
	can_attack = true
