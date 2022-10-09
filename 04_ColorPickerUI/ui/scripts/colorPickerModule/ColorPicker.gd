extends TextureRect


onready var hScrollNode = $"CenterContainer/VBoxContainer/HScroll/TextureProgress"
onready var alphaScrollNode = $"CenterContainer/VBoxContainer/AlphaScroll/TextureProgress"
onready var svPickerNode = $"CenterContainer/VBoxContainer/SVPicker/ColorRect"
onready var previewNode = $"CenterContainer/VBoxContainer/Hex/HBoxContainer/MarginContainer/ColorRect"

var hue = 0
var saturation = 0
var ligintness = 1
var alpha = 1

func _ready():
	hScrollNode.connect("TargetButtonMove", self, "HScrollMoveCallback")
	svPickerNode.connect("TargetButtonMove", self, "SVPickerMoveCallback")
	alphaScrollNode.connect("TargetButtonMove", self, "AlphaScrollMoveCallback")
	UpdateShader()
	
func HScrollMoveCallback(value):
	hue = value
	UpdateShader()

func AlphaScrollMoveCallback(value):
	alpha = 1 - value
	UpdateShader()

func SVPickerMoveCallback(value):
	saturation = value.x
	ligintness = 1 - value.y
	UpdateShader()
	
func UpdateShader():
	print("saturation", saturation)
	print("ligintness", ligintness)
	#	Color from_hsv(h: float, s: float, v: float, a: float = 1.0)
	var color = Color.from_hsv(hue, saturation, ligintness) 
	var color_noSV =  Color.from_hsv(hue, 1, 1) 
	color.a = alpha
	
	svPickerNode.material.set_shader_param("hue", hue);
	svPickerNode.targetButtonNode.material.set_shader_param("innerColor", color);
	
	hScrollNode.targetButtonNode.material.set_shader_param("innerColor", color_noSV);
	
	alphaScrollNode.targetButtonNode.material.set_shader_param("innerColor", color);
	alphaScrollNode.material.set_shader_param("targetColor", color);
	
	previewNode.material.set_shader_param("innerColor", color);

	
	
#uniform vec4 outerColor = vec4(1,1,1,1);
#uniform vec4 innerColor = vec4(0,0,0,1);


