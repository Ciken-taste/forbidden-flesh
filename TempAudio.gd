extends AudioStreamPlayer

@export var audio : String

func _ready():
	stream = load(audio)
	play()

func _on_finished():
	queue_free()
