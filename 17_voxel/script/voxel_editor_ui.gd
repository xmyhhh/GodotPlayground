extends Node
onready var voxel_editor = get_tree().get_root().find_node("Voxel_editor", true, false)

var button_add 
var button_remove
var button_undo
var button_redo
var button_color

func init():

	button_add = voxel_editor.editor_ui.get_node("EditorMain/MarginContainerLeft/Left/ToolList/VBoxContainer/Add")
	button_add.connect("pressed", self, "addButtonPressedCallback")
	
	button_remove = voxel_editor.editor_ui.get_node("EditorMain/MarginContainerLeft/Left/ToolList/VBoxContainer/Remove")
	button_remove.connect("pressed", self, "removeButtonPressedCallback")
	
	#voxel_editor.editor_ui.get_node("HBoxContainer/clear").connect("pressed", self, "clearButtonPressedCallback")
	button_undo = voxel_editor.editor_ui.get_node("EditorMain/MarginContainerLeft/Left/UndoRedo/HBoxContainer/Undo")
	button_undo.connect("pressed", self, "undoButtonPressedCallback")
	
	button_redo = voxel_editor.editor_ui.get_node("EditorMain/MarginContainerLeft/Left/UndoRedo/HBoxContainer/Redo")
	button_redo.connect("pressed", self, "redoButtonPressedCallback")

	button_color = voxel_editor.editor_ui.get_node("EditorMain/MarginContainerLeft/Left/ToolList/VBoxContainer/Color")
	button_color.connect("pressed", self, "colorButtonPressedCallback")
	
func addButtonPressedCallback():
	voxel_editor.editor_script_main.set_mode(voxel_editor.editor_script_main.Editor_Mode.Add)
	button_remove.reset()
	button_color.reset()
	
func clearButtonPressedCallback():
	voxel_editor.editor_script_data.voxel_claer()
	voxel_editor.editor_script_main.reset()
	
func removeButtonPressedCallback():
	voxel_editor.editor_script_main.set_mode(voxel_editor.editor_script_main.Editor_Mode.Remove)
	button_add.reset()
	button_color.reset()
	
func undoButtonPressedCallback():
	voxel_editor.editor_script_main.undo()
	
func redoButtonPressedCallback():
	voxel_editor.editor_script_main.redo()

func colorButtonPressedCallback():
	button_remove.reset()
	button_add.reset()
	pass
