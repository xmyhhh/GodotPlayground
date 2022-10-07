extends Control

var scrollButtonNode 
var isPressingScrollButton = false
var scrollButtonPos = Vector2(0,0)

var scrollButtonXMin
var scrollButtonXMax 

func _ready():
	scrollButtonNode = get_child(0)
	scrollButtonNode.rect_position.x -= scrollButtonNode.rect_size.x / 2
	scrollButtonXMin = rect_position.x - scrollButtonNode.rect_size.x / 2
	scrollButtonXMax = rect_position.x + margin_right - scrollButtonNode.rect_size.x / 2
	
	
func _gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if ((event.is_pressed())):
			isPressingScrollButton = true
			var a = scrollButtonNode.rect_global_position
			print(scrollButtonNode.rect_global_position)

			scrollButtonNode.rect_global_position.x = event.global_position.x
			pass
		if ((not event.is_pressed())):
			isPressingScrollButton = false
			
	if (event is InputEventScreenDrag or event is InputEventMouseMotion) and isPressingScrollButton:
		scrollButtonNode.rect_position.x += event.relative.x
		if(scrollButtonNode.rect_position.x > scrollButtonXMax):
			scrollButtonNode.rect_position.x = scrollButtonXMax
		elif(scrollButtonNode.rect_position.x < scrollButtonXMin):
			scrollButtonNode.rect_position.x = scrollButtonXMin
			
func ScrollButtonPressCallback():
	scrollButtonPos = scrollButtonNode.rect_position
	isPressingScrollButton = true
	pass
	
func ScrollButtonUnPressCallback():
	isPressingScrollButton = false
	pass



