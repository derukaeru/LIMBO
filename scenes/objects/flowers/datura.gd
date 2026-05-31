extends MeshInstance3D

@onready var anim: AnimationPlayer = $StaticBody3D/model/AnimationPlayer
@onready var _raycast: RayCast3D = $StaticBody3D/RayCast3D
@onready var detect_corpse: Area3D = $detect_corpse

var spawn_radius: float = 10.0
var energy: float = 50.0 # the sun energy thing

var player: CharacterBody3D
var has_pos := false

var age_min: float = 20.0 # seconds
var age_max: float = 60.0 # seconds

var reproduction_min: float = 6.0 # seconds
var reproduction_max: float = 20.0 # seconds

var offspring_chance := 0.80 # percentage

func _ready() -> void:
	player = Util.gn("player")
	
	# aging
	get_tree().create_timer(randf_range(age_min, age_max)).timeout.connect(die)
	
	# reproduce
	get_tree().create_timer(randf_range(reproduction_min, reproduction_max)).timeout.connect(reproduce)
	
	# set random rot
	rotation.y = randf_range(0, 360)
	
	# start idle animation at random times
	get_tree().create_timer(randf_range(0, 1)).timeout.connect(func() -> void: anim.play("idle"))
	

func _process(_delta) -> void:
	if not has_pos:
		if _raycast.is_colliding():
			var collision_point = _raycast.get_collision_point()
			position = collision_point
			has_pos = true
			
			if position.y <= Util.get_group_node("terrain").water_height:
				queue_free()
	
	if player:
		var dist: float = global_position.distance_to(player.global_position)
		if dist > GameManager.cull_dist:
			visible = false
			set_physics_process(false)
		else:
			visible = true
			set_physics_process(true)
	
	if energy <= 0:
		die()
	
func reproduce() -> void:
	if randf() <= offspring_chance:
		var datura = load(Registry.UID["datura"]).instantiate()
		datura.position = Vector3(position.x + randf_range(-spawn_radius, spawn_radius), 1000, position.z + randf_range(-spawn_radius, spawn_radius))
		Util.get_group_node("flowers").get_node("datura").add_child(datura)
	
	get_tree().create_timer(randf_range(reproduction_min, reproduction_max)).timeout.connect(reproduce)
	energy = round(energy * 0.75)

func die() -> void:
	var corpse = load(Registry.UID["flower_corpse"]).instantiate()
	
	corpse.position = position
	corpse.energy = energy
	
	Util.get_group_node("flowers").get_node("corpse").add_child(corpse)
	queue_free()


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
