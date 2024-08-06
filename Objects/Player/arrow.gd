extends Node3D

var speed = 40
@onready var collision_ray := $RayCast3D as RayCast3D
@onready var damage_area := $Area3D as Area3D
@onready var pickup_area := $PickUpArea as Area3D

func _physics_process(delta):
	rotation.x -= 0.01
	position.x -= speed * sin(rotation.y) * delta
	position.z -= speed * cos(rotation.y) * delta
	position.y += speed * sin(rotation.x) * delta
	if collision_ray.is_colliding():
		speed = 0
		damage_area.monitorable = false
		pickup_area.monitorable = true
		pickup_area.monitoring = true
	if not collision_ray.is_colliding() and speed == 0:
		var loose_arrow = load("res://Objects/Player/loose_arrow.tscn").instantiate()
		loose_arrow.global_position = global_position
		loose_arrow.rotation = rotation
		call_deferred("add_sibling", loose_arrow)
		queue_free()


func _on_timer_timeout():
	queue_free()


func _on_pick_up_area_area_entered(area):
	if area.is_in_group("Player"): queue_free()
