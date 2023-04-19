#ProtagonistCamera V0.1 2022.6.21
#Code By Xmy 
tool
extends Spatial

enum LerpMethod{Defalut}
enum LookAtTargetType{SpatialNode,Vector3Point}

enum CheckType{SetMode,SetSubMode,SetLookAtTargetType,SetLookAtSpatial,SetLookAtPoint,SetZenithAngelOffset,SetAzimuthAngelOffse,SetDistanceOffset,SetDistanceMax,SetDistanceMin,SetLerpSpeed}

#regin config Variable
var isLerp:bool = true setget SetLerp , GetLerp
var lerpSpeed:float = 0.3 setget SetLerpSpeed , GetLerpSpeed
 
var distanceMin:float = 15 setget SetDistanceMin , GetDistanceMin
var distanceMax:float = 100 setget SetDistanceMax , GetDistanceMax
var distanceOffset:float = 0.0 setget SetDistanceOffset ,GetDistanceOffset

var zenithAngelOffset:float = 0.3 setget SetZenithAngelOffset , GetZenithAngelOffset
var azimuthAngelOffset:float = 0.0001 setget SetAzimuthAngelOffset , GetAzimuthAngelOffse

var lookAtTargetType setget SetLookAtTargetType , GetLookAtTargetType
var lookAtSpatial:NodePath setget SetLookAtSpatial , GetLookAtSpatial
var lookAtPoint:Vector3 = Vector3(0,0,0) setget SetLookAtPoint , GetLookAtPoint

var isAutoSurround:bool = false
var autoSurroundSpeed:float = 0.1

#end Config Variable

#region Editor script
func _set(prop_name: String, val) -> bool:
	# Assume the property exists
	var retval: bool = true
	match prop_name: 
		"Protagonist/type":
			lookAtTargetType = val
		"Protagonist/Spatial":
			lookAtSpatial = val
		"Protagonist/Point":
			lookAtPoint = val
		"Lerp/enable":
			isLerp = val
		"Lerp/speed":
			lerpSpeed = val

		"Angel/zenithOffset":
			zenithAngelOffset = val
		"Angel/azimuthOffset":
			azimuthAngelOffset = val
		"Distance/Max":
			distanceMax = val
		"Distance/Min":
			distanceMin = val
		"Distance/offset":
			distanceOffset = val


		"AutoSurround/enable":
			isAutoSurround = val
		"AutoSurround/speed":
			autoSurroundSpeed = val
		_:
			retval = false
	 
	if(retval):
		property_list_changed_notify()
	return retval

func _get(prop_name: String):
	var retval = null
	match prop_name:
		"Protagonist/type":
			retval = lookAtTargetType 
		"Protagonist/Spatial":
			retval = lookAtSpatial
		"Protagonist/Point":
			retval = lookAtPoint
		"Lerp/enable":
			retval = isLerp
		"Lerp/speed":
			retval = lerpSpeed

		"Angel/zenithOffset":
			retval = zenithAngelOffset
		"Angel/azimuthOffset":
			retval = azimuthAngelOffset

		"Distance/Max":
			retval = distanceMax 
		"Distance/Min":
			retval = distanceMin
		"Distance/offset":
			retval = distanceOffset
		"AutoSurround/enable":
			retval = isAutoSurround
		"AutoSurround/speed":
			retval = autoSurroundSpeed
	return retval

func _get_property_list() -> Array:
	var ret: Array = []

	ret.append({
	"hint": PROPERTY_HINT_ENUM,
	"usage": PROPERTY_USAGE_DEFAULT,
	"name": "Protagonist/type",
	"type": TYPE_INT,
	"hint_string": PoolStringArray(LookAtTargetType.keys()).join(",")
	})

	if(lookAtTargetType==LookAtTargetType.SpatialNode):
		ret.append({
			"name": "Protagonist/Spatial", 
			"type": TYPE_NODE_PATH,
		})
	else:
		ret.append({
			"name": "Protagonist/Point", 
			"type": TYPE_VECTOR3,
		})

	ret.append({
		"name": "Lerp/enable", 
		"type": TYPE_BOOL,
	})
	ret.append({
		"name": "Lerp/speed",
		"type": TYPE_REAL,
		"hint": PROPERTY_HINT_EXP_RANGE,
		"hint_string":"0.01 , 1 , 0.01"
	})


	ret.append({
		"name": "Angel/zenithOffset",
		"type": TYPE_REAL,
		"hint": PROPERTY_HINT_EXP_RANGE,
		"hint_string":"0.001 , 1"
	})
	ret.append({
		"name": "Angel/azimuthOffset",
		"type": TYPE_REAL,
		"hint": PROPERTY_HINT_EXP_RANGE,
		"hint_string":"0.001 , 1"
	})


	ret.append({
		"name": "Distance/Max",
		"type": TYPE_REAL,
		"hint": PROPERTY_HINT_EXP_RANGE,
		"hint_string":str(distanceMin)+", 1000 , 0.01"
	})
	ret.append({
		"name": "Distance/Min",
		"type": TYPE_REAL,
		"hint": PROPERTY_HINT_EXP_RANGE,
		"hint_string":"0 , "+str(distanceMax)+" , 0.01"
	})
	ret.append({
		"name": "Distance/offset",
		"type": TYPE_REAL,
		"hint": PROPERTY_HINT_EXP_RANGE,
		"hint_string":"0 , 1 , 0.001"
	})

	ret.append({
		"name": "AutoSurround/enable", 
		"type": TYPE_BOOL,
	})
	if(isAutoSurround):
		ret.append({
			"name": "AutoSurround/speed", 
			"type": TYPE_REAL,
			"hint": PROPERTY_HINT_EXP_RANGE,
			"hint_string":"0.01 , 100 , 0.01"
		})

	return ret
#end Editor script

#region Godot callback
func _init():
	pass

func _physics_process(delta): 

	match lookAtTargetType:
		LookAtTargetType.Vector3Point:
			if lookAtPoint==null:
				return
		LookAtTargetType.SpatialNode:
			if lookAtSpatial==null or lookAtSpatial=='':
				return 

	if(isAutoSurround):
		azimuthAngelOffset += autoSurroundSpeed * delta
	var distance = float((distanceMax-distanceMin)*distanceOffset)+distanceMin 
	var zenithAngel = zenithAngelOffset*3.14 #(极角)
	var azimuthAngel = azimuthAngelOffset*2*3.14 #(方位角)
	
	var targetPosition

	if(lookAtTargetType==LookAtTargetType.SpatialNode):
		targetPosition=get_node(lookAtSpatial).transform.origin
	else:
		targetPosition=lookAtPoint
	
	var cameraPosition = Vector3(targetPosition.x+distance*sin(zenithAngel)*cos(azimuthAngel),
	targetPosition.y+distance*cos(zenithAngel),targetPosition.z+distance*sin(zenithAngel)*sin(azimuthAngel))

	if(isLerp):
		LookAtPositionLerp(cameraPosition,targetPosition)
	else:
		LookAtPosition(cameraPosition,targetPosition)
#end Godot callback

#region Setter
func SetLookAtTargetType(value:int):
	lookAtTargetType=value

func SetLookAtSpatial(traget:NodePath):
	if (not Check(traget,CheckType.SetLookAtSpatial)):
		return

	lookAtSpatial=traget

func SetLookAtPoint(traget:Vector3):
	if (not Check(traget,CheckType.SetLookAtPoint)):
		return
	lookAtPoint=traget

func SetZenithAngelOffset(value:float):
	if (not Check(value,CheckType.SetZenithAngelOffset)):
		return
	#TODO: 约束到01之间
	zenithAngelOffset = clamp(value, 0.0001, 0.9999)

func SetAzimuthAngelOffset(value:float):
	if (not Check(value,CheckType.SetAzimuthAngelOffse)):
		return
	#TODO: 约束到01之间
	azimuthAngelOffset = clamp(value, 0.0001, 0.9999)

func SetDistanceOffset(value:float):
	if (not Check(value,CheckType.SetDistanceOffset)):
		return
	#TODO: 约束到01之间
	distanceOffset = clamp(value,0,1)

func SetDistanceMax(value:float):
	if (not Check(value,CheckType.SetDistanceMax)):
		return

	distanceMax = value

func SetDistanceMin(value:float):
	if (not Check(value,CheckType.SetDistanceMin)):
		return

	distanceMin = value

func SetLerp(value:bool):
	isLerp=value

func SetLerpSpeed(value:float):
	if (not Check(value,CheckType.SetLerpSpeed)):
		return

	lerpSpeed=value
#end Setter

#region Getter
func GetLookAtTargetType():
	return lookAtTargetType
func GetLookAtSpatial():
	return lookAtSpatial
func GetLookAtPoint():
	return lookAtPoint
func GetZenithAngelOffset():
	return zenithAngelOffset
func GetAzimuthAngelOffse():
	return azimuthAngelOffset
func GetDistanceOffset():
	return distanceOffset
func GetDistanceMax():
	return distanceMax
func GetDistanceMin():
	return distanceMin
func GetLerp():
	return isLerp
func GetLerpSpeed():
	return lerpSpeed
#end Getter


#region Public Method
#以增量的方式设置极角，输入increment是一个-1到1之间的float，当极角到达0度时，无法再减小极角；当极角到达180度时，无法再增大极角；
func SetZenithAngelOffsetIncrement(increment:float):
	increment=clamp(increment,-1,1)
	var val= zenithAngelOffset + increment
	#如果val超过1，那么zenithAngelOffset=1-（val-1）=2-val,并且需要azimuthAngel+=180
	if(val <= 1 and val>=0):

		self.zenithAngelOffset=val

#以增量的方式设置方向角，输入increment是一个-1到1之间的float，方向角的设定没有上述极角限制，到达0度和360度时依然可以继续增大减小；
func SetAzimuthAngelOffsetIncrement(increment:float):
	increment = clamp(increment,-1,1)
	var val = azimuthAngelOffset + increment
	if(val > 1):
		
		self.azimuthAngelOffset = val - 1
	elif(val < 0):
		self.azimuthAngelOffset = val + 1
	else:
		self.azimuthAngelOffset = val
#region end


#region Internal Method(Do not call outsise this class!!)




func Check(input,checkType)->bool:
	if(input == null):
		print("CameraControllerError: set parameter can not be null")
		return false

	match checkType:
		CheckType.SetLookAtSpatial:
			if(lookAtTargetType==LookAtTargetType.Vector3Point):
				print("CameraControllerError: function SetLookAtSpatial() can be called only under LookAtTargetType=SpatialNode")
				return false

		CheckType.SetLookAtPoint:
			if(lookAtTargetType==LookAtTargetType.SpatialNode):
				print("CameraControllerError: function SetLookAtSpatial() can be called only under LookAtTargetType=Vector3Point")
				return false

		CheckType.SetZenithAngelOffset:
			pass

		CheckType.SetAzimuthAngelOffse:
			pass

		CheckType.SetDistanceOffset:
			pass

		CheckType.SetDistanceMax:
			if(input<0):
				print("CameraControllerError: function SetDistanceMax(value) can be called when value >=0")
				return false
			elif(input<distanceMin):
				print("CameraControllerError: fun50ction SetDistanceMax(value) can be called when DistanceMax >=DistanceMin")
				return false

		CheckType.SetDistanceMin:
			if(input<0):
				print("CameraControllerError: function SetDistanceMin(value) can be called when value >=0")
				return false
			elif(input>distanceMax):
				print("CameraControllerError: function SetDistanceMin(value) can be called when DistanceMax >=DistanceMin")
				return false

		CheckType.SetLerpSpeed:
			if(input<=0 or input>1):
				print("CameraControllerError: function SetLerpSpeed(value) can be called when 1	>=value >0")
				return false
	return true

#不借助Spatial节点的look_at（）方法自己实现
func LookAt(taregtPosition,worldUp=Vector3.UP):
	look_at(taregtPosition,worldUp)
	# var cameraAxis_Z =(transform.origin-taregtPosition).normalized()

	# var cameraAxis_X= worldUp.cross(cameraAxis_Z).normalized()
	
	# var cameraAxis_Y= cameraAxis_Z.cross(cameraAxis_X)
	
	# transform.basis=Basis(cameraAxis_X,cameraAxis_Y,cameraAxis_Z)

func LookAtLerp(taregtPosition,worldUp=Vector3.UP):
	var cameraAxis_Z =(transform.origin-taregtPosition).normalized()

	var cameraAxis_X= worldUp.cross(cameraAxis_Z).normalized()
	
	var cameraAxis_Y= cameraAxis_Z.cross(cameraAxis_X)

	var quat = Quat(transform.basis).slerp(Quat(Basis(cameraAxis_X,cameraAxis_Y,cameraAxis_Z)),lerpSpeed) 

	transform.basis = Basis(quat)


func LookAtPosition(position,taregtPosition,worldUp=Vector3.UP):
	look_at_from_position(position,taregtPosition,worldUp)
	# transform.origin=position
	# LookAt(taregtPosition,worldUp)

func LookAtPositionLerp(position,taregtPosition,worldUp=Vector3.UP):

	transform.origin= lerp(transform.origin,position,lerpSpeed)  

	LookAt(taregtPosition,worldUp)


#end Internal Method
