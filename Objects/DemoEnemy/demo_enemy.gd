extends CharacterBody3D


@onready var nav := $NavigationAgent3D as NavigationAgent3D
@onready var sword := $Sword as Node3D

@export var able_to_lunge : bool = true

var boost_applied : bool = false
var lunging : bool = false
var swinging : bool = false
var attacking : bool = false

var speed : float = 2.0 + randf_range(0, 1.5)

var health : int = 10

var new_velocity : Vector3 = Vector3.ZERO

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
		var next_location = nav.get_next_path_position()
		if lunging and not boost_applied and able_to_lunge: 
			($LungeTimer as Timer).start()
			boost_applied = true
			new_velocity = (next_location - current_location).normalized() * speed * 15

		elif not lunging or not able_to_lunge:
			new_velocity = (next_location - current_location).normalized() * speed
			look_at(next_location)
			rotation.y += PI
		velocity = new_velocity
		move_and_slide()

func seek_player(target_location):
	nav.target_position = target_location  


func _on_area_3d_area_entered(area):
	if area.is_in_group("PlayerSword"): 
		health -= 1 + randi_range(0, 1)
		($MeshInstance3D/MeshInstance3D as MeshInstance3D).transparency = health * 0.1
		if health <= 0: 
			get_parent().get_tree().call_group("KD", "kill_confirmed")
			queue_free()


func _on_attack_area_area_entered(area):
	if area.is_in_group("Player"): 
		if able_to_lunge: lunging = true
		else:
			attacking = true
			swinging = true



func _on_lunge_timer_timeout():
	($LungeTimer as Timer).stop()
	boost_applied = false
	lunging = false
	attacking = true
	swinging = true
