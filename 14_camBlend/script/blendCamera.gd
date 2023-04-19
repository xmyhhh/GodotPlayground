extends Camera

var blendCameraController
var startTrans
var memoryTargetVirCamTrans    #记忆虚拟相机是为了防止在blend的过程中 虚拟相机被销毁了

var offsetQuat = null
var offsetPos = null
var fovSet = null
var vCamTrans = null

func moveToVirtualCamera(time : float) :
	if(time==0.0):
		startTrans = global_transform
		
	var end_transform
	if(is_instance_valid(blendCameraController.targetVirCamNode)):
		end_transform = blendCameraController.targetVirCamNode.global_transform.looking_at(blendCameraController.targetVirCamNode.GetTargetOrigin(), Vector3.UP)
	else:
		end_transform = blendCameraController.targetVirCamNode.global_transform.looking_at(memoryTargetVirCamTrans.origin, Vector3.UP)
	 
	var currentOrigin : Vector3
	currentOrigin = blendCameraController.path.interpolate_baked(blendCameraController.path.get_baked_length() * time, true)
	var currentRotation := Quat(global_transform.basis.orthonormalized()).slerp(end_transform.basis, time)

	if(offsetQuat != null):
		global_transform = Transform(Basis(currentRotation), offsetPos + currentOrigin)
		offsetQuat = null
		offsetPos = null
	else:
		global_transform = Transform(currentRotation, currentOrigin)

	if(fovSet !=null):
		fov = lerp(fov, fovSet, 0.1)

func moveToPlayerCamera(time : float) :
	var currentOrigin : Vector3
	currentOrigin = blendCameraController.path.interpolate_baked(blendCameraController.path.get_baked_length() * time, true)
	var target_transform : Transform
#	target_transform = global_transform.looking_at(NavigatorTool.globalCameraRig.global_transform.origin, Vector3.UP)
	target_transform = blendCameraController.savedBlendCamEndTrans
	var currentRotation := Quat(global_transform.basis.orthonormalized()).slerp(target_transform.basis, time)
	
	if(offsetQuat != null):
		global_transform = Transform(Basis(offsetQuat * currentRotation), offsetPos + currentOrigin)
		offsetQuat = null
		offsetPos = null
	else:
		global_transform = Transform(currentRotation, currentOrigin)


func DoUpdate():
	if(vCamTrans != null):
		global_transform = vCamTrans
	if(fovSet !=null):
		fov = lerp(fov, fovSet, 0.1)
