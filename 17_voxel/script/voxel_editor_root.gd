extends Spatial


onready var grid_render = get_node("Render/Grid")
onready var voxel_render = get_node("Render/Voxel")
onready var editor_camera = get_node("Camera")

onready var editor_config_theme = get_node("Config/Theme")
onready var editor_config = get_node("Config/Editor")


onready var editor_script_main = get_node("script/EditorMain")
onready var editor_script_input = get_node("script/Input")
onready var editor_script_data = get_node("script/VoxelData")
onready var editor_script_ui = get_node("script/UI")

onready var editor_ui = get_node("UI")

func _ready():
	editor_script_main.init()
