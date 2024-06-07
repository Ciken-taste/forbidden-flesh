extends CharacterBody3D



const JUMP_VELOCITY : float = 5.5


# Speed dict toimii muistina. Jos haluat muuttaa pelaajan nopeutta, muuta tästä vaan!
const SPEED_DICT : Dictionary = {"walk": 0.05, "roll": 0.1, "run": 0.15, "attack": 0.2}

var target_rotation : Vector3 = Vector3.ZERO
var input_dir : Vector2 = Vector2.ZERO

var stamina : float = 100
var health : int = 100

# Roll_cooldown estää rollin spämmimistä
var rolling : bool = false
var roll_cooldown : bool = false

var inside_sword : bool = false

# Run cooldown pistää pelaajan kävelee ku stamina loppuu
var running : bool = false
var run_cooldown : bool = false

var invincible : bool = false
var dead : bool = false

@onready var hit_audio := $HitAudio as AudioStreamPlayer3D
@onready var death_timer := $DeathTimer as Timer
@onready var blood_splatter := $Mesh/GPUParticles3D as GPUParticles3D
var splat_ready : bool = true

@onready var roll_audio := $RollAudio as AudioStreamPlayer3D
@onready var cam_boom := $CameraBoom as Node3D
@onready var mesh := $Mesh as MeshInstance3D

# Sword vars, Sword areoita on 2 jotta hitreg toimis paremmin
@onready var sword := $Mesh/Sword as Node3D
@onready var sword_audio := $SwordAudio as AudioStreamPlayer3D

# Sword animation vars
@onready var swing_timer := $Mesh/Sword/SwingTimer as Timer
@onready var return_swing_timer := $Mesh/Sword/ReturnSwingTimer as Timer
@onready var sword_rot : float = sword.rotation.y
var attacking : bool = false
var lunging : bool = false
var sword_dir : int = 1


@onready var health_bar := $HUD/HealthBar as ProgressBar
@onready var stamina_bar := $HUD/StaminaBar as ProgressBar
@onready var exhausting_alert := $HUD/StaminaBar/Exhausted as Label

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var global_vars : Object = get_node("/root/global")

func _input(event) -> void:
	if event.is_action_pressed("attack") and not attacking and stamina >= 5:
		global_vars.player_attack = true
		sword_audio.play(0.3)
		stamina -= 5
		attacking = true
		lunging = true
		swing_timer.start()
		return_swing_timer.start()
	
	if event.is_action_pressed("lock_on"): ($HUD/LockOn as Control).show()
	if event.is_action_released("lock_on"): ($HUD/LockOn as Control).hide()
	if event.is_action_pressed("run"):
		running = true
	if event.is_action_released("run"):
		running = false
	if event.is_action_pressed("roll") and not rolling and not roll_cooldown and is_on_floor() and stamina >= 10 and input_dir:
		stamina -= 10
		rolling = true
		# Roll timer ajoittaa roll movementin. 
		($RollTimer as Timer).start()
		roll_audio.play()


func attack() -> void:
	const ATTACK_SPEED = PI/10
	if attacking: sword.rotation.y += ATTACK_SPEED * sword_dir

func speed_governor() -> float:
	var speed : float = SPEED_DICT["walk"]
	if lunging: return SPEED_DICT["attack"]
	if (not running or run_cooldown or not is_on_floor()) and stamina < 100: stamina += 0.15
	if rolling and not running: 
		return SPEED_DICT["roll"]
	if run_cooldown: return speed
	if running and is_on_floor():
		if stamina >= 1:
			speed = SPEED_DICT["run"]
			stamina -= 0.175
		else:
			running = false
			run_cooldown = true
			($RunTimer as Timer).start()
	return speed


func roll_handler() -> void:
	if rolling:
		# PI/15 perustuu siihen, että timer kestää 0.5s (30 physics tick) 
		# Tässä ajassa pelaajan pitää pyöriä 2PI verran.
		mesh.rotation.x += PI/15
	
	elif not attacking:
		# Nolla rollauksen, just in case
		mesh.rotation.x = 0
		# Ottaa vastaan wasd inputit
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		# Target rot on cam_boomin rotation. Target rottia käytetään siihen
		# ettei pelaaja voi muuttaa suuntaa kesken rollia.
		target_rotation = cam_boom.rotation


func death() -> void:
	if health <= 0:
		death_timer.start()
		dead = true
		mesh.hide()
		var dead_player = preload("res://Objects/Player/dead_player.tscn").instantiate()
		add_child(dead_player)

func _physics_process(delta) -> void:
	# Blood splat and invincibility frames
	if inside_sword and not rolling and health > 0 and not invincible:
		invincible = true
		if splat_ready: 
			splat_ready = false
			blood_splatter.emitting = true
		($InvincibilityTimer as Timer).start()
		health -= 15
		hit_audio.play()
	velocity.x = 0
	velocity.z = 0
	if dead: return
	death()
	if run_cooldown: exhausting_alert.show()
	else: exhausting_alert.hide()
	
	health_bar.value = health
	stamina_bar.value = stamina
	
	

	attack()
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
		($Mesh/Sword/DamageArea as Area3D).monitorable = true
		rolling = false
		roll_cooldown = true
		($RollTimer as Timer).start()
	else:
		roll_cooldown = false

# Used in respawning
func remove_player() -> void: queue_free()

func _on_run_timer_timeout() -> void:
	run_cooldown = false


func _on_area_3d_area_entered(area) -> void:
	if area.is_in_group("EnemySword"): inside_sword = true
	elif area.is_in_group("InstaDeath"): health = 0

func _on_area_3d_area_exited(area) -> void:
	if area.is_in_group("EnemySword"): inside_sword = false


func _on_death_timer_timeout() -> void:
	if death_timer.wait_time == 2:
		death_timer.wait_time = 0.05
		($HUD/Death/AudioStreamPlayer as AudioStreamPlayer).play()
	elif ($HUD/Death as ColorRect).modulate.a < 0.9:
		($HUD/Death as ColorRect).modulate.a += 0.01
	death_timer.start()




func _on_invincibility_timer_timeout():
	invincible = false
	($InvincibilityTimer as Timer).stop()


func _on_gpu_particles_3d_finished():
	splat_ready = true


func _on_swing_timer_timeout():
	global_vars.player_attack = false
	lunging = false
	sword_dir = -1

func _on_return_swing_timer_timeout():
	sword_dir = 1
	attacking = false
	sword.rotation.y = sword_rot
