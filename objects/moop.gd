extends RigidBody3D

enum STATES {IDLE, SEARCHING, DESPERATE, SLEEPING, RUNNING, ALERT}
var current_state:STATES = STATES.IDLE

func _process(_delta):
	if current_state == STATES.IDLE:
		pass
