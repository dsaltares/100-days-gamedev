extends Node
class_name Health

signal health_changed(health)
signal died

export var health := 100.0

func hurt(damage: int) -> void:
	if health <= damage:
		health = 0.0
	else:
		health -= damage
		
	emit_signal("health_changed", health)
	
	if health == 0:
		emit_signal("died")
	
