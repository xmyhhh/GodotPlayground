extends Spatial


export var manipulateMaxDistance = 200
export var enableMouseInput = true #for debug use

var SessionEnable = true
var rayOrigin:Vector3
var rayEnd:Vector3

	

#region Godot Callback 
func _ready():
	pass
	
func _input(event):
	if event is InputEventScreenTouch and not event.is_pressed():
		InputEventProcess(event.position)
	elif enableMouseInput and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		InputEventProcess(event.position)
		
func InputEventProcess(inputPos):
	var currentCamera = get_viewport().get_camera()
	var spaceSatae = get_world().direct_space_state
	rayOrigin = currentCamera.project_ray_origin(inputPos)
	rayEnd = rayOrigin + currentCamera.project_ray_normal(inputPos) * manipulateMaxDistance
	var intersection = spaceSatae.intersect_ray(rayOrigin, rayEnd)
	if not intersection.empty():
		pass
	
func _physics_process(delta):
	pass
#endregion
