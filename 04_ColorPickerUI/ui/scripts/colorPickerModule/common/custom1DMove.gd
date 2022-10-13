extends Control

signal TargetButtonMove

export var targetButton:NodePath
var targetButtonNode 
var isPressingtargetButton = false

var targetButtonXMin
var targetButtonXMax 

var startDragPos
var startButtonPos

var pivotOffset
export var setToRight = true

func _ready():

	targetButtonNode = get_node(targetButton)
	if(targetButtonNode == null):
		targetButtonNode = get_child(0)
	pivotOffset = targetButtonNode.rect_size.x / 2
	targetButtonXMin = rect_position.x - pivotOffset
	targetButtonXMax = rect_position.x + margin_right - pivotOffset
	
	if(not setToRight):
		targetButtonNode.rect_position.x -= pivotOffset
	else:
		targetButtonNode.rect_position.x = targetButtonXMax - pivotOffset
	

func _gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if ((event.is_pressed())):
			isPressingtargetButton = true
			targetButtonNode.rect_position.x = event.position.x - pivotOffset
			startDragPos = event.position.x
			startButtonPos = targetButtonNode.rect_position.x
			
		if ((not event.is_pressed())):
			isPressingtargetButton = false
		var scale = (targetButtonNode.rect_position.x - targetButtonXMin) / (targetButtonXMax - targetButtonXMin)
		emit_signal("TargetButtonMove", scale)
			
	if (event is InputEventScreenDrag or event is InputEventMouseMotion) and isPressingtargetButton:
		
#		if(event.position.x > targetButtonXMax or event.position.x < targetButtonXMin):
#			return
		
		targetButtonNode.rect_position.x = startButtonPos + (event.position.x - startDragPos)
		if(targetButtonNode.rect_position.x > targetButtonXMax):
			targetButtonNode.rect_position.x = targetButtonXMax
			
		elif(targetButtonNode.rect_position.x < targetButtonXMin):
			targetButtonNode.rect_position.x = targetButtonXMin
			
		var scale = (targetButtonNode.rect_position.x - targetButtonXMin) / (targetButtonXMax - targetButtonXMin)
		emit_signal("TargetButtonMove", scale)
		




