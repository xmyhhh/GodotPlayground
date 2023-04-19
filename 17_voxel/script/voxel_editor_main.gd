extends Node
onready var voxel_editor = get_tree().get_root().find_node("Voxel_editor", true, false)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func init():
	voxel_editor.editor_script_data.init()
	voxel_editor.editor_script_ui.init()
	voxel_editor.grid_render.render()
#	voxel_editor.voxel_render.render(voxel_editor.editor_data.voxel_array)


func ray_cast(event):
	var currentCamera = get_viewport().get_camera()
	var spaceSatae = voxel_editor.get_world().direct_space_state
	var rayOrigin = currentCamera.project_ray_origin(event.position)
	var rayEnd = rayOrigin + currentCamera.project_ray_normal(event.position) * 100
	var intersection = spaceSatae.intersect_ray(rayOrigin, rayEnd, [], 0xFFFFFFFF, false, true)
	if not intersection.empty()	:
	
		var normal = VecApproximateZero(intersection.normal)
		var center = intersection.position - normal/2
		print(normal)
		print(VecRound(center))
		voxel_editor.editor_script_data.voxel_add(center + normal)
		
func _physics_process(delta):
	voxel_editor.voxel_render.render(voxel_editor.editor_script_data.voxel_dict)


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

