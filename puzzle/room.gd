extends Node

@onready var dimensions = $RoomWalls.mesh.size

func _show() -> void:
	self.visible = true
	
func _hide() -> void:
	self.visible = false
