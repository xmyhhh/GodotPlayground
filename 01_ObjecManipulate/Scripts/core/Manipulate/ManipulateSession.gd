extends Spatial


export var manipulateMaxDistance = 40


var SessionEnable = true
var rayOrigin:Vector3
var rayEnd:Vector3
var currentManipulateObj = null
var isHandlePressing = false

#region Godot Callback 
func _input(event):
	if isInputPress(event):
		PressEventProcess(event.position)
	else:
		OtherEventProcess(event)
#endregion


#region Internal Method
func PressEventProcess(inputPos):
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
			else:
				HandleManipulationStarted()
			currentManipulateObj = intersectionObjRoot
			intersectionObjRoot.OnManipulateStart()
			return
			
		#Step 2: try get if it is IntersectionHandle
		var intersectionHandleRoot = TryGetIntersectionHandleRoot(intersection.collider)
		if(intersectionHandleRoot != null):
			currentManipulateObj.OnManipulateHandlePressedCallback(intersectionHandleRoot.handleInfo)
			return
			
		#Step 3: EndManipulation
		currentManipulateObj.OnManipulateEnd()
		HandleManipulationEnded()
		intersectionObjRoot == null
func OtherEventProcess(event):
	if(currentManipulateObj != null):
		currentManipulateObj.InputHandle(event)

func HandleManipulationStarted():
	print("HandleManipulationStarted")
	pass
	
func HandleManipulationEnded():
	print("HandleManipulationEnded")
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


#region tool Scrpt
func isInputPress(event):
	var isScreenPressed = event is InputEventScreenTouch and event.is_pressed()
	var isMouseClicked =  event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed
	return isScreenPressed or isMouseClicked
#endregion
