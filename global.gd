extends Node
# AUTOLOADER

var mouse_sensitivity : float = 0.01

# Tämän avulla viholliset ei ota lämää, jos pelaaja ei swingaa
var player_attack : bool = false

var player_position : Vector3 = Vector3.ZERO


# HUD upgrade. Sitä käytetään aseiden vaihossa invissä ja inventoryn päivittämiseen.
var hud_update : bool = false

# Jos esimerkiksi invetory haluaa muuttaa pelaajan HP:ta, niin tätä muttamaa
var change_of_health : int = 0
var change_of_stamina : int = 0


## INVENTORYSSÄ PATH SIIHEN SCENEEN 

## TÄSSÄ KAIKKI ITEMIT
#var inventory : Dictionary = {
	## ASEET
	#"res://Objects/weapons/stock_sword": 1, 
	#"res://Objects/weapons/war_hammer": 0, 
	#
	## CONSUMABLES
	#"res://Objects/consumables/health_potion": 1,
	#"res://Objects/consumables/stamina_potion": 1,
#}

var inventory : Array = [
	"res://Objects/weapons/stock_sword", 
	"res://Objects/weapons/war_hammer", 
	"res://Objects/consumables/health_potion", 
	"res://Objects/consumables/stamina_potion"
]

## HOTBAR MUISTI
var hotbar1 : String = "res://Objects/weapons/stock_sword"
var hotbar2 : String = ""
var hotbar3 : String = "res://Objects/consumables/health_potion"
var hotbar4 : String = "res://Objects/consumables/stamina_potion"

var current_melee = "res://Objects/weapons/weaponless.tscn"
var current_ranged = "res://Objects/weapons/weaponless.tscn"

# ASEIDEN STATSIT, OHJE: NIMI LAINAUSMERKEISSA, STAT JÄLKEEN "war_hammer": 5 
const melee_damage_dict : Dictionary = {"weaponless": 0, "stock_sword": 1, "war_hammer": 3}
const melee_stamina_dict : Dictionary = {"weaponless": 0, "stock_sword": 5, "war_hammer": 15}
const melee_speed_dict : Dictionary = {"weaponless": 1.0, "stock_sword": 1.0, "war_hammer": 0.7}
