extends Node

func get_main():
	return get_tree().current_scene

func get_group_node(group):
	return get_tree().get_first_node_in_group(group)
