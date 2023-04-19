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
		print(intersection.position)
		print(intersection.normal)


func _physics_process(delta):
	voxel_editor.voxel_render.render(voxel_editor.editor_script_data.voxel_dict)



