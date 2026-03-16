extends Node3D

var ui_node

func _ready():
	ui_node = G.gn("ui")

func _process(_delta):
	ui_node.get_node("datura_count").text = "datura: %s" % [$flowers/datura.get_child_count()]
	ui_node.get_node("fps").text = "fps: %d" % [Engine.get_frames_per_second()]
	ui_node.get_node("cull").text = "cull distance: %d" % [G.cull_dist]
	
	if Input.is_action_just_pressed("reduce_cull"):
		G.cull_dist -= 5
	elif Input.is_action_just_pressed("increase_cull"):
		G.cull_dist += 5

func generate_flowers():
	var datura = preload("res://objects/datura.tscn")
	
	for i in 10:
		var d = datura.instantiate()
		d.position = Vector3(randf_range(-100, 100), 1000, randf_range(-100, 100))
		
		$flowers/datura.add_child(d)
