extends Node3D

enum State { FOLLOW, MOVING_TO_LOCK, LOCKED, RETURNING }

@export var rotate_delay = 0.1
@export var position_delay = 4.0
@export var setup_zoom = 9.0
@export_range(0.1, 10.0) var return_speed := 1.5 #How fast the return plays relative to the original trip (1.0 = mirrored timing)

var state: State = State.FOLLOW
var lock_transform := Transform3D()
var travel_start := Transform3D()

var zoom_height: float
var saved_target_position: Vector3
var saved_target_basis: Basis
var saved_zoom_height: float

@onready var target = Node3D.new()

func _ready() -> void:
	target.rotation.x = deg_to_rad(-45)
	target.rotation.y = deg_to_rad(45)
	_set_camera(0, 0, 0.5, setup_zoom)

func _physics_process(delta: float) -> void:
	match state:
		State.FOLLOW:
			_handle_input()
			_rotate_camera()
			_move_camera(delta)
			_zoom_camera(delta)
		State.MOVING_TO_LOCK:
			%Camera3D.global_transform = %Camera3D.global_transform.interpolate_with(lock_transform, position_delay * delta)
			if _transforms_are_close(%Camera3D.global_transform, lock_transform):
				%Camera3D.global_transform = lock_transform
				state = State.LOCKED
		State.LOCKED:
			if Input.is_action_just_pressed("escape"):
				state = State.RETURNING
		State.RETURNING:
			%Camera3D.global_transform = %Camera3D.global_transform.interpolate_with(travel_start, position_delay * delta * return_speed)
			if _transforms_are_close(%Camera3D.global_transform, travel_start):
				_end_return()

func move_to_transform(transform: Transform3D) -> void:
	if state != State.FOLLOW:
		return
	saved_target_position = target.position
	saved_target_basis = target.basis
	saved_zoom_height = zoom_height
	travel_start = %Camera3D.global_transform
	lock_transform = transform
	state = State.MOVING_TO_LOCK

func is_following() -> bool:
	return state == State.FOLLOW

func _transforms_are_close(a: Transform3D, b: Transform3D) -> bool:
	return a.origin.distance_to(b.origin) < 0.01 \
		and Quaternion(a.basis).angle_to(Quaternion(b.basis)) < deg_to_rad(0.5)

func _end_return() -> void:
	%Camera3D.transform = Transform3D(Basis(), %ZoomPoint.position)
	target.position = saved_target_position
	target.basis = saved_target_basis
	zoom_height = saved_zoom_height
	_update_fov()
	state = State.FOLLOW

func _update_fov() -> void:
	var d : float = %Camera3D.global_position.distance_to(%Pivot.global_position)
	if d > 0.001:
		%Camera3D.fov = rad_to_deg(2.0 * atan(zoom_height / (2.0 * d)))

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
	zoom_height = size
	%Camera3D.fov = rad_to_deg(2.0 * atan(size / (2.0 * size)))
	%Camera3D.projection = Camera3D.PROJECTION_PERSPECTIVE

func _rotate_camera() -> void:
	var to_target_rot = target.rotation - %Pivot.rotation
	if to_target_rot != Vector3.ZERO:
		var q  = Quaternion(%Pivot.transform.basis)
		var tq = Quaternion(target.basis)
		%Pivot.transform.basis = Basis(q.slerp(tq, rotate_delay))
	else:
		target.rotation = %Pivot.rotation

func _move_camera(delta: float) -> void:
	var to_target_pos = target.position - %Pivot.position
	if to_target_pos != Vector3.ZERO:
		%Pivot.position = %Pivot.position.lerp(target.position, position_delay * delta)
	else:
		target.position = %Pivot.position

func _zoom_camera(delta: float) -> void:
	zoom_height = lerpf(zoom_height, %ZoomPoint.position.z, position_delay * delta) #Eases towards ZoomPoint
	%Camera3D.position = %Camera3D.position.lerp(%ZoomPoint.position, position_delay * delta)
	_update_fov()
