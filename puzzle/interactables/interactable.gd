extends Node3D

@export var current_position: Vector2
@export var enabled := false
@export var facing_required: bool
@export var object: InteractableObject
var facing: bool
@onready var facing_normal = position.direction_to($FacingNormal.global_position)

func _physics_process(_delta: float) -> void:
	$InputPivot.position = get_viewport().get_camera_3d().unproject_position(object.get_input_target())
	if facing_required:
		facing = facing_normal.dot(get_viewport().get_camera_3d().project_ray_normal($InputPivot.global_position)) < 0
	else:
		facing = true
	if facing and Camera.is_following():
		_show_click_area()
	else:
		_hide_click_area()

func _show_click_area() -> void:
	enabled = true
	$InputPivot/ClickArea.mouse_default_cursor_shape = 2
	$InputPivot/ClickArea.visible = true

func _hide_click_area() -> void:
	enabled = false
	$InputPivot/ClickArea.mouse_default_cursor_shape = 0
	$InputPivot/ClickArea.visible = false

#####Signals#####
func _on_click_area_pressed() -> void:
	#play sound
	object.trigger_event()
