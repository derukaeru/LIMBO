extends MeshInstance3D

@export var size_x := 200       # world size in meters
@export var size_z := 200
@export var resolution := 60  # how many vertices per dimension
@export var noise_scale := 0.04
@export var height_scale := 16.0
var water_height := -3.5

var noise := FastNoiseLite.new()

func _ready():
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


func add_water():
	var plane := $water
	plane.mesh.size = Vector2(size_x, size_z)
	
	plane.position.y = water_height
	plane.position.x = size_x/2
	plane.position.z = size_z/2
	
func generate_mesh() -> ArrayMesh:
	var mesh_data = ArrayMesh.new()

	var positions: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var uvs: PackedVector2Array = []
	var indices: PackedInt32Array = []

	var x_step = float(size_x) / resolution
	var z_step = float(size_z) / resolution

	# Build vertex grid
	for z in range(resolution + 1):
		for x in range(resolution + 1):
			var world_x = x * x_step
			var world_z = z * z_step
			var h = noise.get_noise_2d(world_x, world_z) * height_scale

			positions.append(Vector3(world_x, h, world_z))
			uvs.append(Vector2(float(x) / resolution, float(z) / resolution))

	# Triangles
	# vertex index formula: i = z * (resolution + 1) + x
	var row_len = resolution + 1

	for z in range(resolution):
		for x in range(resolution):
			var i = z * row_len + x
			var i_right = i + 1
			var i_down = i + row_len
			var i_down_right = i_down + 1

			# first triangle (flip order)
			indices.append(i)
			indices.append(i_right)
			indices.append(i_down)

			# second triangle
			indices.append(i_right)
			indices.append(i_down_right)
			indices.append(i_down)


	# Calculate normals
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

	# Build surface
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
	
	G.gm().generate_flowers()
	
	return mesh_data
