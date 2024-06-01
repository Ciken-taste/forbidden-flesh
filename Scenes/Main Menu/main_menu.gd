extends Control

func _on_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://Scenes/Demo/demo_level.tscn")
