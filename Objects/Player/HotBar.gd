extends Control

@onready var global_vars : Object = get_node("/root/global")

@onready var button1 := ($Control1/Button as Button)
@onready var button2 := ($Control2/Button as Button)
@onready var button3 := ($Control3/Button as Button)
@onready var button4 := ($Control4/Button as Button)


func _input(event):	
	if event.is_action_pressed("hotbar1") and global_vars.hotbar1.contains("res://Objects/weapons/"):
		global_vars.current_melee = global_vars.hotbar1 + ".tscn"
		global_vars.hud_update = true
	if event.is_action_pressed("hotbar2") and global_vars.hotbar2.contains("res://Objects/weapons/ranged/"):
		global_vars.current_melee = global_vars.hotbar2 + ".tscn"
		global_vars.hud_update = true
	
	
	
	# DONT PANIC, tää ohjaa vain consumbales slotteja
	if event.is_action_pressed("hotbar3") and global_vars.hotbar3.contains("res://Objects/consumables/"):
		var inv : Array = global_vars.inventory 
		for x in len(inv):
			if inv[x - 1] == global_vars.hotbar3:
				var temp_audio = preload("res://Audio/temp_audio.tscn").instantiate()
				temp_audio.audio = "res://Audio/Roblox Drinking Sound Effect.mp3"
				call_deferred("add_child", temp_audio)
				inv.pop_at(x - 1 )
				
				## TÄHÄN PERÄÄN JOS HALUAA UUSIA ITEMEJÄ HOTBARIIN
				if global_vars.hotbar3.contains("health_potion"):
					global_vars.change_of_health = 25
				if global_vars.hotbar3.contains("stamina_potion"):
					global_vars.change_of_stamina = 45
				break
	
	
	if event.is_action_pressed("hotbar4") and global_vars.hotbar4.contains("res://Objects/consumables/"):
		var inv : Array = global_vars.inventory 
		for x in len(inv):
			if inv[x - 1] == global_vars.hotbar4:
				var temp_audio = preload("res://Audio/temp_audio.tscn").instantiate()
				temp_audio.audio = "res://Audio/Roblox Drinking Sound Effect.mp3"
				call_deferred("add_child", temp_audio)
				inv.pop_at(x - 1 )
				if global_vars.hotbar4.contains("health_potion"):
					global_vars.change_of_health = 25
				if global_vars.hotbar4.contains("stamina_potion"):
					global_vars.change_of_stamina = 45
				break

# Tää päivittää iconit hotbaarissa.
func _on_timer_timeout():
	if global_vars.hotbar1.contains("res://Objects/weapons/"):
		if ResourceLoader.exists(global_vars.hotbar1 + ".png"):
			button1.icon = load(global_vars.hotbar1 + ".png")
		else:
			button1.icon = load("res://Textures/missing_texture.png")

	if global_vars.hotbar2.contains("res://Objects/weapons/ranged/"):
		if ResourceLoader.exists(global_vars.hotbar2 + ".png"):
			button2.icon = load(global_vars.hotbar2 + ".png")
		else:
			button2.icon = load("res://Textures/missing_texture.png")

	if global_vars.hotbar3.contains("res://Objects/consumables/"):
		if ResourceLoader.exists(global_vars.hotbar3 + ".png"):
			button3.icon = load(global_vars.hotbar3 + ".png")
		else:
			button3.icon = load("res://Textures/missing_texture.png")

	if global_vars.hotbar4.contains("res://Objects/consumables/"):
		if ResourceLoader.exists(global_vars.hotbar4 + ".png"):
			button4.icon = load(global_vars.hotbar4 + ".png")
		else:
			button4.icon = load("res://Textures/missing_texture.png")
