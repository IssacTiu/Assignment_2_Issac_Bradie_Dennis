extends Node3D

enum State { FOLLOW, MOVING_TO_LOCK, LOCKED, RETURNING }

@export var rotate_delay = 0.1
@export var position_delay = 4.0
@export var setup_zoom = 8.0

var setup_transform3d := Transform3D()
var state: State = State.FOLLOW
var lock_transform := Transform3D()

var saved_target_position: Vector3
var saved_target_basis: Basis
var saved_zoom: float

@onready var target = Node3D.new()

func _ready() -> void:
	target.rotation.x = deg_to_rad(-45)
	target.rotation.y = deg_to_rad(45)
	_set_camera(0, 0, 1.5, setup_zoom)
	setup_transform3d = Transform3D(target.basis, target.position)

func _physics_process(delta: float) -> void:
	match state:
		State.FOLLOW:
			_handle_input()
			_rotate_camera()
			_move_camera(delta)
			_zoom_camera(delta)
		State.MOVING_TO_LOCK:
			%Camera3D.set_perspective(100.0, 0.05, 4000.0)
			%Camera3D.global_transform = %Camera3D.global_transform.interpolate_with(lock_transform, position_delay * delta)
			if _transforms_are_close(%Camera3D.global_transform, lock_transform):
				%Camera3D.global_transform = lock_transform
				state = State.LOCKED
		State.LOCKED:
			if Input.is_action_just_pressed("escape"):
				release_camera()
		State.RETURNING: #Rig moves back to past location
			_rotate_camera()
			_move_camera(delta)
			_zoom_camera(delta)
			%Camera3D.set_orthogonal(8.0, 0.05, 4000.0)
			var rest := _rest_global_transform()
			%Camera3D.global_transform = %Camera3D.global_transform.interpolate_with(rest, position_delay * delta)
			if _transforms_are_close(%Camera3D.global_transform, rest) and _rig_is_settled():
				_end_return()

func move_to_transform(xform: Transform3D) -> void:
	if state != State.FOLLOW:
		return #Already busy
	saved_target_position = target.position
	saved_target_basis = target.basis
	saved_zoom = %ZoomPoint.position.z
	lock_transform = xform
	state = State.MOVING_TO_LOCK

func release_camera() -> void:
	if state != State.LOCKED:
		return
	target.position = saved_target_position
	target.basis = saved_target_basis
	%ZoomPoint.position.z = saved_zoom
	state = State.RETURNING

func _rest_global_transform() -> Transform3D: #Where cam should sit relative to rig
	return %Pivot.global_transform * Transform3D(Basis(), %ZoomPoint.position)

func _rig_is_settled() -> bool:
	return target.position.distance_to(%Pivot.position) < 0.01 \
		and Quaternion(%Pivot.basis).angle_to(Quaternion(target.basis)) < deg_to_rad(0.5)

func _transforms_are_close(a: Transform3D, b: Transform3D) -> bool:
	return a.origin.distance_to(b.origin) < 0.01 \
		and Quaternion(a.basis).angle_to(Quaternion(b.basis)) < deg_to_rad(0.5)

func _end_return() -> void: #Snap back to pivot, user input is valid again
	%Camera3D.transform = Transform3D(Basis(), %ZoomPoint.position)
	%Camera3D.size = %ZoomPoint.position.z
	target.rotation = %Pivot.rotation
	state = State.FOLLOW

func _handle_input() -> void:
	if Input.is_action_just_pressed("rotate_left"):
		target.rotate_y(deg_to_rad(-90))
	if Input.is_action_just_pressed("rotate_right"):
		target.rotate_y(deg_to_rad(90))

func _set_camera(x: float, y: float, height: float, size: float):
	target.position.x = x
	target.position.z = y
	target.position.y = height
	%ZoomPoint.position.z = size

func _rotate_camera() -> void:
	var to_target_rotation = target.rotation - %Pivot.rotation
	if to_target_rotation != Vector3.ZERO:
		var q  = Quaternion(%Pivot.transform.basis)
		var tq = Quaternion(target.basis)
		%Pivot.transform.basis = Basis(q.slerp(tq, rotate_delay))
	else:
		target.rotation = %Pivot.rotation

func _move_camera(delta: float) -> void:
	var to_target_position = target.position - %Pivot.position
	if to_target_position != Vector3.ZERO:
		%Pivot.position = %Pivot.position.lerp(target.position, position_delay * delta)
	else:
		target.position = %Pivot.position

func _zoom_camera(delta: float) -> void:
	var to_target_zoom = %ZoomPoint.position - %Camera3D.position
	if to_target_zoom != Vector3.ZERO:
		%Camera3D.position = %Camera3D.position.lerp(%ZoomPoint.position, position_delay * delta)
		%Camera3D.size = lerp(%Camera3D.size, %ZoomPoint.position.z, position_delay * delta)
	else:
		%ZoomPoint.position = %Camera3D.position
