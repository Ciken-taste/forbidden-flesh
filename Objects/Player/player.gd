extends CharacterBody3D



const JUMP_VELOCITY : float = 5.5


# Speed dict toimii muistina. Jos haluat muuttaa pelaajan nopeutta, muuta tästä vaan!
const SPEED_DICT : Dictionary = {"walk": 0.1, "roll": 0.2, "run": 0.3}

var target_rotation : Vector3 = Vector3.ZERO
var input_dir : Vector2 = Vector2.ZERO

var stamina : float = 100
var health : int = 100

# Roll_cooldown estää rollin spämmimistä
var rolling : bool = false
var roll_cooldown : bool = false

# Run cooldown pistää pelaajan kävelee ku stamina loppuu
var running : bool = false
var run_cooldown : bool = false

@onready var cam_boom := $CameraBoom as Node3D
@onready var mesh := $Mesh as MeshInstance3D

@onready var stamina_bar := $HUD/StaminaBar as ProgressBar
@onready var exhausting_alert := $HUD/StaminaBar/Exhausted as Label

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event) -> void:
	if event.is_action_pressed("run"):
		running = true
	if event.is_action_released("run"):
		running = false
	
	if event.is_action_pressed("roll") and not rolling and not roll_cooldown and is_on_floor() and stamina >= 10 and input_dir:
		stamina -= 10
		rolling = true
		
		# Roll timer ajoittaa roll movementin. 
		($RollTimer as Timer).start()
	


func speed_governor() -> float:
	var speed : float = SPEED_DICT["walk"]
	if not running and stamina < 100: stamina += 0.1
	
	if run_cooldown: return speed
	if running and not rolling and is_on_floor():
		if stamina >= 1:
			speed = SPEED_DICT["run"]
			stamina -= 0.25
		else:
			running = false
			run_cooldown = true
			($RunTimer as Timer).start()
	if rolling:
		speed = SPEED_DICT["roll"]
	return speed


func roll_handler() -> void:
	if rolling:
		# PI/15 perustuu siihen, että timer kestää 0.5s (30 physics tick) 
		# Tässä ajassa pelaajan pitää pyöriä 2PI verran.
		mesh.rotation.x += PI/15
	
	else:
		# Nolla rollauksen, just in case
		mesh.rotation.x = 0
		# Ottaa vastaan wasd inputit
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		# Target rot on cam_boomin rotation. Target rottia käytetään siihen
		# ettei pelaaja voi muuttaa suuntaa kesken rollia.
		target_rotation = cam_boom.rotation


func _physics_process(delta) -> void:
	if run_cooldown: exhausting_alert.show()
	else: exhausting_alert.hide()
	
	stamina_bar.value = stamina
	# Governor kattoo että käveleekö, rollaa vai juokseeko pelaaja
	var speed : float = speed_governor()
	
	# Painovoima
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	roll_handler()
	
	# Hyppy
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var y_change : int = 0
	
	if input_dir.y < 0: # Forward
		position.x -= sin(target_rotation.y) * speed
		position.z -= cos(target_rotation.y) * speed
		mesh.rotation.y = target_rotation.y
		y_change = 1

	if input_dir.y > 0: # Back
		position.x += sin(target_rotation.y) * speed
		position.z += cos(target_rotation.y) * speed
		mesh.rotation.y = target_rotation.y - PI
		y_change = -1
		
	
	var normalize : float = 1
	if y_change != 0: normalize = 0.5
	if input_dir.x < 0: # Left
		position.x += sin(target_rotation.y - PI/2) * speed * normalize
		position.z += cos(target_rotation.y - PI/2) * speed * normalize
		if y_change == 1:
			mesh.rotation.y = target_rotation.y + PI/4
		elif y_change == -1:
			mesh.rotation.y = target_rotation.y + PI/2 + PI/4
		else: 
			mesh.rotation.y = target_rotation.y + PI/2

	if input_dir.x > 0: # Right
		
		position.x += sin(target_rotation.y + PI/2) * speed * normalize
		position.z += cos(target_rotation.y + PI/2) * speed * normalize
		mesh.rotation.y = target_rotation.y - PI/2
		if y_change == 1:
			mesh.rotation.y = target_rotation.y - PI/4
		elif y_change == -1:
			mesh.rotation.y = target_rotation.y - PI/2 - PI/4
		else: 
			mesh.rotation.y = target_rotation.y - PI/2

	
	move_and_slide()


func _on_roll_timer_timeout() -> void:
	if rolling:
		rolling = false
		roll_cooldown = true
		($RollTimer as Timer).start()
	else:
		roll_cooldown = false


func _on_run_timer_timeout():
	run_cooldown = false
