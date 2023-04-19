extends Node
enum CamType{PLAYER_CAM = 0, BLEND_CAM = 1}
export var DynamicBlend = true

onready var tweenNode = get_node("Tween")


var blendCameraPrefabPath = "res://14_camBlend/prefab/blendCamera.tscn"
var currentCamType = CamType.PLAYER_CAM
var playerCam = null
var blendCam = null
var isBlending = false

var targetVirCamNode = null

var targetCameraPosition  #目标相机的位置
var targetObjectPosition  #目标位置
var targetCameraTransform 


var blendInitialGlobalTransform

var duration
var transType
var easeType


var isBlendToPlayerCam = false
var isBlendToVirtualCam = false
var isAtVirtualCam = false
var savedBlendCamEndTrans = null

func _ready():
	tweenNode.connect("tween_all_completed", self , "tweenFinishCallback")

func _physics_process(delta):
	if(DynamicBlend):
		#Setp 1:check if target VCam move or playerCam move
		if(savedBlendCamEndTrans == null):
			return
			
		#Step 2:in blending move, when player cam trans change
		if(isBlendToPlayerCam and not savedBlendCamEndTrans.is_equal_approx(playerCam.global_transform)):
			blendCam.offsetQuat =  Quat(playerCam.global_transform.basis) * (Quat(savedBlendCamEndTrans.basis).inverse())
			blendCam.offsetPos = playerCam.global_transform.origin - savedBlendCamEndTrans.origin
			return
			
		#Step 3:in blending move, when virtual cam target trans change
		if(isBlendToVirtualCam and not savedBlendCamEndTrans.is_equal_approx(targetVirCamNode.global_transform)):
			blendCam.offsetQuat =  Quat(targetVirCamNode.global_transform.basis) * (Quat(savedBlendCamEndTrans.basis).inverse())
			blendCam.offsetPos = targetVirCamNode.global_transform.origin - savedBlendCamEndTrans.origin
			blendCam.fovSet = targetVirCamNode.fov
			return
			
		#Step 4:off blending move, when virtual cam target trans change
		if(isAtVirtualCam and not savedBlendCamEndTrans.is_equal_approx(targetVirCamNode.global_transform)):
			blendCam.vCamTrans = targetVirCamNode.global_transform
			blendCam.fovSet = targetVirCamNode.fov
			blendCam.DoUpdate()
			
			return
		
#region Public Method
func BlendToVirtualCam(_targetVirCam, _duration = 2.5 , _transType = 1, _easeType = 2, delay = 0.0):
	if(not _targetVirCam.has_meta("virtualCamera")):
		push_warning("BlendToVirtualCam funtion call error: targetVirCam must be virtualCamera")
		return
	tweenNode.remove_all()
	
	isBlendToVirtualCam = true
	isBlendToPlayerCam = false
	isAtVirtualCam = false
	if(targetVirCamNode != null):
		targetVirCamNode.activate = false
	
	targetVirCamNode = _targetVirCam
	targetVirCamNode.activate = true

	duration = _duration
	easeType = _easeType
	transType = _transType
	
	if(currentCamType == CamType.PLAYER_CAM):
		playerCam = get_viewport().get_camera()
		blendCam = load(blendCameraPrefabPath).instance()
		add_child(blendCam)
		blendCam.global_transform = playerCam.global_transform
		blendCam.environment = playerCam.environment
		blendCam.fov = playerCam.fov

		blendCam.far = playerCam.far
		blendCam.near = playerCam.near
		blendCam.h_offset = playerCam.h_offset
		blendCam.v_offset = playerCam.v_offset
		blendCam.cull_mask = playerCam.cull_mask
		blendCam.size = playerCam.size
		blendCam.blendCameraController = self
		blendCam.memoryTargetVirCamTrans = targetVirCamNode.global_transform
		
		blendInitialGlobalTransform = playerCam.global_transform
		currentCamType = CamType.BLEND_CAM
	else:
		blendInitialGlobalTransform = blendCam.global_transform
		
	savedBlendCamEndTrans = targetVirCamNode.global_transform
	
	targetCameraPosition = targetVirCamNode.global_transform.origin
	targetObjectPosition = targetVirCamNode.GetTargetOrigin()
	
	targetCameraTransform = targetVirCamNode.global_transform  

	
	tweenNode.interpolate_method(blendCam, "moveToVirtualCamera", 0.0, 1.0,
							  duration, transType, easeType, delay)
	# set by default physics, allowing regular animation
	tweenNode.set_tween_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	BuildPathToVirtualCam()
	yield(get_tree(),"idle_frame")
	blendCam.current = true
	tweenNode.start()
	

func BlendToPlayerCam(_duration = 2.5 , _transType = 1, _easeType = 2, delay = 0.0):
	
	if(currentCamType == CamType.PLAYER_CAM):
		return
	
	tweenNode.remove_all()
	
	duration = _duration
	easeType = _easeType
	transType = _transType
	
	isBlendToVirtualCam = false
	isBlendToPlayerCam = true
	isAtVirtualCam = false
	
	savedBlendCamEndTrans = playerCam.global_transform
	blendInitialGlobalTransform = blendCam.global_transform
	tweenNode.interpolate_method(blendCam, "moveToPlayerCamera", 0.0, 1.0,
							  duration, transType, easeType, delay)
	# set by default physics, allowing regular animation
	tweenNode.set_tween_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	BuildPathToPlayerCam()
	tweenNode.start()
#endregion




func tweenFinishCallback():
	if(isBlendToPlayerCam):
		yield(get_tree(),"idle_frame")
		playerCam.current = true
		currentCamType = CamType.PLAYER_CAM
	
	if(isBlendToVirtualCam):
		isAtVirtualCam = true
		
	isBlendToVirtualCam = false
	isBlendToPlayerCam = false

var path
export var bezier_control_point_strength := 0.6 #default give round circle approximation
func BuildPathToVirtualCam():
	if path == null :
		path = Curve3D.new()
		path.up_vector_enabled = false
	else :
		path.clear_points()

	path.bake_interval = 0.1

	var straightDirection = (targetCameraTransform.origin -blendInitialGlobalTransform.origin)  
	var initialCameraDirection = -blendInitialGlobalTransform.basis.z.normalized()
	var traightLengths = straightDirection.length()  
	var finalCameraDirection = (targetObjectPosition - targetCameraTransform.origin).normalized()

	path.add_point(blendInitialGlobalTransform.origin, 
					-initialCameraDirection * traightLengths * bezier_control_point_strength / 2, 
					initialCameraDirection * traightLengths * bezier_control_point_strength / 2)
					
	path.add_point(targetCameraTransform.origin, 
					-finalCameraDirection * traightLengths * bezier_control_point_strength / 2, 
					finalCameraDirection * traightLengths * bezier_control_point_strength / 2)
					
func BuildPathToPlayerCam():
	path.clear_points()
	var straightDirection = (playerCam.global_transform.origin -blendInitialGlobalTransform.origin)  
	var initialCameraDirection = -blendInitialGlobalTransform.basis.z.normalized()
	var traightLengths = straightDirection.length()  
#	var finalCameraDirection = (-playerCam.global_transform.basis.z).normalized()
	var p = playerCam.get_node(playerCam.target)
	var finalCameraDirection = (p.global_transform.origin - playerCam.global_transform.origin).normalized()
	path.bake_interval = 0.1
	path.add_point(blendInitialGlobalTransform.origin, 
					-initialCameraDirection * traightLengths * bezier_control_point_strength / 2, 
					initialCameraDirection * traightLengths * bezier_control_point_strength / 2)
					
	path.add_point(playerCam.global_transform.origin, 
					-finalCameraDirection * traightLengths * bezier_control_point_strength / 2, 
					finalCameraDirection * traightLengths * bezier_control_point_strength / 2)

