extends MeshInstance


#注意，这个脚本只是为了测试 对于功能没有实际意义

onready var colorPickerUINode = $"../UI/ColorPickerModule"

func _ready():
	colorPickerUINode.connect("ColorChange", self, "ColorChangeCallback")



func ColorChangeCallback(value):
	var a = get_surface_material(0)
	get_surface_material(0).albedo_color =  value;
