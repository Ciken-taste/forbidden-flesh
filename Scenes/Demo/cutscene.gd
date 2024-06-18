extends Node3D

@export var cutscene_path : Curve3D

var activated : bool = false
@onready var camera := $Path3D/PathFollow3D/Camera3D as Camera3D
@onready var path_follow := $Path3D/PathFollow3D as PathFollow3D
@onready var path := $Path3D as Path3D

func _ready():
	path.curve = cutscene_path

func _physics_process(_delta) -> void:
	if not activated or path_follow.progress_ratio >= 0.9: 
		if camera.current: camera.current = false
		return
	path_follow.progress_ratio += 0.005


func _on_area_3d_area_entered(area) -> void:
	if area.is_in_group("Player") and not activated:
		activated = true
		camera.current = true
