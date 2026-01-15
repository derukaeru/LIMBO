extends MeshInstance3D

var energy := 100

func _process(_delta):
	if energy <= 0:
		queue_free()

func _on_lose_energy_timeout():
	energy -= 1
