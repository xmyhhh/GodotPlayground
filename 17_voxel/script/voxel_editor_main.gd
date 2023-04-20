extends Node

enum Editor_Mode {Add = 0, Remove = 1}
enum Instruct_Type {Add = 0, Remove = 1}

onready var voxel_editor = get_tree().get_root().find_node("Voxel_editor", true, false)

var editor_mode = 0
var undo_stack = []
var redo_stack = []

func init():
	voxel_editor.editor_script_data.init()
	voxel_editor.editor_script_ui.init()
	voxel_editor.grid_render.render()

func set_mode(mode):
	if(mode == 0 or mode ==1):
		editor_mode = mode 

func undo():
	if(undo_stack.size() > 0):
		var p = undo_stack.pop_back()
		match p.type:
			Instruct_Type.Add:
				voxel_editor.editor_script_data.voxel_remove(p.value)
			
			Instruct_Type.Remove:
				voxel_editor.editor_script_data.voxel_add(p.value)
		redo_stack.push_back(p)

func redo():
	if(redo_stack.size() > 0):
		var p = redo_stack.pop_back()
		match p.type:
			Instruct_Type.Add:
				voxel_editor.editor_script_data.voxel_add(p.value)
			
			Instruct_Type.Remove:
				voxel_editor.editor_script_data.voxel_remove(p.value)
		undo_stack.push_back(p)

func ray_cast(event):
	var currentCamera = get_viewport().get_camera()
	var spaceSatae = voxel_editor.get_world().direct_space_state
	var rayOrigin = currentCamera.project_ray_origin(event.position)
	var rayEnd = rayOrigin + currentCamera.project_ray_normal(event.position) * 100
	var intersection = spaceSatae.intersect_ray(rayOrigin, rayEnd, [], 0xFFFFFFFF, false, true)
	if not intersection.empty()	:
		var self_center = null
		var target_center = null
		if(TryGetVoxelFace(intersection.collider)):
			var normal = VecApproximateZero(intersection.normal)
			self_center = intersection.position - normal/2
			target_center = self_center + normal

		elif(TryGetGrid(intersection.collider)):
			if(intersection.normal.y<0):
				return
				
			self_center = Vector3(intersection.position.x, 0, intersection.position.z)
			self_center = VecRound(self_center)
			target_center = self_center
			
		if(self_center != null):
			match(editor_mode):
				Editor_Mode.Add:
					voxel_editor.editor_script_data.voxel_add(target_center)
					undo_stack.push_back(Instruct.new(Instruct_Type.Add,target_center))
				Editor_Mode.Remove:
					voxel_editor.editor_script_data.voxel_remove(self_center)
					undo_stack.push_back(Instruct.new(Instruct_Type.Remove, self_center))
			redo_stack.clear()
			
func _physics_process(delta):
	voxel_editor.voxel_render.render(voxel_editor.editor_script_data.voxel_dict)






func TryGetVoxelFace(collider):
	if(collider.get_parent().has_meta("Voxel")):
		return true
	return false

func TryGetGrid(collider):
	if(collider.get_parent().has_meta("Grid")):
		return true
	return false


func VecApproximateZero(inVec):
	if(inVec is Vector3):
		return Vector3(FloatApproximateZero(inVec.x), FloatApproximateZero(inVec.y), FloatApproximateZero(inVec.z))
	if(inVec is Vector2):
		return Vector2(FloatApproximateZero(inVec.x), FloatApproximateZero(inVec.y))
	print("catch error in func VecApproximate:inVec can only be vector")
	return null
	
func VecRound(inVec):
	if(inVec is Vector3):
		return Vector3(int(round(inVec.x)), int(round(inVec.y)), int(round(inVec.z)))
	if(inVec is Vector2):
		return Vector2(int(round(inVec.x)), int(round(inVec.y)))
	print("catch error in func VecApproximate:inVec can only be vector")
	return null

func FloatApproximateZero(inFloat, clampMin = -0.01, clampMax = 0.01):
	if(inFloat < clampMax and clampMin < inFloat):
		return 0
	return inFloat


class Instruct:
	var type
	var value
	
	func _init(_type, _value):
		type = _type
		value = _value
