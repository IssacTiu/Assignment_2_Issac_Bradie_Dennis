extends Node3D

#Coordinates for the next room
@export var next_room: Vector2

#Coordinates of the door's room
var current_position: Vector2

var click_range = Vector2.ZERO		#Area that can be clicked
@onready var facing_normal = global_position.direction_to($FacingNormal.global_position)

var facing: bool
var locked: bool
var disable: bool

signal moved(x, y)

func _ready() -> void:
	click_range = $Pivot/ClickArea.size/2
	current_position.x = self.get_parent_node_3d().position.x
	current_position.y = self.get_parent_node_3d().position.z


func _physics_process(delta: float) -> void:
	if disable:
		$Pivot/ClickArea.mouse_default_cursor_shape = 0
	else:
		$Pivot/ClickArea.mouse_default_cursor_shape = 2
	facing = facing_normal.dot(get_viewport().get_camera_3d().project_ray_normal($Pivot.global_position)) > 0
	if not facing:
		$Pivot.global_position = get_viewport().get_camera_3d().unproject_position(global_position)
		$Pivot/ClickArea.size.y = 131
	else:
		$Pivot.global_position = get_viewport().get_camera_3d().unproject_position($HiddenPosition.global_position)
		$Pivot/ClickArea.size.y = 65
	$Pivot/ClickArea.position = -$Pivot/ClickArea.size/2
	click_range = $Pivot/ClickArea.size/2


func _input(event: InputEvent) -> void:
	if not disable:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed() and abs(event.position - $Pivot.position).x < click_range.x and abs(event.position - $Pivot.position).y < click_range.y:
				if not locked:
					moved.emit(next_room.x, next_room.y)


func unlock() -> void:
	locked = false
