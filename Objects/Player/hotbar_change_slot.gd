extends Button

@export var path_name : String

@onready var global_vars : Object = get_node("/root/global")

func _ready():
	if ResourceLoader.exists(path_name + ".png"):
		icon = load(path_name + ".png")
	var text_str = path_name.replace("res://Objects/weapons/", "")
	text_str = text_str.replace("res://Objects/consumables/", "")
	text_str = text_str.replace("ranged/", "")
	text_str = text_str.replace("_", " ")
	text = text_str


func _on_pressed():
	if path_name.contains("res://Objects/weapons/ranged"):
		if global_vars.hotbar2 == "change":
			global_vars.hotbar2 = path_name
	elif path_name.contains("res://Objects/weapons/"):
		## EI TOIMI RANGED ASEIDEN KANSSA
		if global_vars.hotbar1 == "change":
			global_vars.hotbar1 = path_name
	if path_name.contains("res://Objects/consumables/"):
		if global_vars.hotbar3 == "change":
			global_vars.hotbar3 = path_name
		if global_vars.hotbar4 == "change":
			global_vars.hotbar4 = path_name
