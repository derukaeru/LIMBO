extends MeshInstance3D

var player
var spawn_radius:float = 10

var energy := 50 # the sun energy thing

var has_pos := false

var age_min := 20 # seconds
var age_max := 60 # seconds

var reproduction_min := 6 # seconds
var reproduction_max := 20 # seconds

var offspring_chance := 0.80 # percentage

func _ready():
	player = G.gn("player")
	$age.wait_time = randi_range(age_min, age_max)
	$age.start()
	
	$reproduce.wait_time = randi_range(reproduction_min, reproduction_max)
	$reproduce.start()
	
	rotation.y = randf_range(0, 360)
	
	$anim.wait_time = randf_range(0, 1)
	$anim.start()

func _process(_delta):
	if not has_pos:
		if $StaticBody3D/RayCast3D.is_colliding():
			var collision_point = $StaticBody3D/RayCast3D.get_collision_point()
			position = collision_point
			has_pos = true
			
			if position.y <= G.gn("terrain").water_height:
				queue_free()
	
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist > G.cull_dist:
			visible = false
			set_physics_process(false)
		else:
			visible = true
			set_physics_process(true)
	
	if energy <= 0:
		die()
	
func reproduce():
	if randf() <= offspring_chance:
		var datura = preload("res://objects/datura.tscn")
		var d = datura.instantiate()
		d.position = Vector3(position.x + randf_range(-spawn_radius, spawn_radius), 1000, position.z + randf_range(-spawn_radius, spawn_radius))
		G.gn("flowers").get_node("datura").add_child(d)
	
	$reproduce.wait_time = randi_range(reproduction_min, reproduction_max)
	energy = round(energy * 0.75)

func die():
	var corpse = preload("res://objects/flower_corpse.tscn")
	var c = corpse.instantiate()
	c.position = position
	c.energy = energy
	G.gn("flowers").get_node("corpse").add_child(c)
	
	queue_free()

func _on_anim_timeout():
	$StaticBody3D/model/AnimationPlayer.play("idle")

func _on_get_corpse_energy_timeout():
	var areas = $detect_corpse.get_overlapping_areas()
	for a in areas:
		if(a.name == "flower_corpse"):
			if a.energy > 0:
				a.energy -= 1
				energy += 1

func _on_get_sun_energy_timeout():
	# if daytime get energy 
	# else dont
	energy += 1

func _on_lose_energy_timeout():
	energy -= 1
