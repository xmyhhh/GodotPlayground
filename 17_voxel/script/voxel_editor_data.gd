extends Node
onready var voxel_editor = get_tree().get_root().find_node("Voxel_editor", true, false)


var voxel_dict = {}

func init():
	var p = voxel_editor.voxel_render.Voxel.new(Vector3(0,0,0), Color(0.0, 1.0, 0.0, 1.0))
	voxel_dict[p.get_id()] = p
	
	pass # Replace with function body.


func voxel_random_add():
	var pos_row = randi() % (voxel_editor.editor_config.row - 1) / 2
	var pos_col= randi() % (voxel_editor.editor_config.col - 1) / 2
	
	if(rand_range(0, 1)>0.5):
		pos_row = -pos_row
		pos_col = -pos_col
		
	var color = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1), rand_range(0, 1))
	var p = voxel_editor.voxel_render.Voxel.new(Vector3(pos_row, 0, pos_col), color)
	voxel_dict[p.get_id()] = p

func voxel_add(pos, color = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1), rand_range(0, 1))):
	var p  = VecRound(pos)
	var key = str(p.x) + ',' + str(p.y) + ',' + str(p.z)
	if(voxel_dict.has(key) or p.y<0):
		return
	var q = voxel_editor.voxel_render.Voxel.new(p, color)
	voxel_dict[q.get_id()] = q

func voxel_remove(pos):
	var p  = VecRound(pos)
	var key = str(p.x) + ',' + str(p.y) + ',' + str(p.z)
	if(voxel_dict.has(key)):
		voxel_dict.erase(key)

func voxel_claer():
	voxel_dict.clear()

func VecRound(inVec):
	if(inVec is Vector3):
		return Vector3(int(round(inVec.x)), int(round(inVec.y)), int(round(inVec.z)))
	if(inVec is Vector2):
		return Vector2(int(round(inVec.x)), int(round(inVec.y)))
	print("catch error in func VecApproximate:inVec can only be vector")
	return null
