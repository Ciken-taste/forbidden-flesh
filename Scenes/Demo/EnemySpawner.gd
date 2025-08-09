extends Area3D

var spawning : bool = false
var cooldown : bool = false

@onready var spawn_timer := $SpawnTimer as Timer
@onready var spawn_point := $Marker3D as Marker3D

func _physics_process(_delta) -> void:
	if not spawning or cooldown: return
	spawn_timer.start()
	cooldown = true
	var random_pos : Vector3 = Vector3(randi_range(-10, 10), 0, randi_range(-10, 10))
	var enemy = preload("res://Objects/DemoEnemy/demo_enemy.tscn").instantiate()
	call_deferred("add_sibling", enemy)
	enemy.global_transform.origin = spawn_point.global_transform.origin + random_pos

func _on_area_entered(area) -> void:
	if area.is_in_group("Player"): spawning = true
		

func _on_area_exited(area) -> void:
	if area.is_in_group("Player"): spawning = false


func _on_spawn_timer_timeout() -> void:
	cooldown = false
