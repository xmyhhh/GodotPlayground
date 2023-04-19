extends Spatial


onready var blendCameraControllerNode = get_node("BlendCameraController")
onready var virtualCamera0 = get_node("MeshInstance1/VCamera")
onready var virtualCamera1 = get_node("Plane/VCamera2")
onready var virtualCamera2 = get_node("Plane/VCamera3")
# Called when the node enters the scene tree for the first time.
func _ready():

	yield(get_tree().create_timer(5), "timeout")
	blendCameraControllerNode.BlendToVirtualCam(virtualCamera1, 2)
#
	yield(get_tree().create_timer(15), "timeout")
	blendCameraControllerNode.BlendToVirtualCam(virtualCamera0, 3)

	yield(get_tree().create_timer(15), "timeout")
	blendCameraControllerNode.BlendToVirtualCam(virtualCamera2, 4)
