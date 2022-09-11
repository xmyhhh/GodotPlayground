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


var meshNode = null
var physicsBodyNode = null
var collisonNodeArray = null

var manipulate3DGUIRootNode = null
var collisonMaxPoint = null
var collisonMinPoint = null
var currentHandleInfo = null

var objInit = false
var errorObj = false
var isManipulating = false
var isHandlePressing = false
#region Godot Callback
func _ready():
	set_meta("ManipulateableObject", true)
	if(not delayInit):
		InitObject()
		
#func _input(event):
#	if(not isHandlePressing):
#		return
		
#	if event is InputEventScreenTouch and not event.is_pressed():
#		InputEventProcess(event.position)
#	elif enableMouseInput and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
#		InputEventProcess(event.position)
		
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
	var boundingBoxRoot = Spatial.new()
	
	var boxSizeHalf = Vector3(width, height, depth) / 2
	#Step 1: 12 edge gen
	for i in range(12):
		var meshInst = editorRoot.edgePrefab.instance()
		boundingBoxRoot.add_child(meshInst)
		meshInst.handleInfo.handleIndex = i
		meshInst.handleInfo.handleType = ManipulateActionType.Rotation
		meshInst.transform.origin = editorRoot.eadgTrans[2 * i] * boxSizeHalf
		meshInst.transform.basis = Basis(editorRoot.eadgTrans[2 * i + 1])
		
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

		var mesh = boxFaces[i]
		var meshInst = MeshInstance.new()
	#		var mesh = PlaneMesh.new()
	#		mesh.center_offset = Vector3(0, 0, 0)
		meshInst.mesh = mesh

		boundingBoxRoot.add_child(meshInst)
		meshInst.set_surface_material(0, editorRoot.faceMat)
		meshInst.set_script(editorRoot.handleScript)

		meshInst.handleInfo.handleIndex = i
		meshInst.handleInfo.handleType = ManipulateActionType.Position



	return boundingBoxRoot
	
func InputEventProcess(position):
	pass
#endregion


#region Tool Script
func Vec3Compare(source, target):
	if(source.x <= target.x and source.y <= target.y and source.z <= target.z):
		return true
	return false
	
func GeneratePlane(center:Vector3, halfSize:Vector3):
	var surfaceTool = SurfaceTool.new()
	surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var p0
	var p1
	if(halfSize.x == 0):
		p0 = Vector3(0, halfSize.y, -halfSize.z)
		p1 = Vector3(0, -halfSize.y, halfSize.z)
	elif(halfSize.y == 0):
		p0 = Vector3(halfSize.x, 0, -halfSize.z)
		p1 = Vector3(-halfSize.x, 0, halfSize.z)
	else:
		p0 = Vector3(halfSize.x, -halfSize.y, 0)
		p1 = Vector3(-halfSize.x, halfSize.y, 0)
		
	surfaceTool.add_vertex(center - halfSize)
	surfaceTool.add_vertex(center - p0)
	surfaceTool.add_vertex(center - p1)

	
	surfaceTool.add_vertex(center + halfSize)
	surfaceTool.add_vertex(center + p0)
	surfaceTool.add_vertex(center + p1)

	
	return surfaceTool.commit()

func GenerateBoxFace(boxCenter:Vector3, boxSizeHalf:Vector3):
	var res = []

	res.append(GeneratePlane(boxCenter - Vector3(boxSizeHalf.x, 0, 0), Vector3(0, boxSizeHalf.y, boxSizeHalf.z)))
	res.append(GeneratePlane(boxCenter + Vector3(boxSizeHalf.x, 0, 0), Vector3(0, boxSizeHalf.y, boxSizeHalf.z)))

	res.append(GeneratePlane(boxCenter - Vector3(0, boxSizeHalf.y, 0), Vector3(boxSizeHalf.x, 0, boxSizeHalf.z)))
	res.append(GeneratePlane(boxCenter + Vector3(0, boxSizeHalf.y, 0), Vector3(boxSizeHalf.x, 0, boxSizeHalf.z)))

	res.append(GeneratePlane(boxCenter - Vector3(0, 0, boxSizeHalf.z), Vector3(boxSizeHalf.x, boxSizeHalf.y, 0)))
	res.append(GeneratePlane(boxCenter + Vector3(0, 0, boxSizeHalf.z), Vector3(boxSizeHalf.x, boxSizeHalf.y, 0)))

	return res
#endregion
