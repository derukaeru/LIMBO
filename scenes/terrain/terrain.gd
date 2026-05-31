extends MeshInstance3D

var size_x: float = 200.0
var size_z: float = 200.0

var resolution: int = 60
var noise_scale: float = 0.04
var height_scale: float = 16.0
var water_height: float= -3.5

var noise: FastNoiseLite = FastNoiseLite.new()

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_scale
	
	mesh = generate_mesh()

func create_collision_shape(positions: PackedVector3Array, indices: PackedInt32Array) -> CollisionShape3D:
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(indices_to_faces(positions, indices))

	var col := CollisionShape3D.new()
	col.shape = shape
	return col

func indices_to_faces(positions: PackedVector3Array, indices: PackedInt32Array) -> PackedVector3Array:
	var faces := PackedVector3Array()
	faces.resize(indices.size())
	for i in range(indices.size()):
		faces[i] = positions[indices[i]]
	return faces

func add_water() -> void:
	var plane := $water
	plane.mesh.size = Vector2(size_x, size_z)
	
	plane.position.y = water_height
	
	plane.position.x = round(size_x / 2)
	plane.position.z = round(size_z / 2)
	
func generate_mesh() -> ArrayMesh:
	var mesh_data = ArrayMesh.new()

	var positions: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var uvs: PackedVector2Array = []
	var indices: PackedInt32Array = []

	var x_step = float(size_x) / resolution
	var z_step = float(size_z) / resolution

	for z in range(resolution + 1):
		for x in range(resolution + 1):
			var world_x = x * x_step
			var world_z = z * z_step
			var h = noise.get_noise_2d(world_x, world_z) * height_scale

			positions.append(Vector3(world_x, h, world_z))
			uvs.append(Vector2(float(x) / resolution, float(z) / resolution))

	var row_len = resolution + 1

	for z in range(resolution):
		for x in range(resolution):
			var i = z * row_len + x
			var i_right = i + 1
			var i_down = i + row_len
			var i_down_right = i_down + 1

			indices.append(i)
			indices.append(i_right)
			indices.append(i_down)

			indices.append(i_right)
			indices.append(i_down_right)
			indices.append(i_down)

	normals.resize(positions.size())
	for i in range(0, indices.size(), 3):
		var a = indices[i]
		var b = indices[i + 1]
		var c = indices[i + 2]

		var p1 = positions[a]
		var p2 = positions[b]
		var p3 = positions[c]

		var normal = ((p2 - p1).cross(p3 - p1)).normalized()

		normals[a] += normal
		normals[b] += normal
		normals[c] += normal

	for n in range(normals.size()):
		normals[n] = normals[n].normalized()

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = positions
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	mesh_data.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	var static_body = $StaticBody3D

	var col := create_collision_shape(positions, indices)
	static_body.add_child(col)
	
	position.x = -size_x/2
	position.z = -size_z/2
	
	add_water()
	Util.get_main().generate_flowers()
	
	return mesh_data
