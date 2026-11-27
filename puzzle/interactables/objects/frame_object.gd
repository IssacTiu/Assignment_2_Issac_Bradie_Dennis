extends InteractableObject

func trigger_event() -> void:
	Camera.set_target(get_cam_target())
	print("Frame event triggered")
