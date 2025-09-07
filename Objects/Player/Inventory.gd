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
		var displayed_items : Array
		for x in inventory.size():
			
			var displayed : bool = false
			for z in displayed_items.size():
				if inventory[x] == displayed_items[z]:
					displayed = true
			if not displayed:
				displayed_items.append(inventory[x])
				var count : int = 1
				for y in inventory.size():
					if inventory[x] == inventory[y] and x != y:
						count += 1
				var inv_slot = preload("res://Objects/Player/inventory_slot.tscn").instantiate()
				inv_slot.path_name = inventory[x]
				inv_slot.count = count
				vbox.call_deferred("add_child", inv_slot)
