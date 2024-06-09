extends Node3D

@onready var player := $Player as CharacterBody3D

@onready var pause_menu := $PauseMenu as Control
var currently_paused : bool = false

func _input(event) -> void:

	if event.is_action_pressed("respawn"):
		get_tree().call_group("KD", "death_confirmed")
		get_tree().call_group("player", "remove_player")
		var new_player = preload("res://Objects/Player/player.tscn").instantiate()
		new_player.position.y = 5
		player = new_player
		add_child(new_player)



func _on_menu_fade_timer_timeout():
	if currently_paused and pause_menu.modulate.a < 1: pause_menu.modulate.a += 0.025
	elif not currently_paused and pause_menu.modulate.a > 0: pause_menu.modulate.a -= 0.025

func _on_pause_menu_toggle_pause():
	currently_paused = not currently_paused
	get_tree().paused = currently_paused
