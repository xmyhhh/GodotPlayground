
extends MultiMeshInstance
onready var voxel_editor = get_tree().get_root().find_node("Voxel_editor", true, false)


func _ready():
	set_meta("Grid", true)

func render():
	for x in range(voxel_editor.editor_config.row):
		for z in range(voxel_editor.editor_config.col):
			self.multimesh.set_instance_transform(x * voxel_editor.editor_config.row + z, Transform(Basis(), Vector3(x + 0.5, 0, -z - 0.5) - Vector3(voxel_editor.editor_config.row/2.0, 0, -voxel_editor.editor_config.col/2.0)))

	





