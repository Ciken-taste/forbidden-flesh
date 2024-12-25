extends Node3D

var mouse_sensitivity : float = 0.01
var saved_zoom : Vector3 = Vector3(2, 2, 2)
const ZOOM_SENSITIVITY : Vector3 = Vector3(0.1, 0.1, 0.1)
@onready var cam_collision := $Camera3D/RayCast3D as RayCast3D
var zoom_frozen : bool = false
var locked_on_enemy = null

var locking_on : bool = false

var inventory_open : bool = false

@onready var lock_ray := $Camera3D/EnemyLockOnRay as RayCast3D

@onready var global_vars : Object = get_node("/root/global")

# Process estää seinien läpi katsomisen, ei toimi kovin hyvin...
func _process(_delta) -> void:
	if global_vars.is_inv_visible or global_vars.is_hotbar_visible:
		inventory_open = true
	else: inventory_open = false
	mouse_sensitivity = global_vars.mouse_sensitivity
	if lock_ray.is_colliding() and locking_on: 
		locked_on_enemy = lock_ray.get_collider()
	if is_instance_valid(locked_on_enemy): 
		look_at(locked_on_enemy.position)
	elif locked_on_enemy != null:
		locked_on_enemy = null
		locking_on = false
	
	if not cam_collision.is_colliding() and not zoom_frozen:
		if scale.x < saved_zoom.x:
			scale += ZOOM_SENSITIVITY
		if scale.x > saved_zoom.x:
			scale -= ZOOM_SENSITIVITY
		
	cam_collision.scale.y = 2 * scale.x + 1
	if cam_collision.is_colliding() and scale.x > 0.3: 
		scale -= ZOOM_SENSITIVITY
		zoom_frozen = true
		($Camera3D/RayCast3D/ZoomFreezeTimer as Timer).start()

func _input(event) -> void:
	if event.is_action_pressed("inventory") or event.is_action_pressed("change_hotbar") or (event.is_action_pressed("pause") and inventory_open):
		inventory_open = not inventory_open
	if inventory_open: return
	if event.is_action_pressed("lock_on"):
		if locked_on_enemy != null:
			($LockOnTimer as Timer).start()
			locking_on = false
		else:
			locking_on = true
		locked_on_enemy = null
	if event.is_action_released("lock_on"):
		($LockOnTimer as Timer).stop()
		locking_on = false
	
	# Ohjaa kameran liikettä
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation.x, -PI/3, PI/2)
	
	# Manual zoom, ei käytössä!
	#if event is InputEventMouseButton:
		#if event.is_pressed():
			#if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and not zoom_frozen:
				#saved_zoom += ZOOM_SENSITIVITY
			#if event.button_index == MOUSE_BUTTON_WHEEL_UP and scale.x > 0.3:
				#saved_zoom -= ZOOM_SENSITIVITY
				#
			#saved_zoom = Vector3(clamp(saved_zoom.x, 0.3, 2), clamp(saved_zoom.y, 0.3, 2), clamp(saved_zoom.z, 0.3, 2))
			#scale = saved_zoom


func _on_zoom_freeze_timer_timeout() -> void:
	zoom_frozen = false


func _on_area_3d_area_entered(area) -> void:
	if area.is_in_group("1x"): saved_zoom = Vector3(1, 1, 1)
	elif area.is_in_group("2x"): saved_zoom = Vector3(2, 2, 2)
	elif area.is_in_group("3x"): saved_zoom = Vector3(3, 3, 3)
	elif area.is_in_group("4x"): saved_zoom = Vector3(4, 4, 4)
	elif area.is_in_group("5x"): saved_zoom = Vector3(5, 5, 5)


func _on_lock_on_timer_timeout():
	locking_on = true

func _on_player_inv_status(status: bool):
	inventory_open = status
