extends Spatial
signal ManipulateStart
signal ManipulateEnd

enum ManipulateActionType {Position, Rotation, Scale}
enum ManipulateDirectionType {XAsix, YAsix, ZAsix}

onready var editorRoot =  get_tree().get_root().find_node("EditorRoot", true, false)
onready var delayInit = true   #Reduce initialization burden
onready var ManipulateActionDIct  = {
	"Position" : ["XAsix", "YAsix", "ZAsix"], 
	"Rotation" : ["XAsix", "YAsix", "ZAsix"],
	"Scale" : ["XAsix", "YAsix", "ZAsix"]
}
onready var enableMouseInput =true

onready var projectionPlaneMaxSize = 200

var meshNode = null
var physicsBodyNode = null
var collisonNodeArray = null

var manipulateSessionRoot = null
var manipulate3DGUIRootNode = null
var boundingBoxRoot = null
var collisonMaxPoint = null
var collisonMinPoint = null
var currentHandleInfo = null

var objInit = false
var errorObj = false
var isManipulating = false
var isHandlePressing = false

#region position
var projectionStartPos = null
var projectionPlaneNode = null

var objStartPos = null
var objStartRot = null
var objStartScale = null
#endregion

#region Godot Callback
func _ready():
	set_meta("ManipulateableObject", true)
	manipulateSessionRoot = get_parent()
	if(not delayInit):
		InitObject()
		
func _input(event):
	if(not isHandlePressing):
		return
		
	if event is InputEventScreenTouch and not event.is_pressed():
		ReleseHandle()
		return
	if enableMouseInput and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		ReleseHandle()
		return

	match currentHandleInfo.handleType:
		ManipulateActionType.Position:
			PositionHandleProcess(event)
		ManipulateActionType.Rotation:
			RotationHandleProcess(event)
		ManipulateActionType.Scale:
			ScaleHandleProcess(event)

#endregion

#region Public Method
func InitObject():
	if(objInit):
		return
	objInit = true
	meshNode = editorRoot.toolScript.FindOneNodeByType(self, "MeshInstance")
	physicsBodyNode = editorRoot.toolScript.FindOneNodeByType(self, "PhysicsBody")
	collisonNodeArray = editorRoot.toolScript.FindMultiNodeByType(physicsBodyNode, "CollisionShape")
	if(not meshNode or not physicsBodyNode or not collisonNodeArray):
		print("Catach Error: collisonNode, meshNode and physicsBodyNode of ManeuverableObject can not be null!")
		return
	InitCollisonBoxPoint(collisonNodeArray)
#endregion

#region Event Handle
func OnManipulateStart():
	if(errorObj or isManipulating):
		return
	InitObject()
	isManipulating = true
	manipulate3DGUIRootNode = Spatial.new()
	physicsBodyNode.add_child(manipulate3DGUIRootNode)
	var depth = collisonMaxPoint.z - collisonMinPoint.z
	var width = collisonMaxPoint.x - collisonMinPoint.x
	var height = collisonMaxPoint.y - collisonMinPoint.y
	var center = (collisonMaxPoint - collisonMinPoint) / 2 + collisonMinPoint
	manipulate3DGUIRootNode.add_child(BoundingBoxGen(depth,width,height))
	manipulate3DGUIRootNode.transform.origin = center


func OnManipulateHandlePressedCallback(handleInfo):
	isHandlePressing = true
	currentHandleInfo = handleInfo
	
func OnManipulateHandleUnPressedCallback(handleInfo):
	isHandlePressing = false
	currentHandleInfo = null

func OnManipulateEnd():
	if(errorObj or not isManipulating):
		return
	isManipulating = false
	manipulate3DGUIRootNode.queue_free()

#endregion

#region Internal Method
func InitCollisonBoxPoint(collisionNodeArray:Array):
	for item in collisionNodeArray:
		var mesh = item.shape.get_debug_mesh()
		var itemTransaltion = item.transform.origin
		if(mesh.get_surface_count()>0):
			#Returns the arrays for the vertices, normals, uvs, etc. that make up the requested surface
			var surffaceArray = mesh.surface_get_arrays(0)
			if(collisonMaxPoint == null):
				collisonMaxPoint = surffaceArray[0][0] + itemTransaltion
			if(collisonMinPoint == null):
				collisonMinPoint = surffaceArray[0][0] + itemTransaltion
			for point in surffaceArray[0]:
				var compareTarget = point + itemTransaltion
				if(Vec3Compare(collisonMaxPoint, compareTarget)):
					collisonMaxPoint = compareTarget
				elif(not Vec3Compare(collisonMinPoint, compareTarget)):
					collisonMinPoint = compareTarget

func BoundingBoxGen(depth, width, height):
	boundingBoxRoot = Spatial.new()
	boundingBoxRoot.name = "boundingBoxRoot"
	var boxSizeHalf = Vector3(width, height, depth) / 2
	#Step 1: 12 edge gen
	for i in range(12):
		var meshInst = editorRoot.edgePrefab.instance()
		boundingBoxRoot.add_child(meshInst)
		meshInst.handleInfo.handleIndex = i
		meshInst.handleInfo.handleType = ManipulateActionType.Rotation
		meshInst.transform.origin = editorRoot.eadgTrans[3 * i] * boxSizeHalf
		meshInst.transform.basis = Basis(editorRoot.eadgTrans[3 * i + 1])
		meshInst.handleInfo.handleData = {"normal": editorRoot.eadgTrans[3 * i + 2]}
	#Step 2: 8 horn gen
	for i in range(8):
		var meshInst = editorRoot.hornPrefab.instance()
		boundingBoxRoot.add_child(meshInst)
		meshInst.handleInfo.handleIndex = i
		meshInst.handleInfo.handleType = ManipulateActionType.Scale
		meshInst.transform.origin = editorRoot.hornTrans[2 * i] * boxSizeHalf
		meshInst.transform.basis = Basis(editorRoot.hornTrans[2 * i + 1])

	#Step 3: 6 face gen(position)
	var boxFaces = GenerateBoxFace(Vector3(0, 0, 0), boxSizeHalf)
	for i in range(6):
		var mesh = boxFaces[i][0]
		#make face Area 
		var meshInst = MeshInstance.new()
		var area = Area.new()
		var collisionShape = CollisionShape.new()
		var boxShape = BoxShape.new()
		
		meshInst.add_child(area)
		area.add_child(collisionShape)

		boxShape.extents =  Vector3(boxFaces[i][1][0],boxFaces[i][1][1], boxFaces[i][1][2]) 
		collisionShape.shape = boxShape

		meshInst.mesh = mesh
		boundingBoxRoot.add_child(meshInst)
		meshInst.set_surface_material(0, editorRoot.faceMat)
		meshInst.set_script(editorRoot.handleScript)
		meshInst.transform.origin = boxFaces[i][2]
		meshInst.handleInfo.handleIndex = i
		meshInst.handleInfo.handleType = ManipulateActionType.Position
		meshInst.handleInfo.handleData = {"normal": boxFaces[i][3], "center": boxFaces[i][2]}
	return boundingBoxRoot
	
func ReleseHandle():
	if(currentHandleInfo.handleType == ManipulateActionType.Position):
		if(is_instance_valid(projectionPlaneNode)):
			projectionPlaneNode.queue_free()
			projectionStartPos = null
	if(currentHandleInfo.handleType == ManipulateActionType.Rotation):
		if(is_instance_valid(projectionPlaneNode)):
			projectionPlaneNode.queue_free()
			projectionStartPos = null
	isHandlePressing = false
	currentHandleInfo = null
	pass

func PositionHandleProcess(event):
	if(not is_instance_valid(projectionPlaneNode)):
		CreateProjectionPlane(event, currentHandleInfo.handleData["normal"], currentHandleInfo.handleData["center"] + transform.origin)

	if event is InputEventScreenDrag or event is InputEventMouseMotion:
		var currentCamera = get_viewport().get_camera()
		var spaceSatae = get_world().direct_space_state
		var rayOrigin = currentCamera.project_ray_origin(event.position)
		var rayEnd = rayOrigin + currentCamera.project_ray_normal(event.position) * get_parent().manipulateMaxDistance
		var intersection = spaceSatae.intersect_ray(rayOrigin, rayEnd, [], 0x7FFFFFFF, false, true)
		if not intersection.empty()	:
			#try get if it is ProjectionPlane
#			print(intersection.collider.get_path())
			var intersectionPlaneCollideroot = TryGetIntersectionProjectionPlaneRoot(intersection.collider)
			if(intersectionPlaneCollideroot != null):
				if(projectionStartPos == null):
					projectionStartPos = VecApproximateZero(intersection.position)
					objStartPos = transform.origin
				else:
					var movePos = VecApproximateZero(intersection.position - projectionStartPos)
					var vecApproximate = VecApproximateZero(movePos)
#					print("--------------------")
#					print("movePos", movePos)
#					print("objStartPos", objStartPos)
#					print("vecApproximate", vecApproximate)
#					print("objStartPos + vecApproximate", objStartPos + vecApproximate)
					#region move obj
					transform.origin = objStartPos + vecApproximate
					#endregion
var i = 0
func RotationHandleProcess(event):
	if(not is_instance_valid(projectionPlaneNode)):
		CreateProjectionPlane(event, currentHandleInfo.handleData["normal"], transform.origin)
	
	if event is InputEventScreenDrag or event is InputEventMouseMotion:
		var currentCamera = get_viewport().get_camera()
		var spaceSatae = get_world().direct_space_state
		var rayOrigin = currentCamera.project_ray_origin(event.position)
		var rayEnd = rayOrigin + currentCamera.project_ray_normal(event.position) * get_parent().manipulateMaxDistance
		var intersection = spaceSatae.intersect_ray(rayOrigin, rayEnd, [], 0x7FFFFFFF, false, true)
		if not intersection.empty()	:
			#try get if it is ProjectionPlane
#			print(intersection.collider.get_path())
			var intersectionPlaneCollideroot = TryGetIntersectionProjectionPlaneRoot(intersection.collider)
			if(intersectionPlaneCollideroot != null):
				if(projectionStartPos == null):
					if((VecApproximateZero(intersection.position) - transform.origin).length() > 0.1):
						projectionStartPos = VecApproximateZero(intersection.position)
						objStartRot = transform
				else:
					var p1 = VecApproximateZero(intersection.position - transform.origin)
					var p2 = VecApproximateZero(projectionStartPos - transform.origin)
					transform.origin = Vector3(0, 0, 0)
					transform = objStartRot.rotated((p1.cross(p2).normalized()), -p1.angle_to(p2))
					transform.origin = objStartRot.origin
					if(i%20 == 0):
						i+=1
						print("--------------------")
						print("p1.angle_to(p2):", p1.angle_to(p2))
						print("p1.cross(p2):", (p1.cross(p2)).normalized() )
						print("p1:", p1)
						print("p2:", p2)
					else:
						i+=1
					#region rotate obj
				
					#endregion
func ScaleHandleProcess(event):
	print("ScaleHandleProcess")
#endregion

#region Tool Script
func Vec3Compare(source, target):
	if(source.x <= target.x and source.y <= target.y and source.z <= target.z):
		return true
	return false
func VecAbs(inVec):
	if(inVec is Vector3):
		return Vector3(abs(inVec.x), abs(inVec.y), abs(inVec.z))

func VecApproximateZero(inVec):
	if(inVec is Vector3):
		return Vector3(floatApproximateZero(inVec.x), floatApproximateZero(inVec.y), floatApproximateZero(inVec.z))
	if(inVec is Vector2):
		return Vector2(floatApproximateZero(inVec.x), floatApproximateZero(inVec.y))
		print("catch error in func VecApproximate:inVec can only be vector")
	return null
	
func floatApproximateZero(inFloat, clampMin = -0.01, clampMax = 0.01):
	if(inFloat < clampMax and clampMin < inFloat):
		return 0
	return inFloat
	
func GeneratePlane(center:Vector3, halfSize:Vector3):
	var surfaceTool = SurfaceTool.new()
	surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var p
	var boxsize
	var normal 
	if(halfSize.x == 0):
		p = Vector3(0, halfSize.y, -halfSize.z)
		boxsize = Vector3(0.001, halfSize.y, halfSize.z)
		normal = Vector3(1, 0, 0)
	elif(halfSize.y == 0):
		p = Vector3(halfSize.x, 0, -halfSize.z)
		boxsize = Vector3(halfSize.x, 0.001, halfSize.z)
		normal = Vector3(0, 1, 0)
	else:
		p = Vector3(halfSize.x, -halfSize.y, 0)
		boxsize = Vector3(halfSize.x, halfSize.y, 0.001)
		normal = Vector3(0, 0, 1)
	
	surfaceTool.add_vertex( - halfSize)
	surfaceTool.add_vertex( - p)
	surfaceTool.add_vertex( + p)

	surfaceTool.add_vertex( + halfSize)
	surfaceTool.add_vertex( - p)
	surfaceTool.add_vertex( + p)

#	var ploygonArray:PoolVector3Array = [(center - halfSize), (center - p), (center + halfSize)]
##	print(ploygonArray)
	return [surfaceTool.commit(), boxsize, center, normal]

func GenerateBoxFace(boxCenter:Vector3, boxSizeHalf:Vector3):
	var res = []
	res.append(GeneratePlane(boxCenter - Vector3(boxSizeHalf.x, 0, 0), Vector3(0, boxSizeHalf.y, boxSizeHalf.z)))
	res.append(GeneratePlane(boxCenter + Vector3(boxSizeHalf.x, 0, 0), Vector3(0, boxSizeHalf.y, boxSizeHalf.z)))

	res.append(GeneratePlane(boxCenter - Vector3(0, boxSizeHalf.y, 0), Vector3(boxSizeHalf.x, 0, boxSizeHalf.z)))
	res.append(GeneratePlane(boxCenter + Vector3(0, boxSizeHalf.y, 0), Vector3(boxSizeHalf.x, 0, boxSizeHalf.z)))

	res.append(GeneratePlane(boxCenter - Vector3(0, 0, boxSizeHalf.z), Vector3(boxSizeHalf.x, boxSizeHalf.y, 0)))
	res.append(GeneratePlane(boxCenter + Vector3(0, 0, boxSizeHalf.z), Vector3(boxSizeHalf.x, boxSizeHalf.y, 0)))
	return res

func CreateProjectionPlane(event, normal, center):
	var meshInst = MeshInstance.new()
	var planeMesh = PlaneMesh.new()
	var area = Area.new()
	var collisionShape = CollisionShape.new()
	var boxShape = BoxShape.new()

	planeMesh.size = Vector2(projectionPlaneMaxSize, projectionPlaneMaxSize)
	
	manipulateSessionRoot.add_child(meshInst)
	meshInst.add_child(area)
	area.add_child(collisionShape)
	area.transform.basis = Basis(Quat(normal.cross(Vector3.UP), -normal.angle_to(Vector3.UP)))
	
	meshInst.name = "ProjectionPlane"
	meshInst.mesh = planeMesh
	meshInst.set_surface_material(0, editorRoot.planeMat)
	meshInst.transform.basis = Basis(Quat(normal.cross(Vector3.UP), normal.angle_to(Vector3.UP)))
	meshInst.transform.origin = center
	
	projectionPlaneNode = meshInst
	area.set_meta("ProjectionPlane", true)

	var boxSize
	if(normal.x == 1):
		boxSize = Vector3(0.0011, projectionPlaneMaxSize/2.0, projectionPlaneMaxSize/2.0)
	elif(normal.y == 1):
		boxSize = Vector3(projectionPlaneMaxSize/2.0, 0.0011, projectionPlaneMaxSize/2.0)
	else:
		boxSize = Vector3(projectionPlaneMaxSize/2.0, projectionPlaneMaxSize/2.0, 0.0011)
	boxShape.extents =  boxSize
	collisionShape.shape = boxShape

func TryGetIntersectionProjectionPlaneRoot(collider):
	if(collider.get_parent().name == "ProjectionPlane"):
		return collider
	return null
	
#endregion
