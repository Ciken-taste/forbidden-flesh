extends CharacterBody3D


@onready var nav := $NavigationAgent3D as NavigationAgent3D
@onready var sword := $Sword as Node3D

var swinging : bool = false
var attacking : bool = false

const SPEED : float = 2.0

var health : int = 10

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
		var new_velocity = (next_location - current_location).normalized() * SPEED
		velocity = new_velocity
		look_at(next_location)
		rotation.y += PI
		move_and_slide()

func seek_player(target_location):
	nav.target_position = target_location  






func _on_area_3d_area_entered(area):
	if area.is_in_group("PlayerSword"): 
		health -= 1
		if health <= 0: queue_free()


func _on_attack_area_area_entered(area):
	if area.is_in_group("Player"): 
		attacking = true
		swinging = true
