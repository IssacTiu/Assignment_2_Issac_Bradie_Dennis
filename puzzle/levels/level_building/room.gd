class_name Room
extends Node

@export var level_start: bool
@onready var dimensions = $RoomWalls.mesh.size

func _ready() -> void:
	if level_start: NavigationManager.current_room = self

func _show() -> void:
	self.visible = true

func _hide() -> void:
	self.visible = false

func get_position() -> Vector3:
	return self.global_transform.origin
