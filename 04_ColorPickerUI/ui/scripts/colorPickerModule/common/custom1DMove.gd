extends Control

signal ScrollButtonMove

var scrollButtonNode 
var isPressingScrollButton = false

var scrollButtonXMin
var scrollButtonXMax 

var startDragPos
var startButtonPos
func _ready():
	scrollButtonNode = get_child(0)
	scrollButtonNode.rect_position.x -= scrollButtonNode.rect_size.x / 2
	scrollButtonXMin = rect_position.x - scrollButtonNode.rect_size.x / 2
	scrollButtonXMax = rect_position.x + margin_right 

func _gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if ((event.is_pressed())):
			isPressingScrollButton = true
			scrollButtonNode.rect_global_position.x = event.global_position.x - scrollButtonNode.rect_size.x / 2
			startDragPos = event.global_position.x
			startButtonPos = scrollButtonNode.rect_position.x
			
		if ((not event.is_pressed())):
			isPressingScrollButton = false

			
	if (event is InputEventScreenDrag or event is InputEventMouseMotion) and isPressingScrollButton:
		print("(event.global_position.x - startDragPos)", event.global_position.x ," ", startDragPos)
		if(event.position.x > scrollButtonXMax or event.position.x < scrollButtonXMin):
			print("over"," ",event.position.x," ",scrollButtonXMin," ", scrollButtonXMax)
			return
		
		scrollButtonNode.rect_position.x = startButtonPos + (event.global_position.x - startDragPos)
		if(scrollButtonNode.rect_position.x > scrollButtonXMax):
			scrollButtonNode.rect_position.x = scrollButtonXMax
			
		elif(scrollButtonNode.rect_position.x < scrollButtonXMin):
			scrollButtonNode.rect_position.x = scrollButtonXMin
			
		var scale = (scrollButtonNode.rect_position.x - scrollButtonXMin) / (scrollButtonXMax - scrollButtonXMin)
		emit_signal("ScrollButtonMove", scale)
		




