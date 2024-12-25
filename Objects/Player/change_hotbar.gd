extends ScrollContainer

@onready var global_vars : Object = get_node("/root/global")
@onready var vbox := ($VBoxContainer2 as VBoxContainer)
var inv_open : bool = false


func _physics_process(_delta):
	global_vars.is_hotbar_visible = visible

func _input(event):
	if event.is_action_pressed("change_hotbar") or (event.is_action_pressed("pause") and inv_open):
		inv_open = not inv_open
		toggle_inventory()
	if event.is_action("hotbar1") and inv_open:
		global_vars.hotbar1 = "change"
	if event.is_action("hotbar2") and inv_open:
		global_vars.hotbar2 = "change"
	if event.is_action("hotbar3") and inv_open:
		global_vars.hotbar3 = "change"
	if event.is_action("hotbar4") and inv_open:
		global_vars.hotbar4 = "change"

func toggle_inventory():
	if not inv_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		hide()
		var children = vbox.get_children()
		for x in children:
			x.queue_free()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		show()
		var inventory : Array = global_vars.inventory
		for x in inventory.size():
			var inv_slot = preload("res://Objects/Player/hotbar_change_slot.tscn").instantiate()
			inv_slot.path_name = inventory[x]
			vbox.call_deferred("add_child", inv_slot)
