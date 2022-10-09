extends Control

signal TargetButtonMove

export var targetButton:NodePath
var targetButtonNode 
var isPressingtargetButton = false

var targetButtonXMin
var targetButtonXMax 

var startDragPos
var startButtonPos
func _ready():
	targetButtonNode = get_node(targetButton)
	if(targetButtonNode == null):
		targetButtonNode = get_child(0)
	targetButtonNode.rect_position.x -= targetButtonNode.rect_size.x / 2
	targetButtonXMin = rect_position.x - targetButtonNode.rect_size.x / 2
	targetButtonXMax = rect_position.x + margin_right 

func _gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if ((event.is_pressed())):
			isPressingtargetButton = true
			targetButtonNode.rect_global_position.x = event.global_position.x - targetButtonNode.rect_size.x / 2
			startDragPos = event.global_position.x
			startButtonPos = targetButtonNode.rect_position.x
			
		if ((not event.is_pressed())):
			isPressingtargetButton = false

			
	if (event is InputEventScreenDrag or event is InputEventMouseMotion) and isPressingtargetButton:
		
		if(event.position.x > targetButtonXMax or event.position.x < targetButtonXMin):
			print("over"," ",event.position.x," ",targetButtonXMin," ", targetButtonXMax)
			return
		
		targetButtonNode.rect_position.x = startButtonPos + (event.global_position.x - startDragPos)
		if(targetButtonNode.rect_position.x > targetButtonXMax):
			targetButtonNode.rect_position.x = targetButtonXMax
			
		elif(targetButtonNode.rect_position.x < targetButtonXMin):
			targetButtonNode.rect_position.x = targetButtonXMin
			
		var scale = (targetButtonNode.rect_position.x - targetButtonXMin) / (targetButtonXMax - targetButtonXMin)
		emit_signal("TargetButtonMove", scale)
		




