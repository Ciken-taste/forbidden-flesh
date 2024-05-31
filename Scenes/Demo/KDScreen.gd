extends MeshInstance3D

var kills : int = 0
var deaths : int = 0
@onready var kills_label := $Kills as Label3D
@onready var deaths_label := $Deaths as Label3D

func death_confirmed() -> void:
	deaths += 1
	deaths_label.text = str(deaths)

func kill_confirmed() -> void:
	kills += 1
	kills_label.text = str(kills)
