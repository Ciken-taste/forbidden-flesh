extends CharacterBody3D


const SPEED : float = 0.2
const JUMP_VELOCITY : float = 4.5
const MOUSE_SENSITIVITY : float = -0.01

var target_rotation : Vector3 = Vector3.ZERO
var input_dir : Vector2 = Vector2.ZERO
var rolling : bool = false

@onready var cam_boom : Node3D = $CameraBoom
@onready var mesh : MeshInstance3D = $Mesh

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
	if event.is_action_pressed("roll"):
		rolling = true
		$RollTimer.start()
	
	if event is InputEventMouseMotion:
		cam_boom.rotation.y += event.relative.x * MOUSE_SENSITIVITY
		cam_boom.rotation.x += event.relative.y * MOUSE_SENSITIVITY
		cam_boom.rotation.x = clamp(cam_boom.rotation.x, -PI/2, PI/2)
		

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
		
	
	if rolling:
		mesh.rotation.x += PI/15
		
	else:
		mesh.rotation.x = 0
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		target_rotation = cam_boom.rotation
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var y_change : int = 0
	
	if input_dir.y < 0: # Forward
		position.x -= sin(target_rotation.y) * SPEED
		position.z -= cos(target_rotation.y) * SPEED
		mesh.rotation.y = target_rotation.y
		y_change = 1

	if input_dir.y > 0: # Back
		position.x += sin(target_rotation.y) * SPEED
		position.z += cos(target_rotation.y) * SPEED
		mesh.rotation.y = target_rotation.y - PI
		y_change = -1
		
	
	var normalize : float = 1
	if y_change != 0: normalize = 0.5
	if input_dir.x < 0: # Left
		position.x += sin(target_rotation.y - PI/2) * SPEED * normalize
		position.z += cos(target_rotation.y - PI/2) * SPEED * normalize
		if y_change == 1:
			mesh.rotation.y = target_rotation.y + PI/4
		elif y_change == -1:
			mesh.rotation.y = target_rotation.y + PI/2 + PI/4
		else: 
			mesh.rotation.y = target_rotation.y + PI/2

	if input_dir.x > 0: # Right
		
		position.x += sin(target_rotation.y + PI/2) * SPEED * normalize
		position.z += cos(target_rotation.y + PI/2) * SPEED * normalize
		mesh.rotation.y = target_rotation.y - PI/2
		if y_change == 1:
			mesh.rotation.y = target_rotation.y - PI/4
		elif y_change == -1:
			mesh.rotation.y = target_rotation.y - PI/2 - PI/4
		else: 
			mesh.rotation.y = target_rotation.y - PI/2

	
	move_and_slide()


func _on_roll_timer_timeout():
	rolling = false
