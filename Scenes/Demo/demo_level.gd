extends Node3D

@onready var player := $Player as CharacterBody3D

func _physics_process(_delta):
	get_tree().call_group("enemies", "seek_player", player.global_transform.origin)

func _input(event):
	if event.is_action_pressed("respawn"):
		get_tree().call_group("KD", "death_confirmed")
		get_tree().call_group("player", "remove_player")
		var new_player = preload("res://Objects/Player/player.tscn").instantiate()
		new_player.position.y = 5
		player = new_player
		add_child(new_player)
