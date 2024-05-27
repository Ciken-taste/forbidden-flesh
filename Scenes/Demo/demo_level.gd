extends Node3D

@onready var player := $Player as CharacterBody3D

func _physics_process(_delta):
	get_tree().call_group("enemies", "seek_player", player.global_transform.origin)
