extends TextureRect

signal ColorChange
signal ColorConfirm

onready var hScrollNode = $"CenterContainer/VBoxContainer/HScroll/TextureProgress"
onready var alphaScrollNode = $"CenterContainer/VBoxContainer/AlphaScroll/TextureProgress"
onready var svPickerNode = $"CenterContainer/VBoxContainer/SVPicker/ColorRect"
onready var previewNode = $"CenterContainer/VBoxContainer/Hex/VBoxContainer/HBoxContainer/MarginContainer/ColorRect"
onready var textEditNode = $"CenterContainer/VBoxContainer/Hex/VBoxContainer/HBoxContainer/CenterContainer/TextEdit"
onready var confirmButton = $"CenterContainer/VBoxContainer/ConfirmButton/TextureRect"


var hue = 0
var saturation = 0
var ligintness = 1
var alpha = 1

var finalColor = Color(1,1,1,1)

func _ready():

	hScrollNode.connect("TargetButtonMove", self, "HScrollMoveCallback")
	svPickerNode.connect("TargetButtonMove", self, "SVPickerMoveCallback")
	alphaScrollNode.connect("TargetButtonMove", self, "AlphaScrollMoveCallback")
	confirmButton.connect("pressed", self, "ConfirmButtonPressedCallback")
	UpdateShaderAndText()
	
func HScrollMoveCallback(value):
	hue = value
	UpdateShaderAndText()

func AlphaScrollMoveCallback(value):
	alpha = value
	UpdateShaderAndText()

func SVPickerMoveCallback(value):
	saturation = value.x
	ligintness = 1 - value.y
	UpdateShaderAndText()

func ConfirmButtonPressedCallback():
	emit_signal("ColorConfirm", finalColor)

func UpdateShaderAndText():

	#Step 1: calulate color
	var color = Color.from_hsv(hue, saturation, ligintness) 
	color.a = alpha
	finalColor = color
	
	var color_halpAlpha = color
	color_halpAlpha.a = color_halpAlpha.a / 2
	
	var color_noSV =  Color.from_hsv(hue, 1, 1) 

	#Step 2: update shader parm
	svPickerNode.material.set_shader_param("hue", hue);
	svPickerNode.targetButtonNode.material.set_shader_param("innerColor", color);

	hScrollNode.targetButtonNode.material.set_shader_param("innerColor", color_noSV);
	
	alphaScrollNode.targetButtonNode.material.set_shader_param("innerColor", color);

	alphaScrollNode.material.set_shader_param("targetColor", color);
	
	previewNode.material.set_shader_param("innerColor", color);
	previewNode.material.set_shader_param("outerColor", color_halpAlpha);
	
	#Step 3: update text
	textEditNode.text = "#" + color.to_html(false)
	
	#Step 4: emit signal
	emit_signal("ColorChange", color)


