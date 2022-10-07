extends Control


signal ScrollButtonMove

var scrollButtonNode 
var isPressingScrollButton = false
var scrollButtonPos = Vector2(0,0)

var scrollButtonXMin
var scrollButtonXMax 

var scrollButtonGlobalXMin
var scrollButtonGlobalXMax 

func _ready():
	scrollButtonNode = get_child(0)
	scrollButtonNode.rect_position.x -= scrollButtonNode.rect_size.x / 2
	scrollButtonXMin = rect_position.x - scrollButtonNode.rect_size.x / 2
	scrollButtonXMax = rect_position.x + margin_right - scrollButtonNode.rect_size.x / 2
	#这个地方为什么rect_global_position会出现负数？？？？
	scrollButtonGlobalXMax = scrollButtonXMax + rect_global_position.x + OS.window_size.x
	scrollButtonGlobalXMin = scrollButtonXMin + rect_global_position.x + OS.window_size.x
	pass
func _gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if ((event.is_pressed())):
			isPressingScrollButton = true
			scrollButtonNode.rect_global_position.x = event.global_position.x - scrollButtonNode.rect_size.x / 2

			
		if ((not event.is_pressed())):
			isPressingScrollButton = false

			
	if (event is InputEventScreenDrag or event is InputEventMouseMotion) and isPressingScrollButton:

		if(event.global_position.x > scrollButtonGlobalXMax or event.global_position.x < scrollButtonGlobalXMin):
			print("over"," ",event.global_position.x," ",scrollButtonGlobalXMin," ", scrollButtonGlobalXMax)
			return
			
		scrollButtonNode.rect_position.x += event.relative.x
		if(scrollButtonNode.rect_position.x > scrollButtonXMax):
			scrollButtonNode.rect_position.x = scrollButtonXMax
			
			
		elif(scrollButtonNode.rect_position.x < scrollButtonXMin):
			scrollButtonNode.rect_position.x = scrollButtonXMin
			
			
		var scale = (scrollButtonNode.rect_position.x - scrollButtonXMin) / (scrollButtonXMax - scrollButtonXMin)
		emit_signal("ScrollButtonMove", scale)
		
func ScrollButtonPressCallback():
	scrollButtonPos = scrollButtonNode.rect_position
	isPressingScrollButton = true
	pass
	
func ScrollButtonUnPressCallback():
	isPressingScrollButton = false
	pass



