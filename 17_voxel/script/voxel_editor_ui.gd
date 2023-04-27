extends Node
onready var voxel_editor = get_tree().get_root().find_node("Voxel_editor", true, false)


func init():

	voxel_editor.editor_ui.get_node("MarginContainerLeft/Left/ToolList/VBoxContainer/Add").connect("pressed", self, "addButtonPressedCallback")
	voxel_editor.editor_ui.get_node("MarginContainerLeft/Left/ToolList/VBoxContainer/Remove").connect("pressed", self, "removeButtonPressedCallback")
	#voxel_editor.editor_ui.get_node("HBoxContainer/clear").connect("pressed", self, "clearButtonPressedCallback")
	voxel_editor.editor_ui.get_node("MarginContainerLeft/Left/UndoRedo/HBoxContainer/Undo").connect("pressed", self, "undoButtonPressedCallback")
	voxel_editor.editor_ui.get_node("MarginContainerLeft/Left/UndoRedo/HBoxContainer/Redo").connect("pressed", self, "redoButtonPressedCallback")
	pass # Replace with function body.

func addButtonPressedCallback():
	voxel_editor.editor_script_main.set_mode(voxel_editor.editor_script_main.Editor_Mode.Add)

func clearButtonPressedCallback():
	voxel_editor.editor_script_data.voxel_claer()
	voxel_editor.editor_script_main.reset()
	
func removeButtonPressedCallback():
	voxel_editor.editor_script_main.set_mode(voxel_editor.editor_script_main.Editor_Mode.Remove)

func undoButtonPressedCallback():
	voxel_editor.editor_script_main.undo()
	
func redoButtonPressedCallback():
	voxel_editor.editor_script_main.redo()
