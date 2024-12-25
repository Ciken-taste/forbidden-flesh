extends Control

@onready var global_vars : Object = get_node("/root/global")

@onready var setting_button := $Settings as Button
@onready var controls_button := $Controls as Button
@onready var start_button := $Start as Button
@onready var quit_button := $Quit as Button

func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -10)

func handle_buttons(is_disabled : bool) -> void:
	setting_button.disabled = is_disabled
	controls_button.disabled = is_disabled
	start_button.disabled = is_disabled
	quit_button.disabled = is_disabled

@onready var start_menu := $Start/StartMenu as Control

func _on_button_pressed() -> void:
	start_menu.show()
	handle_buttons(true)

@onready var controls_menu := $Controls/ControlMenu as Control


@onready var settings_menu := $Settings/SettingsMenu as Control
@onready var master_volume_slider := $Settings/SettingsMenu/MasterAudio as HSlider
@onready var mouse_sensitivity_slider := $Settings/SettingsMenu/MouseSensitivity as HSlider


func _on_controls_pressed():
	handle_buttons(true)
	controls_menu.show()

func _on_settings_pressed():
	handle_buttons(true)
	settings_menu.show()

func _on_quit_pressed():
	get_tree().quit()

func _on_back_controls_pressed():
	handle_buttons(false)
	controls_menu.hide()

func _on_back_settings_pressed():
	handle_buttons(false)
	settings_menu.hide()


func _on_master_audio_drag_ended(value_changed):
	if not value_changed: return
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume_slider.value)
	if master_volume_slider.value == master_volume_slider.min_value:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -1000)


func _on_mouse_sensitivity_drag_ended(value_changed):
	if not value_changed: return
	global_vars.mouse_sensitivity = mouse_sensitivity_slider.value
	


func _on_back_start_pressed():
	start_menu.hide()
	handle_buttons(false)


func _on_level_1_pressed():
	pass # Replace with function body.


func _on_dev_level_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://Scenes/Demo/demo_level.tscn")
