extends Area3D

var energy: float = 30.0

func _ready() -> void:
	get_tree().create_timer(1.5).timeout.connect(lose_energy)

func _process(_delta) -> void:
	if energy <= 0:
		queue_free()

func lose_energy() -> void:
	energy -= 1
