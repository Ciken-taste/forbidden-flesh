extends Area3D



func _on_area_entered(area):
	if area.is_in_group("Player"):
		var enemy = preload("res://Objects/DemoEnemy/demo_enemy.tscn").instantiate()
		enemy.global_position = ($Marker3D as Marker3D).global_position
		add_child(enemy)
