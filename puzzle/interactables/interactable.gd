extends Node3D

#Pivots if the area can only be interacted if your facing towards it
@export var facing_required: bool
@export var current_position: Vector2
@export var enabled := false
var facing: bool
@onready var facing_normal = position.direction_to($FacingNormal.global_position)

func _physics_process(_delta: float) -> void:
	$Pivot.position = get_viewport().get_camera_3d().unproject_position(global_position)
	if facing_required:
		facing = facing_normal.dot(get_viewport().get_camera_3d().project_ray_normal($Pivot.global_position)) > 0
	else:
		facing = true
	if facing:
		_show_click_area()
	else:
		_hide_click_area()

func _show_click_area() -> void:
	enabled = true
	$Pivot/ClickArea.mouse_default_cursor_shape = 2
	$Pivot/ClickArea.visible = true

func _hide_click_area() -> void:
	enabled = false
	$Pivot/ClickArea.mouse_default_cursor_shape = 0
	$Pivot/ClickArea.visible = false

func interactable_event() -> void:
	print("interactable event trigger")

#####Signals#####
func _on_click_area_pressed() -> void:
	interactable_event()
