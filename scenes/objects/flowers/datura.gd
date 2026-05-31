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

var offspring_chance: float = 0.80 # percentage

var sun_energy_speed: float = 1.0
var lose_energy_speed: float = 2.0

func _ready() -> void:
	player = Util.get_group_node("player")
	
	# aging
	get_tree().create_timer(randf_range(age_min, age_max)).timeout.connect(die)
	
	# reproduce
	get_tree().create_timer(randf_range(reproduction_min, reproduction_max)).timeout.connect(reproduce)
	
	# set random rot
	rotation.y = randf_range(0, 360)
	
	# start idle animation at random times
	get_tree().create_timer(randf_range(0, 1)).timeout.connect(func() -> void: anim.play("idle"))
	
	# get corpse energy
	get_tree().create_timer(0.8).timeout.connect(get_corpse_energy)
	
	# get sun energy
	get_tree().create_timer(sun_energy_speed).timeout.connect(get_sun)
	
	# lose energy
	get_tree().create_timer(lose_energy_speed).timeout.connect(lose_energy)

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
		Util.get_group_node("flowers").add_child(datura)
	
	get_tree().create_timer(randf_range(reproduction_min, reproduction_max)).timeout.connect(reproduce)
	energy = round(energy * 0.75)

func die() -> void:
	var corpse = load(Registry.UID["flower_corpse"]).instantiate()
	
	corpse.position = position
	corpse.energy = energy
	
	Util.get_group_node("flowers").add_child(corpse)
	queue_free()


func get_corpse_energy() -> void:
	var areas = detect_corpse.get_overlapping_areas()
	for a in areas:
		if(a.is_in_group("flower_corpse")):
			if a.energy > 0:
				a.energy -= 1
				energy += 1
	
	get_tree().create_timer(0.8).timeout.connect(get_corpse_energy)

func get_sun() -> void:
	# if daytime get energy 
	# else dont
	
	energy += 1
	get_tree().create_timer(sun_energy_speed).timeout.connect(get_sun)

func lose_energy() -> void:
	energy -= 1
	
	get_tree().create_timer(lose_energy_speed).timeout.connect(lose_energy)
