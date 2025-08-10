extends StaticBody3D

@onready var particles := $GPUParticles3D as GPUParticles3D
@onready var particles2 := $GPUParticles3D2 as GPUParticles3D

@onready var player_spawn := $PlayerSpawn as Node3D
@onready var audio := $AudioStreamPlayer3D as AudioStreamPlayer3D
@onready var light := $OmniLight3D as OmniLight3D

func _on_area_3d_area_entered(area):
	if area.is_in_group("Player"): 
		if not particles.emitting:
			audio.play()
			get_parent().player_checkpoint = player_spawn.global_position
			particles.emitting = true
			particles2.emitting = true
			light.show()


func _on_audio_stream_player_3d_finished():
	audio.play(5)
