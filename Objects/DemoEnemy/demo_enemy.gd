extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var home_pos : Vector3 = global_transform.origin

@onready var nav := $NavigationAgent3D as NavigationAgent3D
@onready var sword := $Sword as Node3D

@onready var lunge_timer := $LungeTimer as Timer
@onready var pacification_timer := $PacificationTimer as Timer

@export var able_to_lunge : bool = true

var boost_applied : bool = false
var lunging : bool = false
var swinging : bool = false
var attacking : bool = false

var pacified : bool = false

var speed : float = 2.0 + randf_range(0, 1.5)

var health : int = 10

var new_velocity : Vector3 = Vector3.ZERO

var player_pos : Vector3 = Vector3.ZERO

func _ready():
	if able_to_lunge: ($AttackArea/NormalArea as CollisionShape3D).queue_free()
	else: ($AttackArea/LungeArea as CollisionShape3D).queue_free()

func attack():
	if sword.rotation.y <= (80 * PI) / 180 and swinging: # 80 deg
		sword.rotation.y += PI/32
	else:
		swinging = false
		if sword.rotation.y >= -(80 * PI) / 180: sword.rotation.y -= PI/64
		else: attacking = false
		

func _physics_process(_delta):

	
	attack()
	
	if not attacking: 

		var current_location = global_transform.origin
		var next_location = null
		if not pacified: nav.target_position = player_pos
		else: nav.target_position = home_pos
		next_location = nav.get_next_path_position()
		if lunging and not boost_applied and able_to_lunge: 
			lunge_timer.start()
			boost_applied = true
			new_velocity = (next_location - current_location).normalized() * speed * 15
		elif not lunging or not able_to_lunge:
			new_velocity = (next_location - current_location).normalized() * speed
			look_at(next_location)
			rotation.y += PI
			rotation.z = 0
		velocity = new_velocity
		if pacified:
			look_at(player_pos)
			rotation.y += PI
		if not is_on_floor(): velocity.y -= gravity
		move_and_slide()

func seek_player(target_location):
	player_pos = target_location  


func _on_area_3d_area_entered(area):
	if area.is_in_group("PlayerSword"): 
		health -= 1 + randi_range(0, 1)
		($MeshInstance3D/MeshInstance3D as MeshInstance3D).transparency = health * 0.1
		
	elif area.is_in_group("InstaDeath"): health = 0
	if health <= 0: 
		get_parent().get_tree().call_group("KD", "kill_confirmed")
		queue_free()


func _on_attack_area_area_entered(area):
	if area.is_in_group("Player"): 
		if pacified:
			pacified = false
			nav.target_position = player_pos
		if able_to_lunge: lunging = true
		else:
			attacking = true
			swinging = true



func _on_lunge_timer_timeout():
	lunge_timer.stop()
	boost_applied = false
	lunging = false
	attacking = true
	swinging = true


func _on_pacification_timer_timeout():
	if randi_range(10 - health, 100) > 50: 
		pacified = true
		var time : int = 5
		time += 10 - health + randi_range(0, 5)
		pacification_timer.start(time)
	else: 
		pacified = false
		pacification_timer.start(15)
