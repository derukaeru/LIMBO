extends Node

func get_main() -> Node:
	return get_tree().current_scene

func get_group_node(group) -> Node:
	return get_tree().get_first_node_in_group(group)

func get_all_group_node(group) -> Array:
	return get_tree().get_nodes_in_group(group)
	
