extends MultiMeshInstance
onready var voxel_editor = get_tree().get_root().find_node("Voxel_editor", true, false)
onready var area_node = get_node("Area")

var creat_area = true
var voxel_data_old

func render(voxel_data):
	self.multimesh.instance_count = voxel_data.size()
	var i = -1
	for item in voxel_data:
		var voxel = voxel_data[item]
		i += 1
		self.multimesh.set_instance_transform(i, Transform(Basis(), voxel.pos))
		self.multimesh.set_instance_custom_data(i, voxel.color)

		if(creat_area):
			if(voxel_data_old != null and voxel_data_old.has(item)):
				voxel_data_old.erase(item)
				continue
			create_area_at_pos(item, voxel.pos)

			
	if(creat_area and voxel_data_old != null):
		for item in voxel_data_old:
			remove_area_by_id(item)
	
	voxel_data_old = voxel_data.duplicate()
	
	
func remove_area_by_id(id):
	var p = area_node.get_node(id)
	area_node.remove_child(p)
	p.queue_free()
	
func create_area_at_pos(id, pos):
	var p = CollisionShape.new()
	p.shape = BoxShape.new()
	p.shape.extents = Vector3(0.5, 0.5, 0.5)
	area_node.add_child(p)
	p.name = id
	p.transform.origin = pos


#region Inernal Class
class Voxel:
	var pos = Vector3(0, 0, 0)
	var color = Color(0, 0, 0, 1)
	
	func _init(_pos:Vector3, _color:Color):
		pos = _pos
		color = _color
		
	func get_id():
		return str(pos.x) + ',' + str(pos.y) + ',' + str(pos.z)
#endregion
