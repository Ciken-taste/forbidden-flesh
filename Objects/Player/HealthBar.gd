extends ProgressBar

@onready var health_change := $HealthChangedBar as ProgressBar

func _physics_process(_delta):
	if value < health_change.value: health_change.value -= 0.25
	if value > health_change.value: health_change.value += 0.25
