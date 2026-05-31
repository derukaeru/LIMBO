extends Node3D

var ui_node

func _ready() -> void:
	#ui_node = Util.get_group_node("ui")
	pass

func _process(_delta):
	#ui_node.get_node("datura_count").text = "datura: %s" % [Util.get_all_group_node("datura").size()]
	#ui_node.get_node("fps").text = "fps: %d" % [Engine.get_frames_per_second()]
	#ui_node.get_node("cull").text = "cull distance: %d" % [Util.cull_dist]
	
	if Input.is_action_just_pressed("reduce_cull"):
		Util.cull_dist -= 5
	elif Input.is_action_just_pressed("increase_cull"):
		Util.cull_dist += 5

func generate_flowers():
	var datura = load(Registry.UID["datura"])
	
	for i in 10:
		var d = datura.instantiate()
		d.position = Vector3(randf_range(-100, 100), 1000, randf_range(-100, 100))
		
		Util.get_group_node("flowers").add_child(d)
