extends Node
# AUTOLOADER

var mouse_sensitivity : float = 0.01

# Tämän avulla viholliset ei ota lämää, jos pelaaja ei lyö
var player_attack : bool = false

var player_position : Vector3 = Vector3.ZERO

# INVENTORYSSÄ PATH SIIHEN SCENEEN, .tscn POIS JA res:// POIS. NUMERO PATHIN JÄLKEEN ON KUINKA MONTA PELAAJALLA ON
var inventory : Dictionary = {
	# ASEET
	"Objects/weapons/stock_sword": 1, 
	"Objects/weapons/war_hammer": 0, 
	
	# CONSUMABLES
	"Objects/consumables/health_potion": 1,
	"Objects/consumables/stamina_potion": 1,
}


var current_melee = "Objects/weapons/war_hammer.tscn"
var current_ranged = "Objects/weapons/weaponless.tscn"

# ASEIDEN STATSIT, OHJE: NIMI LAINAUSMERKEISSA, STAT JÄLKEEN "war_hammer": 5 
const melee_damage_dict : Dictionary = {"weaponless": 0, "stock_sword": 1, "war_hammer": 3}
const melee_stamina_dict : Dictionary = {"weaponless": 0, "stock_sword": 5, "war_hammer": 15}
const melee_speed_dict : Dictionary = {"weaponless": 1.0, "stock_sword": 1.0, "war_hammer": 0.7}
