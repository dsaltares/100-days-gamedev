tool
extends Spatial
class_name WeaponManager

export (NodePath) var fire_point_path

onready var weapon_container := $Weapons

var current_slot := 0
var current_weapon: Weapon = null 

func _get_configuration_warning():
	if not fire_point_path:
		return 'Fire point not set'
	return ''

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

	current_slot = slot
	current_weapon = weapon_container.get_child(current_slot)

func _process(delta: float) -> void:
	if not weapon_container:
		return

	var weapon_count := weapon_container.get_child_count()
	current_slot = int(min(weapon_count, current_slot))

	if current_slot < weapon_count:
		current_weapon = weapon_container.get_child(current_slot)
	else:
		current_weapon = null
