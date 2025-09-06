extends Area3D

@export var activated : bool = false



func _on_area_entered(area):
	if area.is_in_group("Player"): 
		activated = true
