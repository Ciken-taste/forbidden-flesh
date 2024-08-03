extends Area3D

var spawning : bool = false
var mod : int = 0

@onready var marker := ($Marker3D as Marker3D)

func _physics_process(_delta):
	if not spawning: return
	mod += 1
	if mod == 10:
		mod = 0
		var stamina_potion : Object = preload("res://Objects/consumables/stamina_potion.tscn").instantiate()
		stamina_potion.position = marker.position
		call_deferred("add_child", stamina_potion)

func _on_area_entered(_area):
	spawning = true


func _on_area_exited(_area):
	spawning = false
