extends Control

signal ColorButtonMove

var colorButtonNode 
var isPressingColorButton = false

var colorButtonMin
var colorButtonMax 

var startDragPos
var startButtonPos

var pivotOffset
func _ready():
	colorButtonNode = get_child(0)
	colorButtonNode.rect_position -= colorButtonNode.rect_size / 2
	colorButtonMin =  Vector2(0,0)
	colorButtonMax = Vector2(margin_right, margin_bottom - margin_top) 
	pivotOffset = colorButtonNode.rect_size / 2
func _gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if ((event.is_pressed())):
			isPressingColorButton = true
			colorButtonNode.rect_global_position = event.global_position - pivotOffset
			startDragPos = event.global_position
			startButtonPos = colorButtonNode.rect_position
			
		if ((not event.is_pressed())):
			isPressingColorButton = false

			
	if (event is InputEventScreenDrag or event is InputEventMouseMotion) and isPressingColorButton:
#		print(""," ",event.position," ", colorButtonMax," ", colorButtonMin)

#		if(Vec2Compare(event.position, colorButtonMax) or not Vec2Compare(event.position, colorButtonMin)):
#			print("over")
#			return
		
		colorButtonNode.rect_position = startButtonPos + (event.global_position - startDragPos) 
		if(colorButtonNode.rect_position.x > (colorButtonMax.x - pivotOffset.x)):
			colorButtonNode.rect_position.x = (colorButtonMax.x - pivotOffset.x)
			
		if(colorButtonNode.rect_position.x < (colorButtonMin.x - pivotOffset.x)):
			colorButtonNode.rect_position.x = (colorButtonMin.x - pivotOffset.x)
			
		if(colorButtonNode.rect_position.y > (colorButtonMax.y - pivotOffset.y)):
			colorButtonNode.rect_position.y = (colorButtonMax.y - pivotOffset.y)
			
		if(colorButtonNode.rect_position.y < (colorButtonMin.y- pivotOffset.y)):
			colorButtonNode.rect_position.y = (colorButtonMin.y - pivotOffset.y)
			
		var scale = Vector2(
			(colorButtonNode.rect_position.x + pivotOffset.x - colorButtonMin.x) / (colorButtonMax.x - colorButtonMin.x),
			(colorButtonNode.rect_position.y + pivotOffset.y - colorButtonMin.y) / (colorButtonMax.y - colorButtonMin.y)
			)
		emit_signal("ColorButtonMove", scale)

func Vec2Compare(v1, v2):
	if(v1.x > v2.x and v1.y > v2.y):
		return true
	return false
