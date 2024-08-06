extends RigidBody3D


func _on_timer_timeout():
	queue_free()


func _on_area_3d_area_entered(area):
	if area.is_in_group("Player"): queue_free()


func _on_timer_2_timeout():
	gravity_scale = 0
	$CollisionShape3D.disabled = true
