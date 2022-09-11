extends Spatial

const PIE = 3.1415926
const HALF_PIE = 1.5707963
var toolScript = load("res://01_ObjecManipulate/Scripts/utils/editorTool.gd")
var handleScript = load("res://01_ObjecManipulate/Scripts/core/Manipulate/ManipulateHandle.gd")

var edgePrefab = load("res://01_ObjecManipulate/prefabs/edge.tscn")
var eadgTrans = [
	Vector3(1, 1, 0),   Quat(Vector3(1, 0, 0), HALF_PIE),
	Vector3(-1, -1, 0), Quat(Vector3(1, 0, 0), HALF_PIE),
	Vector3(1, -1, 0),  Quat(Vector3(1, 0, 0), HALF_PIE),
	Vector3(-1, 1, 0),  Quat(Vector3(1, 0, 0), HALF_PIE),
	
	Vector3(0, 1, 1),   Quat(Vector3(0, 0, 1), HALF_PIE),
	Vector3(0, -1, -1), Quat(Vector3(0, 0, 1), HALF_PIE),
	Vector3(0, 1, -1),  Quat(Vector3(0, 0, 1), HALF_PIE),
	Vector3(0, -1, 1),  Quat(Vector3(0, 0, 1), HALF_PIE),
	
	Vector3(1, 0, 1),   Quat(Vector3(0, 1, 0), 0),
	Vector3(-1, 0, -1), Quat(Vector3(0, 1, 0), 0),
	Vector3(1, 0, -1),  Quat(Vector3(0, 1, 0), 0),
	Vector3(-1, 0, 1),  Quat(Vector3(0, 1, 0), 0)
]

var hornPrefab = load("res://01_ObjecManipulate/prefabs/horn.tscn")
var hornTrans = [
	Vector3(1, 1, 1),   Quat(Vector3(0, 1, 0), HALF_PIE),
	Vector3(1, 1, -1), Quat(Vector3(0, 1, 0), PIE),
	
	Vector3(-1, 1, 1),   Quat(Vector3(0, 1, 0), 0),
	Vector3(-1, 1, -1), Quat(Vector3(0, 1, 0), -HALF_PIE),
	
	Vector3(1, -1, 1),  Quat(0.5, 0.5, 0.5, 0.5),
	Vector3(1, -1, -1),  Quat(0.707, 0.707, 0, 0),

	Vector3(-1, -1, 1),  Quat(Vector3(0, 0, 1), HALF_PIE),
	Vector3(-1, -1, -1),   Quat(0.5, 0.5, -0.5, -0.5),
]

var faceMat = load("res://01_ObjecManipulate/shaders/BoundingBoxFaceMat.tres")
