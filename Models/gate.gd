extends StaticBody3D

@export var open : bool = false
@export var debug_open : bool = false
@export var disabled : bool = false
@onready var gate_bars := $Bars as StaticBody3D
@onready var label := $HUD/Label as Label

func _ready():
	if debug_open: gate_bars.position.y = 5

func _physics_process(_delta):
	if disabled: return
	open = get_parent().activated
	if open:
		if gate_bars.position.y < 5:
			gate_bars.position.y += 0.01
			if label.modulate.a < 1: label.modulate.a += 0.01
		else:
			if label.modulate.a > 0: label.modulate.a -= 0.01
	elif gate_bars.position.y > 0.7:
		gate_bars.position.y -= 0.01
