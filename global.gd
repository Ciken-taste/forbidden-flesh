extends Node
# AUTOLOADER

var mouse_sensitivity : float = 0.01
var music_volume : int = 50

# Tämän avulla viholliset ei ota lämää, jos pelaaja ei swingaa
var player_attack : bool = false

var player_position : Vector3 = Vector3.ZERO


# HUD upgrade. Sitä käytetään aseiden vaihossa invissä ja inventoryn päivittämiseen.
var hud_update : bool = false

var is_inv_visible : bool = false
var is_hotbar_visible : bool = false

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
	"res://Objects/weapons/ranged/stock_bow",
	"res://Objects/weapons/war_hammer", 
	"res://Objects/consumables/health_potion", 
	"res://Objects/consumables/stamina_potion",
	"res://Objects/weapons/gear_of_running"
	
]

## HOTBAR MUISTI
var hotbar1 : String = "res://Objects/weapons/stock_sword"
var hotbar2 : String = "res://Objects/weapons/ranged/stock_bow"
var hotbar3 : String = "res://Objects/consumables/health_potion"
var hotbar4 : String = "res://Objects/consumables/stamina_potion"

var current_melee = "res://Objects/weapons/stock_sword.tscn"
var arrows : int = 50


# ASEIDEN STATSIT, OHJE: NIMI LAINAUSMERKEISSA, STAT JÄLKEEN "war_hammer": 5 
const melee_damage_dict : Dictionary = {
	"weaponless": 0, 
	"stock_sword": 1, 
	"war_hammer": 3, 
	"gear_of_running": 0, 
	"stock_bow": 1
}

const melee_stamina_dict : Dictionary = {
	"weaponless": 0,
	"stock_sword": 5, 
	"war_hammer": 15, 
	"gear_of_running": 0, 
	"stock_bow": 5
}

const melee_speed_dict : Dictionary = {
	"weaponless": 1.0, 
	"stock_sword": 1.0,
	"war_hammer": 0.7, 
	"gear_of_running": 4.5, 
	"stock_bow": 1.0
}
