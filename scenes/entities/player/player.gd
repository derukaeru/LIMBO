extends CharacterBody3D

@onready var spring_arm: SpringArm3D = $ArmContainer/SpringArm3D

var speed: float = 9.8
var look_sensitivity: float = 0.2

var jump_force: float = 9.4
var gravity: float = 19.8

var mouse_delta := Vector2.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		mouse_delta = event.relative * look_sensitivity

func _physics_process(delta) -> void:
	spring_arm.rotation_degrees.y -= mouse_delta.x 
	spring_arm.rotation_degrees.x -= mouse_delta.y  
	spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -60, 40) 
	mouse_delta = Vector2.ZERO  

	var direction = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		direction -= spring_arm.transform.basis.z 
	if Input.is_action_pressed("backward"):
		direction += spring_arm.transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= spring_arm.transform.basis.x
	if Input.is_action_pressed("right"):
		direction += spring_arm.transform.basis.x

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

func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_cancel"):  
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_action_pressed("zoom_in"):
		spring_arm.spring_length -= 0.2  
	if Input.is_action_pressed("zoom_out"):
		spring_arm.spring_length += 0.2
	
	spring_arm.spring_length = clamp(spring_arm.spring_length, -1.6, INF)
