extends Control


onready var effectNode = $"../Hole"
onready var expandNode = $"VBoxContainer/Expand"
onready var gatherNode = $"VBoxContainer/Gather"

onready var animationPlayerNode = $"../Hole/AnimationPlayer"


# 位置控制
#uniform float GatherMax = 1.;  #外圈比例
#uniform float GatherMin = -1.;  #内圈 为-1表示圆心对称
#uniform float Radius = 1.0;   #外圈半径
#uniform bool Symmetrical = true;  #对称变化  为false时GatherMin不起作用

#光点聚拢色彩
#uniform vec3 CenterColor = vec3(0.5, 0.8, 1.);

#光点数量
#uniform int numberPoint = 1;

#泛光大小、强度
#uniform float Floodlight = 5.0;
#uniform float LightSpotRadius = 0.05;



func _ready():
	expandNode.connect("pressed", self, "OnExpandClick")
	gatherNode.connect("pressed", self, "OnGatherClick")


func OnExpandClick():
	animationPlayerNode.play_backwards("Gather")

func OnGatherClick():
	animationPlayerNode.play("Gather")
	

