extends Node

var cull_dist := 55

func gm():
	return get_tree().current_scene

func gn(group):
	return get_tree().get_first_node_in_group(group)
