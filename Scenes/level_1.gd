extends Node3D

@onready var player := $Player as CharacterBody3D

@onready var p_spawn_pos := $PlayerSpawnPOS as Node3D

@onready var pause_menu := $PauseMenu as Control
var currently_paused : bool = false

@export var player_checkpoint = Vector3.ZERO


func _ready():
	player_checkpoint = p_spawn_pos.global_position

func _input(event) -> void:

	if event.is_action_pressed("respawn"):
		get_tree().call_group("KD", "death_confirmed")
		get_tree().call_group("player", "remove_player")
		var new_player = preload("res://Objects/Player/player.tscn").instantiate()
		new_player.global_position = player_checkpoint
		player = new_player
		call_deferred("add_child", new_player)
		remove_child($ScrollContainer)
		var inv = preload("res://Objects/Player/inventory_menu.tscn").instantiate()
		call_deferred("add_child", inv)
		remove_child($ChangeHotbar)
		inv = preload("res://Objects/Player/change_hotbar.tscn").instantiate()
		call_deferred("add_child", inv)


func _on_menu_fade_timer_timeout():
	if currently_paused and pause_menu.modulate.a < 1: pause_menu.modulate.a += 0.025
	elif not currently_paused and pause_menu.modulate.a > 0: pause_menu.modulate.a -= 0.025

func _on_pause_menu_toggle_pause():
	currently_paused = not currently_paused
	get_tree().paused = currently_paused
