extends Control

@onready var global_vars : Object = get_node("/root/global")

@onready var setting_button := $Settings as Button
@onready var controls_button := $Controls as Button
@onready var start_button := $Start as Button
@onready var quit_button := $Quit as Button

@onready var settings_menu := $Settings/SettingsMenu as Control
@onready var master_volume_slider := $Settings/SettingsMenu/MasterAudio as HSlider
@onready var mouse_sensitivity_slider := $Settings/SettingsMenu/MouseSensitivity as HSlider


@onready var controls_menu := $Controls/ControlMenu as Control



signal toggle_pause

var currently_paused : bool = false

func disable_buttons(is_disabled : bool) -> void:
	setting_button.disabled = is_disabled
	controls_button.disabled = is_disabled
	start_button.disabled = is_disabled
	quit_button.disabled = is_disabled

func pause_handler() -> void:
	disable_buttons(currently_paused)
	currently_paused = not currently_paused
	if currently_paused: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("toggle_pause")

func _input(event) -> void:
		if event.is_action_pressed("pause"):
			disable_buttons(false)
			if not settings_menu.visible and not controls_menu.visible:
				pause_handler()
			else:
				settings_menu.hide()
				controls_menu.hide()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	disable_buttons(true)
	settings_menu.show()

func _on_back_settings_pressed() -> void:
	disable_buttons(false)
	settings_menu.hide()


func _on_controls_pressed() -> void:
	disable_buttons(true)
	controls_menu.show()

func _on_back_controls_pressed() -> void:
	disable_buttons(false)
	controls_menu.hide()


func _on_start_pressed() -> void:
	pause_handler()


func _on_master_audio_drag_ended(value_changed) -> void:
	if not value_changed: return
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume_slider.value)
	if master_volume_slider.value == master_volume_slider.min_value:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -1000)



func _on_mouse_sensitivity_drag_ended(value_changed) -> void:
	if not value_changed: return
	global_vars.mouse_sensitivity = mouse_sensitivity_slider.value
	
