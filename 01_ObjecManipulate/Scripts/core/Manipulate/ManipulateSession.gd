extends Spatial


export var manipulateMaxDistance = 80
export var enableMouseInput = true #for debug use

var SessionEnable = true
var rayOrigin:Vector3
var rayEnd:Vector3
var currentManipulateObj = null
var isHandlePressing = false

#region Godot Callback 
func _input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		InputEventProcess(event.position)
	elif enableMouseInput and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		InputEventProcess(event.position)
		
func InputEventProcess(inputPos):
	var currentCamera = get_viewport().get_camera()
	var spaceSatae = get_world().direct_space_state
	rayOrigin = currentCamera.project_ray_origin(inputPos)
	rayEnd = rayOrigin + currentCamera.project_ray_normal(inputPos) * manipulateMaxDistance
	var intersection = spaceSatae.intersect_ray(rayOrigin, rayEnd, [], 0x7FFFFFFF, true, true)
	if not intersection.empty() :
		#Step 1: try get if it is IntersectionObj
		var intersectionObjRoot = TryGetIntersectionObjRoot(intersection.collider)
		if(intersectionObjRoot != null):
			if(currentManipulateObj != null and currentManipulateObj != intersectionObjRoot):
				currentManipulateObj.OnManipulateEnd()
			currentManipulateObj = intersectionObjRoot
			intersectionObjRoot.OnManipulateStart()
			return
			
		#Step 2: try get if it is IntersectionHandle
		var intersectionHandleRoot = TryGetIntersectionHandleRoot(intersection.collider)
		if(intersectionHandleRoot != null):
			currentManipulateObj.OnManipulateHandlePressedCallback(intersectionHandleRoot.handleInfo)
			return

#endregion


#region Internal Method
func HandleManipulationStarted():
	pass
	
func HandleManipulationEnded():
	pass
	
func TryGetIntersectionObjRoot(collider):
	if(collider.get_parent().has_meta("ManipulateableObject")):
		return collider.get_parent()
	if(collider.get_parent().get_parent().has_meta("ManipulateableObject")):
		return collider.get_parent().get_parent()
	return null
func TryGetIntersectionHandleRoot(collider):
	if(collider.get_parent().has_meta("ManipulateableHandle")):
		return collider.get_parent()
	if(collider.get_parent().get_parent().has_meta("ManipulateableHandle")):
		return collider.get_parent().get_parent()
	return null
#endregion
