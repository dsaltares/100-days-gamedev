tool
extends Spatial
class_name WeaponManager

export (NodePath) var fire_point_path
export var sway := 30.0

onready var weapon_container := $Weapons
onready var hand_pos := $HandPos

var current_slot := 0
var current_weapon: Weapon = null

func _get_configuration_warning():
	if not fire_point_path:
		return 'Fire point not set'
	return ''
	
func _ready() -> void:
	if not Engine.editor_hint:
		switch_to_weapon_slot(0)
		weapon_container.set_as_toplevel(true)

func attack(attack_just_pressed: bool) -> void:
	if not fire_point_path:
		return

	if not current_weapon:
		return

	var fire_point: Spatial = get_node(fire_point_path)
	current_weapon.attack(fire_point, attack_just_pressed)

func switch_to_next_weapon() -> void:
	var weapon_count := weapon_container.get_child_count()
	var slot = (current_slot + 1) % weapon_count
	switch_to_weapon_slot(slot)

func switch_to_prev_weapon() -> void:
	var weapon_count := weapon_container.get_child_count()
	var slot = posmod(current_slot -1, weapon_count)
	switch_to_weapon_slot(slot)


func switch_to_weapon_slot(slot: int) -> void:
	var weapon_count := weapon_container.get_child_count()
	if slot >= weapon_count:
		return
		
	for weapon in weapon_container.get_children():
		weapon.set_inactive()

	current_slot = slot
	current_weapon = weapon_container.get_child(current_slot)
	current_weapon.set_active()

func _process(delta: float) -> void:
	if Engine.editor_hint:
		return
		
	if not weapon_container:
		return

	_ensure_right_weapon_selected()
	_update_weapon_sway(delta)

func _ensure_right_weapon_selected() -> void:
	var weapon_count := weapon_container.get_child_count()
	current_slot = int(min(weapon_count, current_slot))
	
	if weapon_count <= current_slot:
		switch_to_weapon_slot(weapon_count - 1)

func _update_weapon_sway(delta: float) -> void:
	var weapon_quat : Quat = weapon_container.global_transform.basis.get_rotation_quat()
	var hand_quat : Quat = hand_pos.global_transform.basis.get_rotation_quat()
	weapon_container.global_transform.origin = hand_pos.global_transform.origin
	weapon_container.global_transform.basis = Basis(weapon_quat.slerp(hand_quat, sway * delta))
