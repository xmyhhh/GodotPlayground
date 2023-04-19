extends MultiMeshInstance
onready var voxel_editor = get_tree().get_root().find_node("Voxel_editor", true, false)


func render(voxel_data):
	self.multimesh.instance_count = voxel_data.size()

	var i = -1
	for item in voxel_data:
		i += 1
		self.multimesh.set_instance_transform(i, Transform(Basis(), item.pos))
		self.multimesh.set_instance_custom_data(i, item.color)
	pass
	




#region Inernal Class
class Voxel:
	var pos = Vector3(0, 0, 0)
	var color = Color(0, 0, 0, 1)
	func _init(_pos:Vector3, _color:Color):
		pos = _pos
		color = _color
#endregion
