extends Control


@export var path : String
@export var item_count : int 

@onready var sprite := $Sprite2D as Sprite2D
@onready var label := $Label as Label

var regex = RegEx.new()

func _ready():
	regex.compile("^.*?/")
	sprite.texture = load(path + ".png")
	sprite.scale = 0.0002 * get_viewport_rect().size
	# Käsittelee pathin item nameksi
	var item_name = path
	while true:
		var string_to_remove = regex.search(item_name)
		if not string_to_remove: break
		string_to_remove = string_to_remove.get_string()
		item_name = item_name.replace(string_to_remove, "")
	item_name = item_name.replace("_", " ")
	
	label.text = item_name + ": " + str(item_count) + "x"
