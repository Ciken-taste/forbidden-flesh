extends Control

@onready var global_vars : Object = get_node("/root/global")

@onready var settings_menu := $Settings/SettingsMenu as Control
@onready var master_volume_slider := $Settings/SettingsMenu/MasterAudio as HSlider
@onready var mouse_sensitivity_slider := $Settings/SettingsMenu/MouseSensitivity as HSlider


@onready var controls_menu := $Controls/ControlMenu as Control



signal toggle_pause

var currently_paused : bool = false

func pause_handler():
	currently_paused = not currently_paused
	if currently_paused: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("toggle_pause")

func _input(event):
		if event.is_action_pressed("pause"):
			if not settings_menu.visible and not controls_menu.visible:
				pause_handler()
			else:
				settings_menu.hide()
				controls_menu.hide()

func _on_quit_pressed():
	get_tree().quit()

func _on_settings_pressed():
	settings_menu.show()

func _on_back_settings_pressed():
	settings_menu.hide()


func _on_controls_pressed():
	controls_menu.show()

func _on_back_controls_pressed():
	controls_menu.hide()


func _on_start_pressed():
	pause_handler()


func _on_master_audio_drag_ended(value_changed):
	if not value_changed: return
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume_slider.value)
	if master_volume_slider.value == master_volume_slider.min_value:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -1000)



func _on_mouse_sensitivity_drag_ended(value_changed):
	if not value_changed: return
	global_vars.mouse_sensitivity = mouse_sensitivity_slider.value
	
