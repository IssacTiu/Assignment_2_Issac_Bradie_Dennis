extends Node3D

@export var rotate_delay = 0.1
@export var position_delay = 5.0
@export var zoom = 8.0
@onready var target = Node3D.new()

func _ready() -> void:
	target.rotation.x = deg_to_rad(-45)
	target.rotation.y = deg_to_rad(45)
	_set_camera(0, 0, zoom)

func _physics_process(delta: float) -> void:
	
	#Camera Controls
	if Input.is_action_just_pressed("rotate_left"):
		target.rotate_y(deg_to_rad(-90))
	if Input.is_action_just_pressed("rotate_right"):
		target.rotate_y(deg_to_rad(90))
		
	if Input.is_action_just_pressed("move_up"):
		target.position.x -= 10
	if Input.is_action_just_pressed("move_down"):
		target.position.x += 10
		
	if Input.is_action_just_pressed("zoom_in"):
		$Pivot/ZoomPoint.position.z += 4
		print($Pivot/ZoomPoint.position.z)
	if Input.is_action_just_pressed("zoom_out"):
		$Pivot/ZoomPoint.position.z -= 4
		print($Pivot/ZoomPoint.position.z)
	
	_rotate_camera()
	_move_camera(delta)
	_zoom_camera(delta)
	
func _set_camera(x: float, y: float, size: float):
	target.position.x = x
	target.position.z = y
	$Pivot/ZoomPoint.position.z = size

#Interpolates camera rotation
func _rotate_camera() -> void:
	#Camera Rotation Interpolation
	var toTargetRotation = target.rotation - $Pivot.rotation
	if toTargetRotation != Vector3.ZERO:
		var q  = Quaternion($Pivot.transform.basis)
		var tq = Quaternion(target.basis)
		# Interpolate using spherical-linear interpolation (SLERP).
		$Pivot.transform.basis = Basis(q.slerp(tq, rotate_delay))
	else:
		target.rotation = $Pivot.rotation

#Interpolates camera position
func _move_camera(delta: float) -> void:
	#Camera Position Interpolation
	var toTargetPosition = target.position - $Pivot.position
	if toTargetPosition != Vector3.ZERO:
		$Pivot.position = $Pivot.position.lerp(target.position, position_delay * delta)
	else:
		target.position = $Pivot.position

#Interpolates camera zoom
func _zoom_camera(delta: float) -> void:
	var toTargetZoom = $Pivot/ZoomPoint.position - $Pivot/Camera3D.position
	if toTargetZoom != Vector3.ZERO:
		$Pivot/Camera3D.position = $Pivot/Camera3D.position.lerp($Pivot/ZoomPoint.position, position_delay * delta)
		$Pivot/Camera3D.size = lerp($Pivot/Camera3D.size, $Pivot/ZoomPoint.position.z, position_delay * delta)
	else:
		$Pivot/ZoomPoint.position = $Pivot/Camera3D.position
