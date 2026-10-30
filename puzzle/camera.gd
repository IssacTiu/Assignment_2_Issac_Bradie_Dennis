extends Node3D

@export var delay = 1

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("move_left"):
		#$Pivot.rotation.y = lerp_angle($Pivot.rotation_degrees.y, left, delay)
		$Pivot.rotate(Vector3.UP, deg_to_rad(90))
	if Input.is_action_just_pressed("move_right"):
		#$Pivot.rotation.y = lerp_angle($Pivot.rotation_degrees.y, right, delay)
		$Pivot.rotate(Vector3.UP, deg_to_rad(-90))
