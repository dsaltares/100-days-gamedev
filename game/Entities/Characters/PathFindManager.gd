extends Node

var queue := []
var cache := {}
var paths_per_turn := 5

func _physics_process(delta: float) -> void:
	for i in range(paths_per_turn):
		dequeue_path_request()

func find_path(agent: Node, nav: Navigation):
	var key := str(agent)
	
	if key in cache:
		return
		
	cache[key] = true
	queue.append({
		"agent": agent,
		"nav": nav,
	})
	
func dequeue_path_request():
	if queue.size() == 0:
		return 
		
	var calc_path_info = queue.pop_front()
	var agent: Node = calc_path_info.agent
	
	if not agent:
		return
	
	var nav: Navigation = calc_path_info.nav
	var start_pos : Vector3 = agent.global_transform.origin
	var end_pos : Vector3 = agent.target_position
	var new_path = nav.get_simple_path(start_pos, end_pos)
	agent.path = new_path
	cache.erase(str(agent))

func _ready() -> void:
	pass
