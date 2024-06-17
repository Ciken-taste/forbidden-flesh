extends Node3D

@export var damage_areas : bool = true
@onready var actual_area := $DamageArea as Area3D

func _physics_process(_delta):
	if damage_areas:
		if not actual_area.monitorable:
			actual_area.monitorable = true
	elif actual_area.monitorable:
		actual_area.monitorable = false
	
