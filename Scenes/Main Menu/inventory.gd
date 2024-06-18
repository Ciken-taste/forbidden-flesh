extends Control

@onready var global_vars : Object = get_node("/root/global")
@onready var items := $ColorRect2 as ColorRect

var inventory_open : bool = false

func _physics_process(_delta):
	if inventory_open and modulate.a < 1:
		modulate.a += 0.05
	if not inventory_open and modulate.a > 0:
		modulate.a -= 0.05

func _input(event):
	if event.is_action_pressed("inventory"):
		inventory_open = not inventory_open
		var inventory = global_vars.inventory
		var items_added : int = 0
		for children in items.get_children():
			children.queue_free()
		for dicts in inventory:
			if inventory[dicts] > 0:
				var item_tab = preload("res://Scenes/Main Menu/inventory_item.tscn").instantiate()
				item_tab.path = str(dicts)
				item_tab.item_count = inventory[dicts]
				item_tab.position.y = 0.2 * get_viewport_rect().size.y * items_added
				items.call_deferred("add_child", item_tab)
				items_added += 1
