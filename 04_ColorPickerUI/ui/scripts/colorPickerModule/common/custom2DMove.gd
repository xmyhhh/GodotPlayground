extends Control

signal TargetButtonMove

var targetButtonNode 
var isPressingtargetButton = false

var targetButtonMin
var targetButtonMax 

var startDragPos
var startButtonPos

var pivotOffset
func _ready():
	targetButtonNode = get_child(0)
	targetButtonNode.rect_position -= targetButtonNode.rect_size / 2
	targetButtonMin =  Vector2(0,0)
	targetButtonMax = Vector2(margin_right, margin_bottom - margin_top) 
	pivotOffset = targetButtonNode.rect_size / 2
	
func _gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if ((event.is_pressed())):
			isPressingtargetButton = true
			targetButtonNode.rect_global_position = event.global_position - pivotOffset
			startDragPos = event.global_position
			startButtonPos = targetButtonNode.rect_position
			
		if ((not event.is_pressed())):
			isPressingtargetButton = false

			
	if (event is InputEventScreenDrag or event is InputEventMouseMotion) and isPressingtargetButton:

		targetButtonNode.rect_position = startButtonPos + (event.global_position - startDragPos) 
		if(targetButtonNode.rect_position.x > (targetButtonMax.x - pivotOffset.x)):
			targetButtonNode.rect_position.x = (targetButtonMax.x - pivotOffset.x)
			
		if(targetButtonNode.rect_position.x < (targetButtonMin.x - pivotOffset.x)):
			targetButtonNode.rect_position.x = (targetButtonMin.x - pivotOffset.x)
			
		if(targetButtonNode.rect_position.y > (targetButtonMax.y - pivotOffset.y)):
			targetButtonNode.rect_position.y = (targetButtonMax.y - pivotOffset.y)
			
		if(targetButtonNode.rect_position.y < (targetButtonMin.y- pivotOffset.y)):
			targetButtonNode.rect_position.y = (targetButtonMin.y - pivotOffset.y)
			
		var scale = Vector2(
			(targetButtonNode.rect_position.x + pivotOffset.x - targetButtonMin.x) / (targetButtonMax.x - targetButtonMin.x),
			(targetButtonNode.rect_position.y + pivotOffset.y - targetButtonMin.y) / (targetButtonMax.y - targetButtonMin.y)
			)
		emit_signal("TargetButtonMove", scale)

func Vec2Compare(v1, v2):
	if(v1.x > v2.x and v1.y > v2.y):
		return true
	return false
