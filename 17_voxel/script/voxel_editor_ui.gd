extends Node
onready var voxel_editor = get_tree().get_root().find_node("Voxel_editor", true, false)


func init():
	voxel_editor.editor_ui.get_node("add").connect("pressed", self, "addButtonPressedCallback")
	voxel_editor.editor_ui.get_node("clear").connect("pressed", self, "clearButtonPressedCallback")
	pass # Replace with function body.

func addButtonPressedCallback():
	voxel_editor.editor_script_data.voxel_random_add()

func clearButtonPressedCallback():
	voxel_editor.editor_script_data.voxel_claer()
