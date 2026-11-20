class_name InteractableObject
extends Node3D

func get_input_target() -> Vector3:
	return %InputTarget.global_position

func get_cam_target() -> Transform3D:
	return %CamTarget.global_transform
