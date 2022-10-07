extends Spatial

onready var editorRoot =  get_tree().get_root().find_node("EditorRoot", true, false)

var manipulateSessionConfig = {
	"ground":{
		"enable": true,
		"nodeName": "Ground"
	},
	"manipulateMaxDistance": 80
}

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
	rayEnd = rayOrigin + currentCamera.project_ray_normal(inputPos) * manipulateSessionConfig["manipulateMaxDistance"]
	var intersection = spaceSatae.intersect_ray(rayOrigin, rayEnd, [], 0x7FFFFFFF, true, true)
	if not intersection.empty() :
		#Step 1: try get if it is IntersectionObj
		var intersectionObjRoot = TryGetIntersectionObjRoot(intersection.collider)
		if(intersectionObjRoot != null):
			var manipulateObjRoot = Spatial.new()
			manipulateObjRoot.set_script(editorRoot.ManipulateableObjectScript)
			manipulateObjRoot.manipulateSessionNode = self
			intersectionObjRoot.get_parent().add_child(manipulateObjRoot)
			manipulateObjRoot.transform = intersectionObjRoot.transform 
			intersectionObjRoot.get_parent().remove_child(intersectionObjRoot)
			manipulateObjRoot.add_child(intersectionObjRoot)
			intersectionObjRoot.transform.origin = Vector3(0, 0, 0)
			intersectionObjRoot.transform.basis = Basis.IDENTITY
			
			if(currentManipulateObj != intersectionObjRoot):
				EndManipulation()

			currentManipulateObj = manipulateObjRoot
			currentManipulateObj.OnManipulateStart()
			return

		#Step 2: try get if it is IntersectionHandle
		var intersectionHandleRoot = TryGetIntersectionHandleRoot(intersection.collider)
		if(intersectionHandleRoot != null):
			currentManipulateObj.OnManipulateHandlePressedCallback(intersectionHandleRoot.handleInfo)
			return

		#Step 3: EndManipulation
		EndManipulation()


func OtherEventProcess(event):
	if(currentManipulateObj != null):
		currentManipulateObj.InputHandle(event)


func EndManipulation():
	if(currentManipulateObj!=null):
		currentManipulateObj.OnManipulateEnd()
		var objNode = currentManipulateObj.get_child(0)
		currentManipulateObj.remove_child(objNode)
		currentManipulateObj.get_parent().add_child(objNode)
		objNode.transform = currentManipulateObj.transform
		currentManipulateObj.queue_free()
		currentManipulateObj = null

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
