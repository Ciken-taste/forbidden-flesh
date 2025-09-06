extends RigidBody3D

func _ready() -> void:
	($GPUParticles3D as GPUParticles3D).emitting = true

func _physics_process(_delta) -> void:
	($SoftBody3D as SoftBody3D).position.y -= 0.015

func _on_gpu_particles_3d_finished() -> void:
	queue_free()
