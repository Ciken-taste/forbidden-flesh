extends Control

func _on_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://Scenes/Demo/demo_level.tscn")

@onready var controls_menu := $Controls/ControlMenu as Control
@onready var settings_menu := $Settings/SettingsMenu as Control

func _on_controls_pressed():
	controls_menu.show()

func _on_settings_pressed():
	settings_menu.show()

func _on_quit_pressed():
	get_tree().quit()

func _on_back_controls_pressed():
	controls_menu.hide()

func _on_back_settings_pressed():
	settings_menu.hide()
