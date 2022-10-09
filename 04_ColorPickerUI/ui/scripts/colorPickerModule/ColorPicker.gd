extends TextureRect


onready var huvScrollNode = $"CenterContainer/VBoxContainer/HUVScroll/TextureProgress"
onready var alphaScrollNode = $"CenterContainer/VBoxContainer/AlphaScroll"
onready var grayPickerNode = $"CenterContainer/VBoxContainer/GrayPicker/ColorRect"


func _ready():
	huvScrollNode.connect("ScrollButtonMove", self, "huvScrollMoveCallback")




func huvScrollMoveCallback(value):
	grayPickerNode.material.set_shader_param("hue",value);
	pass
