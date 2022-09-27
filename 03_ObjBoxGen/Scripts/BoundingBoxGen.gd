extends RigidBody


onready var editorRoot =  get_tree().get_root().find_node("root", true, false)


# Called when the node enters the scene tree for the first time.
func _ready():
	var box = BoundingBoxGen(self)
	add_child(box[0])
	box[0].transform.origin = box[1]



func CollisionShapesToBox(targetNode):
	var CollisionShapeArray = editorRoot.toolScript.FindMultiNodeByType(targetNode, "CollisionShape")
	var minVec3 = null
	var maxVec3 = null
	for collisionShape in CollisionShapeArray:
		match ShapeTypeToNumber(collisionShape.shape):
			1: #CylinderShape
				var res = GetCylinderShapeBoxSize(collisionShape)
				minVec3 = Vec3Min(minVec3, res[0])
				maxVec3 = Vec3Max(maxVec3, res[1])
			2: #BoxShape
				var res = GetBoxShapeBoxSize(collisionShape)
				minVec3 = Vec3Min(minVec3, res[0])
				maxVec3 = Vec3Max(maxVec3, res[1])
			4: #CapsuleShape
				var res = GetCapsuleShapeBoxSize(collisionShape)
				minVec3 = Vec3Min(minVec3, res[0])
				maxVec3 = Vec3Max(maxVec3, res[1])
			8: #SphereShape
				var res = GetSphereShapeBoxSize(collisionShape)
				minVec3 = Vec3Min(minVec3, res[0])
				maxVec3 = Vec3Max(maxVec3, res[1])
	return [(maxVec3 + minVec3) / 2, (maxVec3 - minVec3) / 2]
	

func BoundingBoxGen(targetNode):
	var boundingBoxRoot = Spatial.new()
	
	boundingBoxRoot.name = "boundingBoxRoot"
	var box = CollisionShapesToBox(targetNode)
	var boxOrigin = box[0]
	var boxSizeHalf = box[1]
	#Step 1: 12 edge gen
	for i in range(12):
		var meshInst = editorRoot.edgePrefab.instance()
		boundingBoxRoot.add_child(meshInst)
		meshInst.transform.origin = editorRoot.eadgTrans[3 * i] * boxSizeHalf
		meshInst.transform.basis = Basis(editorRoot.eadgTrans[3 * i + 1])
	
	#Step 2: 8 horn gen
	var hornTmpArray = []
	for i in range(8):
		var meshInst = editorRoot.hornPrefab.instance()
		boundingBoxRoot.add_child(meshInst)
		meshInst.transform.origin = editorRoot.hornTrans[2 * i] * boxSizeHalf
		meshInst.transform.basis = Basis(editorRoot.hornTrans[2 * i + 1])
		hornTmpArray.append(meshInst)

	return [boundingBoxRoot, boxOrigin]


func ShapeTypeToNumber(shape):
	return int(shape.is_class("CylinderShape")) * 1 + int(shape.is_class("BoxShape")) * 2 + int(shape.is_class("CapsuleShape")) * 4 + int(shape.is_class("SphereShape")) * 8 

func Vec3Max(inVec3a, inVec3b):
	if(inVec3a==null):
		return inVec3b
	if(inVec3b==null):
		return inVec3a
	return Vector3(max(inVec3a.x, inVec3b.x), max(inVec3a.y, inVec3b.y), max(inVec3a.z, inVec3b.z))
	
func Vec3Min(inVec3a, inVec3b):
	if(inVec3a==null):
		return inVec3b
	if(inVec3b==null):
		return inVec3a
	return Vector3(min(inVec3a.x, inVec3b.x), min(inVec3a.y, inVec3b.y), min(inVec3a.z, inVec3b.z))

func GetBoxShapeBoxSize(item):
	var mesh = item.shape.get_debug_mesh()
	var itemTransaltion = item.transform.origin
	var collisonMaxPoint
	var collisonMinPoint
	if(mesh.get_surface_count()>0):
		#Returns the arrays for the vertices, normals, uvs, etc. that make up the requested surface
		var surffaceArray = mesh.surface_get_arrays(0)
		collisonMaxPoint = surffaceArray[0][0] + itemTransaltion
		collisonMinPoint = surffaceArray[0][0] + itemTransaltion
		for point in surffaceArray[0]:
			var compareTarget = point + itemTransaltion
			if(Vec3Compare(collisonMaxPoint, compareTarget)):
				collisonMaxPoint = compareTarget
			elif(not Vec3Compare(collisonMinPoint, compareTarget)):
				collisonMinPoint = compareTarget
	return [collisonMinPoint, collisonMaxPoint]


func GetSphereShapeBoxSize(item):
	var itemTransaltion = item.transform.origin
	var radius = item.shape.radius
	var collisonMaxPoint = itemTransaltion + Vector3(radius, radius, radius)
	var collisonMinPoint = itemTransaltion - Vector3(radius, radius, radius)
	return [collisonMinPoint, collisonMaxPoint]


func GetCapsuleShapeBoxSize(item):
	var itemTransaltion = item.transform.origin
	var radius = item.shape.radius
	var height = item.shape.height
	var collisonMaxPoint = itemTransaltion + Vector3(radius, height, radius)
	var collisonMinPoint = itemTransaltion - Vector3(radius, height, radius)
	return [collisonMinPoint, collisonMaxPoint]
	
func GetCylinderShapeBoxSize(item):
	var itemTransaltion = item.transform.origin
	var radius = item.shape.radius
	var height = item.shape.height
	var collisonMaxPoint = itemTransaltion + Vector3(radius, height / 2, radius)
	var collisonMinPoint = itemTransaltion - Vector3(radius, 0, radius)
	return [collisonMinPoint, collisonMaxPoint]
	
func Vec3Compare(source, target):
	if(source.x <= target.x and source.y <= target.y and source.z <= target.z):
		return true
	return false
