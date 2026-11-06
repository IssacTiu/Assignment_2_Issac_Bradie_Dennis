extends Node

var current_room = Vector2.ZERO

@onready var rooms = {Vector2(0, 0): $Room1, Vector2(0, -8): $Room2}

func _ready() -> void:
	_enable_buttons()


func _on_door_moved(x: Variant, y: Variant) -> void:
	var h = rooms[Vector2(x,y)].position.y + (rooms[Vector2(x,y)].dimensions.y/2)
	print(h)
	$Camera._set_camera(x, y, h, 8)
	current_room = Vector2(x,y)
	_enable_buttons()

func _enable_buttons() -> void:
	for room in rooms.values():
		for children in room.get_children():
			if "disable" in children:
				if children.current_position == current_room:
					room._show()
					children.disable = false
				else:
					room._hide()
					children.disable = true
