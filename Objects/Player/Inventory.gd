extends ScrollContainer

@onready var global_vars : Object = get_node("/root/global")
@onready var vbox := ($VBoxContainer2 as VBoxContainer)
var inv_open : bool = false

func _physics_process(_delta):
	global_vars.is_inv_visible = visible
	if global_vars.hud_update:
		inv_open = not inv_open
		toggle_inventory(false)


func _input(event):
	if event.is_action_pressed("inventory") or (event.is_action_pressed("pause") and inv_open):
		inv_open = not inv_open
		toggle_inventory(true)


func toggle_inventory(is_visible):
	if not inv_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		hide()
		var children = vbox.get_children()
		for x in children:
			x.queue_free()
	else:
		if is_visible: 
			show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var inventory : Array = global_vars.inventory
		for x in inventory.size():
			var inv_slot = preload("res://Objects/Player/inventory_slot.tscn").instantiate()
			inv_slot.path_name = inventory[x]
			vbox.call_deferred("add_child", inv_slot)
