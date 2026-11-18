extends Node3D

#Pivots if the area can only be interacted if your facing towards it
@export var facing_required: bool

#Coordinates of the door's room
@export var current_position: Vector2
@export var enabled := false

var click_range = Vector2.ZERO #Area that can be clicked
@onready var facing_normal = position.direction_to($FacingNormal.global_position)

var facing: bool

func _ready() -> void:
	click_range = $Pivot/ClickArea.size/2

func _physics_process(_delta: float) -> void:
	$Pivot.position = get_viewport().get_camera_3d().unproject_position(global_position)
	if facing_required:
		facing = facing_normal.dot(get_viewport().get_camera_3d().project_ray_normal($Pivot.global_position)) > 0
	else:
		facing = true
	if facing:
		_show()
	else:
		_hide()

func _input(event: InputEvent) -> void:
	if enabled:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if abs(event.position - $Pivot.position).x < click_range.x and abs(event.position - $Pivot.position).y < click_range.y:
				if facing: #FireInteractableCase: trigger the event here
					$Pivot/ClickArea.modulate = Color(1,0,0)
					#print("Interactable")
				else: #NotInteractableCase: trigger sound or text letting player know it didn't work
					$Pivot/ClickArea.modulate = Color(1,1,0)
					#print("NotInteractable")
		else: #RestDebugCase
			$Pivot/ClickArea.modulate = Color(0,1,0)

func _show() -> void:
	enabled = true
	$Pivot/ClickArea.mouse_default_cursor_shape = 2
	$Pivot/ClickArea.visible = true

func _hide() -> void:
	enabled = false
	$Pivot/ClickArea.mouse_default_cursor_shape = 0
	$Pivot/ClickArea.visible = false
