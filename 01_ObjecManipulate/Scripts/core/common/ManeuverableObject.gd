extends Spatial



onready var editorRoot =  get_tree().get_root().find_node("EditorRoot", true, false)
var meshNode = null
var physicsBodyNode = null
var collisonNodeArray = null


var manipulate3DGUIRootNode


var collisonMaxPoint = null
var collisonMinPoint = null
func _ready():
	meshNode = editorRoot.toolScript.FindOneNodeByType(self, "MeshInstance")
	physicsBodyNode = editorRoot.toolScript.FindOneNodeByType(self, "PhysicsBody")
	collisonNodeArray = editorRoot.toolScript.FindMultiNodeByType(physicsBodyNode, "CollisionShape")
	if(not meshNode or not physicsBodyNode or not collisonNodeArray):
		print("Catach Error: collisonNode, meshNode and physicsBodyNode of ManeuverableObject can not be null!")
		return
	InitCollisonBoxPoint(collisonNodeArray)
	
	pass


#region Event Callback
func OnManipulateStartCallback():
	manipulate3DGUIRootNode = Spatial.new()
	add_child(manipulate3DGUIRootNode)
	manipulate3DGUIRootNode.add_child(BoundingBoxGen())
	
func OnManipulateEndCallback():
	manipulate3DGUIRootNode.queue_free()
#endregion


#region Internal Method
func InitCollisonBoxPoint(collisionNodeArray:Array):
	for item in collisionNodeArray:
		var mesh = item.shape.get_debug_mesh()
#		var m = MeshInstance.new()
#		add_child(m)
#		m.mesh = mesh
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

func BoundingBoxGen():
	var boundingBoxRoot = Spatial.new()
	var depth = collisonMaxPoint.z - collisonMinPoint.z
	var width = collisonMaxPoint.x - collisonMinPoint.x
	var height = collisonMaxPoint.y - collisonMinPoint.y
	var boxSize = Vector3(width, height, depth) / 2
	#Step 1: 12 edge gen
	for i in range(12):
		var meshInst = editorRoot.edgePrefab.instance()
		boundingBoxRoot.add_child(meshInst)
		meshInst.transform.origin = editorRoot.eadgTrans[2 * i] * boxSize
		meshInst.transform.basis = Basis(editorRoot.eadgTrans[2 * i + 1])
	#Step 2: 8 horn gen
	for i in range(8):
		var meshInst = editorRoot.hornPrefab.instance()
		boundingBoxRoot.add_child(meshInst)
		meshInst.transform.origin = editorRoot.hornTrans[2 * i] * boxSize
		meshInst.transform.basis = Basis(editorRoot.hornTrans[2 * i + 1])
#	manipulate3DGUIRootNode.add_child(meshInst)
#	meshInst.mesh = cube
	return boundingBoxRoot
	pass

#endregion



#region Tool Script
func Vec3Compare(source, target):
	if(source.x <= target.x and source.y <= target.y and source.z <= target.z):
		return true
	return false
#endregion
