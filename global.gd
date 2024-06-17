extends Node
# AUTOLOADER

var mouse_sensitivity : float = 0.01

# Tämän avulla viholliset ei ota lämää, jos pelaaja ei lyö
var player_attack : bool = false

var player_position : Vector3 = Vector3.ZERO


var current_melee = "res://Objects/weapons/war_hammer.tscn"
var current_ranged = "res://Objects/weapons/weaponless.tscn"

const melee_damage_dict : Dictionary = {"weaponless": 0, "stock_sword": 1, "war_hammer": 4}
const melee_stamina_dict : Dictionary = {"weaponless": 0, "stock_sword": 5, "war_hammer": 20}
const melee_speed_dict : Dictionary = {"weaponless": 1.0, "stock_sword": 1.0, "war_hammer": 0.7}
