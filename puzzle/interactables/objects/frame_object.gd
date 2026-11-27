extends InteractableObject

func trigger_event() -> void:
	Camera.move_to_transform(get_cam_target())
	print("Frame event triggered")
