extends Button

@export var path_name : String

@onready var global_vars : Object = get_node("/root/global")

func _ready():
	icon = load(path_name + ".png")
	var text_str = path_name.replace("res://Objects/weapons/", "")
	text_str = text_str.replace("res://Objects/consumables/", "")
	text_str = text_str.replace("_", " ")
	text = text_str

func remove_from_inventory(item : String):
	var pos : int = 0
	for x in global_vars.inventory:
		if x.contains(item):
			global_vars.inventory.pop_at(pos)
			break
		pos += 1



func _on_pressed():
	if path_name.contains("res://Objects/weapons/"):
		## EI TOIMI RANGED ASEIDEN KANSSA
		global_vars.current_melee = path_name + ".tscn"
		global_vars.hud_update = true
	if path_name.contains("res://Objects/consumables/"):
		if path_name.contains("health_potion"):
			remove_from_inventory("health_potion")
			global_vars.hud_update = true
			global_vars.change_of_health = 25
			
		if path_name.contains("stamina_potion"):
			remove_from_inventory("stamina_potion")
			global_vars.hud_update = true
			global_vars.change_of_stamina = 45
