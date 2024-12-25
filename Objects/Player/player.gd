extends CharacterBody3D


const JUMP_VELOCITY : float = 5.5


# Speed dict toimii muistina. Jos haluat muuttaa pelaajan nopeutta, muuta tästä vaan!
const SPEED_DICT : Dictionary = {"walk": 200, "roll": 350, "run": 500, "attack": 650}

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
var inventory_open : bool = false

var attack_disabled : bool = false

var hud_upgrade_reset_delay : int = 0

@onready var hit_audio := $HitAudio as AudioStreamPlayer3D
@onready var death_timer := $DeathTimer as Timer
@onready var blood_splatter := $Mesh/GPUParticles3D as GPUParticles3D
var splat_ready : bool = true

@onready var collision := $CollisionShape3D as CollisionShape3D
@onready var roll_audio := $RollAudio as AudioStreamPlayer3D
@onready var cam_boom := $CameraBoom as Node3D
@onready var mesh := $Mesh as MeshInstance3D

@onready var aim_audio := $AimAudio as AudioStreamPlayer3D

# Sword vars
@onready var sword_audio := $SwordAudio as AudioStreamPlayer3D
var sword

# Sword animation vars
@onready var swing_timer := $SwingTimer as Timer
@onready var return_swing_timer := $ReturnSwingTimer as Timer

var ranged : bool = false
var aiming : bool = false
@onready var aiming_beam := $CameraBoom/ProjectilePath as MeshInstance3D
@onready var projectile_spawn := $CameraBoom/ProjectileSpawn as Marker3D
@onready var arrow_label := $HUD/HotBar/Control2/ArrowsLabel as Label

var attacking : bool = false
var lunging : bool = false
var sword_dir : int = 1
var sword_rot : float

var melee_stamina_use : int = 5
var weapon_movement_speed_mult : float = 1.0

@onready var health_bar := $HUD/HealthBar as ProgressBar
@onready var stamina_bar := $HUD/StaminaBar as ProgressBar
@onready var exhausting_alert := $HUD/StaminaBar/Exhausted as Label

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var global_vars : Object = get_node("/root/global")

func _ready():
	create_melee()

func create_melee():
	
	arrow_label.text = "Arrows: " + str(global_vars.arrows)
	# Tää luo uuden miekan pelaajalle, autoloaderissa otetaan uus miekka.
	if sword: sword.queue_free()
	ranged = false

	attack_disabled = false
	var current_melee = load(global_vars.current_melee).instantiate()
	mesh.call_deferred("add_child", current_melee)
	sword = current_melee
	sword_rot = sword.rotation.y
	if global_vars.current_melee.contains("ranged"):
		ranged = true
	
	# Tähän voi laittaa uusia audioita, esim hammer ääni
	if "Sword" in str(sword): 
		sword_audio.stream = load("res://Audio/sword_miss.ogg")
	if "Hammer" in str(sword):
		sword_audio.stream = load("res://Audio/hammer_miss.ogg")
	if "Weaponless" in str(sword):
		attack_disabled = true
	if "Bow" in str(sword):
		sword_audio.stream = load("res://Audio/bow_fire.wav")
	
	var player_weapon = global_vars.current_melee
	var stamina_dict = global_vars.melee_stamina_dict
	var speed_dict = global_vars.melee_speed_dict
	# Tutkii autoloaderin damage dictistä, että kuinka paljon pelaajan ase tekee lämää
	for dicts in stamina_dict:
		if str(dicts) in str(player_weapon):
			melee_stamina_use = stamina_dict[dicts]
	for dicts in speed_dict:
		if str(dicts) in str(player_weapon):
			weapon_movement_speed_mult = speed_dict[dicts]


func _input(event) -> void:
	if event.is_action_pressed("inventory") or event.is_action_pressed("change_hotbar") or (event.is_action_pressed("pause") and inventory_open):
		inventory_open = not inventory_open
	if inventory_open: return
	if event.is_action_pressed("attack") and not attacking and stamina >= melee_stamina_use and not attack_disabled and not ranged:
		global_vars.player_attack = true
		sword_audio.play(0.3)
		stamina -= melee_stamina_use
		attacking = true
		lunging = true
		swing_timer.start()
		return_swing_timer.start()



	if event.is_action_pressed("aim") and ranged:
		aim_audio.play()
		aiming = true
		
		aiming_beam.show()
	if event.is_action_released("aim"):
		
		aiming = false
		aiming_beam.hide()
	if event.is_action_pressed("attack") and ranged and aiming and stamina >= melee_stamina_use and global_vars.arrows > 0:
		global_vars.arrows -= 1
		
		arrow_label.text = "Arrows: " + str(global_vars.arrows)
		aiming = false
		aiming_beam.hide()
		sword_audio.play()
		stamina -= melee_stamina_use
		var arrow = load("res://Objects/Player/arrow.tscn").instantiate()
		arrow.global_transform.origin = projectile_spawn.global_transform.origin
		arrow.rotation = cam_boom.rotation
		call_deferred("add_sibling", arrow)


	if event.is_action_pressed("lock_on"): ($HUD/LockOn as Control).show()
	if event.is_action_released("lock_on"): ($HUD/LockOn as Control).hide()
	if event.is_action_pressed("run"):
		running = true
	if event.is_action_released("run"):
		running = false
	if event.is_action_pressed("roll") and not rolling and not roll_cooldown and is_on_floor() and stamina >= 10 and input_dir:
		collision.scale = Vector3(0.8, 0.8, 0.8)
		stamina -= 10
		rolling = true
		# Roll timer ajoittaa roll movementin. 
		if not ranged:
			sword.damage_areas = false
		($RollTimer as Timer).start()
		roll_audio.play()


func attack() -> void:
	const ATTACK_SPEED = PI/10
	if attacking: sword.rotation.y += ATTACK_SPEED * sword_dir

func speed_governor() -> float:
	var speed : float = SPEED_DICT["walk"]
	if lunging: return SPEED_DICT["attack"] * weapon_movement_speed_mult
	if (not running or run_cooldown or not is_on_floor()) and stamina < 100: stamina += 0.15
	if rolling and not running: 
		return SPEED_DICT["roll"] * weapon_movement_speed_mult
	if run_cooldown: return speed * weapon_movement_speed_mult
	if running and is_on_floor():
		if stamina >= 1:
			speed = SPEED_DICT["run"]
			stamina -= 0.1
		else:
			running = false
			run_cooldown = true
			($RunTimer as Timer).start()
	return speed * weapon_movement_speed_mult


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
	
	if global_vars.is_inv_visible or global_vars.is_hotbar_visible:
		inventory_open = true
	else: inventory_open = false
	# HUD upgrade. Sitä käytetään aseiden vaihossa invissä ja inventoryn päivittämiseen.
	if global_vars.hud_update:
		create_melee()
		hud_upgrade_reset_delay += 1
		if hud_upgrade_reset_delay >= 3:
			global_vars.hud_update = false
			hud_upgrade_reset_delay = 0
	
	global_vars.player_position = global_transform.origin
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
	
	# Jos esim vedät health pot
	health += global_vars.change_of_health
	global_vars.change_of_health = 0
	stamina += global_vars.change_of_stamina
	if global_vars.change_of_stamina: run_cooldown = false
	global_vars.change_of_stamina = 0
	
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
		velocity.x -= sin(target_rotation.y) * speed * delta
		velocity.z -= cos(target_rotation.y) * speed * delta
		mesh.rotation.y = target_rotation.y
		y_change = 1

	if input_dir.y > 0: # Back
		velocity.x += sin(target_rotation.y) * speed * delta
		velocity.z += cos(target_rotation.y) * speed * delta
		mesh.rotation.y = target_rotation.y - PI
		y_change = -1
		
	
	var normalize : float = 1
	if y_change != 0: normalize = 0.5
	if input_dir.x < 0: # Left
		velocity.x += sin(target_rotation.y - PI/2) * speed * normalize * delta
		velocity.z += cos(target_rotation.y - PI/2) * speed * normalize * delta
		if y_change == 1:
			mesh.rotation.y = target_rotation.y + PI/4
		elif y_change == -1:
			mesh.rotation.y = target_rotation.y + PI/2 + PI/4
		else: 
			mesh.rotation.y = target_rotation.y + PI/2

	if input_dir.x > 0: # Right
		
		velocity.x += sin(target_rotation.y + PI/2) * speed * normalize * delta
		velocity.z += cos(target_rotation.y + PI/2) * speed * normalize * delta
		mesh.rotation.y = target_rotation.y - PI/2
		if y_change == 1:
			mesh.rotation.y = target_rotation.y - PI/4
		elif y_change == -1:
			mesh.rotation.y = target_rotation.y - PI/2 - PI/4
		else: 
			mesh.rotation.y = target_rotation.y - PI/2
	if ranged and aiming:
		stamina -= 0.25
		mesh.global_rotation.y = cam_boom.global_rotation.y
		if stamina < melee_stamina_use:
			aiming = false
			aiming_beam.hide()
	move_and_slide()


func _on_roll_timer_timeout() -> void:
	if rolling:
		collision.scale = Vector3(1, 1, 1)
		if not ranged:
			sword.damage_areas = true
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
	
	if area.is_in_group("HealthPotion"): global_vars.inventory.append("res://Objects/consumables/health_potion")
	if area.is_in_group("StaminaPotion"): global_vars.inventory.append("res://Objects/consumables/stamina_potion")
	if area.is_in_group("LooseArrow"): 
		global_vars.arrows += 1
		arrow_label.text = "Arrows: " + str(global_vars.arrows)

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
