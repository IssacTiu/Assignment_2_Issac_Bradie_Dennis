extends Node3D

@export var rotate_delay = 0.1
@export var position_delay = 5.0
@export var setup_zoom = 8.0
var setup_transform3d := Transform3D()
@onready var target = Node3D.new()

func _ready() -> void:
	target.rotation.x = deg_to_rad(-45)
	target.rotation.y = deg_to_rad(45)
	_set_camera(0, 0, 1.5, setup_zoom)
	setup_transform3d = Transform3D(target.basis, target.position)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("rotate_left"):
		target.rotate_y(deg_to_rad(-90))
	if Input.is_action_just_pressed("rotate_right"):
		target.rotate_y(deg_to_rad(90))
	_rotate_camera()
	_move_camera(delta)
	_zoom_camera(delta)

func _set_camera(x: float, y: float, height: float, size: float):
	target.position.x = x
	target.position.z = y
	target.position.y = height
	%Pivot/ZoomPoint.position.z = size

func _rotate_camera() -> void:
	var toTargetRotation = target.rotation - %Pivot.rotation
	if toTargetRotation != Vector3.ZERO:
		var q  = Quaternion(%Pivot.transform.basis)
		var tq = Quaternion(target.basis)
		%Pivot.transform.basis = Basis(q.slerp(tq, rotate_delay))
	else:
		target.rotation = %Pivot.rotation

func _move_camera(delta: float) -> void:
	var toTargetPosition = target.position - %Pivot.position
	if toTargetPosition != Vector3.ZERO:
		%Pivot.position = %Pivot.position.lerp(target.position, position_delay * delta)
	else:
		target.position = %Pivot.position

func _zoom_camera(delta: float) -> void:
	var toTargetZoom = %Pivot/ZoomPoint.position - %Pivot/Camera3D.position
	if toTargetZoom != Vector3.ZERO:
		%Pivot/Camera3D.position = %Pivot/Camera3D.position.lerp(%Pivot/ZoomPoint.position, position_delay * delta)
		%Pivot/Camera3D.size = lerp(%Pivot/Camera3D.size, %Pivot/ZoomPoint.position.z, position_delay * delta)
	else:
		%Pivot/ZoomPoint.position = %Pivot/Camera3D.position

func set_target(t: Transform3D) -> void:
	target.basis = t.basis
	target.position = t.origin
