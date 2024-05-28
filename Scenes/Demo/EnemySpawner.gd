extends Area3D

var spawning : bool = false
var cooldown : bool = false

func _physics_process(_delta):
	if not spawning or cooldown: return
	($SpawnTimer as Timer).start()
	cooldown = true
	var enemy = preload("res://Objects/DemoEnemy/demo_enemy.tscn").instantiate()
	var random_pos : Vector3 = Vector3(randi_range(-10, 10), 0, randi_range(-10, 10))
	enemy.global_position = ($Marker3D as Marker3D).global_position + random_pos
	add_child(enemy)


func _on_area_entered(area):
	if area.is_in_group("Player"): spawning = true
		

func _on_area_exited(area):
	if area.is_in_group("Player"): spawning = false


func _on_spawn_timer_timeout():
	cooldown = false
