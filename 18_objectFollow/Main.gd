extends Spatial

onready var ObjectNode = $"Object"
onready var ObjectNode2 = $"Object2"
onready var ObjectNode3 = $"Object3"
onready var ObjectNode4 = $"Object4"
onready var ObjectNode5 = $"Object5"
onready var playerNode = $"Player"


# Called when the node enters the scene tree for the first time.
func _ready():
	ObjectNode.set_follow_target(playerNode)
	ObjectNode2.set_follow_target(ObjectNode)
	ObjectNode3.set_follow_target(ObjectNode2)
	ObjectNode4.set_follow_target(ObjectNode3)
	ObjectNode5.set_follow_target(ObjectNode4)
	
	
	ObjectNode.start_follow()
	ObjectNode2.start_follow()
	ObjectNode3.start_follow()
	ObjectNode4.start_follow()
	ObjectNode5.start_follow()
