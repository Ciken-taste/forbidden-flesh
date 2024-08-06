extends Node3D

var speed = 25
@onready var collision_ray := $RayCast3D as RayCast3D
@onready var damage_area := $Area3D as Area3D

func _physics_process(delta):
	position.x -= speed * sin(rotation.y) * delta
	position.z -= speed * cos(rotation.y) * delta
	position.y += speed * sin(rotation.x) * delta
	if collision_ray.is_colliding():
		speed = 0
		damage_area.monitorable = false
	if not collision_ray.is_colliding() and speed == 0:
		position.y -= 0.5


func _on_timer_timeout():
	queue_free()
