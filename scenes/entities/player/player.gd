extends CharacterBody3D

@export var speed: float = 9.8
@export var look_sensitivity: float = 0.2 # Reduced for better control

@export var jump_force: float = 9.4      # added
@export var gravity: float = 19.8        # added

var mouse_delta := Vector2.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Lock mouse

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative * look_sensitivity

func _physics_process(delta):
	# Rotate character based on mouse movement
	$Node3D/SpringArm3D.rotation_degrees.y -= mouse_delta.x  # Rotate left/right
	$Node3D/SpringArm3D.rotation_degrees.x -= mouse_delta.y  # Look up/down
	$Node3D/SpringArm3D.rotation_degrees.x = clamp($Node3D/SpringArm3D.rotation_degrees.x, -60, 40)  # Prevent flipping
	mouse_delta = Vector2.ZERO  # Reset after applying

	# Movement
	var direction = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		direction -= $Node3D/SpringArm3D.transform.basis.z  # Move Forward
	if Input.is_action_pressed("backward"):
		direction += $Node3D/SpringArm3D.transform.basis.z  # Move Backward
	if Input.is_action_pressed("left"):
		direction -= $Node3D/SpringArm3D.transform.basis.x  # Move Left
	if Input.is_action_pressed("right"):
		direction += $Node3D/SpringArm3D.transform.basis.x  # Move Right

	if direction != Vector3.ZERO:
		direction = direction.normalized() * speed
	
	velocity.x = direction.x
	velocity.z = direction.z

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_pressed("jump"):
			velocity.y = jump_force
		else:
			velocity.y = 0

	move_and_slide()

func _process(_delta):
	# Toggle mouse lock on ESC
	if Input.is_action_just_pressed("ui_cancel"):  
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_action_pressed("zoom_in"):
		$Node3D/SpringArm3D.spring_length -= 0.2  
	if Input.is_action_pressed("zoom_out"):
		$Node3D/SpringArm3D.spring_length += 0.2
	
	$Node3D/SpringArm3D.spring_length = clamp($Node3D/SpringArm3D.spring_length, -1.6, INF)
