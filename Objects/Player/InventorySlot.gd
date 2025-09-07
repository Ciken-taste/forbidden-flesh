extends Button

@export var path_name : String
@export var count : int

@onready var global_vars : Object = get_node("/root/global")

func _ready():
	if ResourceLoader.exists(path_name + ".png"):
		icon = load(path_name + ".png")
	var text_str = path_name.replace("res://Objects/weapons/", "")
	text_str = text_str.replace("res://Objects/consumables/", "")
	text_str = text_str.replace("ranged/", "")
	text_str = text_str.replace("_", " ")
	if count > 1: text_str += " " + str(count) + "x"
	text = text_str 

func remove_from_inventory(item : String):
	var pos : int = 0
	for x in global_vars.inventory:
		if x.contains(item):
			global_vars.inventory.pop_at(pos)
			break
		pos += 1

func spawn_audio(audio_path : String):
	var audio_player = preload("res://Audio/temp_audio.tscn").instantiate()
	audio_player.audio = audio_path
	get_parent().get_parent().call_deferred("add_child", audio_player)




func _on_pressed():
	if path_name.contains("res://Objects/weapons/ranged"):
		spawn_audio("res://Audio/bow_equip.wav")

		global_vars.current_melee = path_name + ".tscn"
		global_vars.hud_update = true
	elif path_name.contains("res://Objects/weapons/"):
		spawn_audio("res://Audio/Sword Unsheathed Sound Effect - High Quality.mp3")

		global_vars.current_melee = path_name + ".tscn"
		global_vars.hud_update = true
	if path_name.contains("res://Objects/consumables/"):
		if path_name.contains("health_potion"):
			remove_from_inventory("health_potion")
			spawn_audio("res://Audio/Roblox Drinking Sound Effect.mp3")

			global_vars.hud_update = true
			global_vars.change_of_health = 25
			
		if path_name.contains("stamina_potion"):
			remove_from_inventory("stamina_potion")
			spawn_audio("res://Audio/Roblox Drinking Sound Effect.mp3")

			global_vars.hud_update = true
			global_vars.change_of_stamina = 45
