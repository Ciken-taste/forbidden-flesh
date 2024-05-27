extends Node3D

var mouse_sensitivity : float = -0.01
const ZOOM_SENSITIVITY : Vector3 = Vector3(0.1, 0.1, 0.1)
@onready var cam_collision := $Camera3D/RayCast3D as RayCast3D

var zoom_frozen : bool = false

# Process estää seinien läpi katsomisen, ei toimi kovin hyvin...
func _process(_delta) -> void:
	cam_collision.scale.y = 2 * scale.x + 1
	if cam_collision.is_colliding() and scale.x > 0.3: 
		scale -= ZOOM_SENSITIVITY
		zoom_frozen = true
		($Camera3D/RayCast3D/ZoomFreezeTimer as Timer).start()

func _input(event) -> void:
	# Ohjaa kameran liikettä
	if event is InputEventMouseMotion:
		rotation.y += event.relative.x * mouse_sensitivity
		rotation.x += event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation.x, -PI/3, PI/2)
	
	# Zoom
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and not zoom_frozen:
				scale += ZOOM_SENSITIVITY
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and scale.x > 0.3:
				scale -= ZOOM_SENSITIVITY
			var clamped_zoom = clamp(scale.x, 0.3, 2)
			scale = Vector3(clamped_zoom, clamped_zoom, clamped_zoom)


func _on_zoom_freeze_timer_timeout():
	zoom_frozen = false
