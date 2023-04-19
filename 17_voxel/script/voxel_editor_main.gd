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


func _physics_process(delta):
	voxel_editor.voxel_render.render(voxel_editor.editor_script_data.voxel_array)
