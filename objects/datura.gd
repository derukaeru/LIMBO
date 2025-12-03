extends MeshInstance3D

var player
var spawn_radius:float = 4.2

var has_pos := false

var age_min := 20 # seconds
var age_max := 60 # seconds

var reproduction_min := 3 # seconds
var reproduction_max := 5 # seconds

var offspring_chance := 0.75 # percentage

func _ready():
	player = G.gn("player")
	$age.wait_time = randi_range(age_min, age_max)
	$age.start()
	
	$reproduce.wait_time = randi_range(reproduction_min, reproduction_max)
	$reproduce.start()
	
	rotation.y = randf_range(0, 360)
	
	$anim.wait_time = randf_range(0, 1)
	$anim.start()

func _process(delta):
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

func reproduce():
	if randf() <= offspring_chance:
		var datura = preload("res://objects/datura.tscn")
		var d = datura.instantiate()
		d.position = Vector3(position.x + randf_range(-spawn_radius, spawn_radius), 1000, position.z + randf_range(-spawn_radius, spawn_radius))
		G.gn("flowers").get_node("datura").add_child(d)
	
	$reproduce.wait_time = randi_range(reproduction_min, reproduction_max)

func die():
	queue_free()


func _on_anim_timeout():
	$StaticBody3D/model/AnimationPlayer.play("idle")
