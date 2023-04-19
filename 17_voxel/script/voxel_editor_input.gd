extends Node
onready var voxel_editor = get_tree().get_root().find_node("Voxel_editor", true, false)


func isInputPress(event):
	var isScreenPressed = event is InputEventScreenTouch and event.is_pressed()
	var isMouseClicked =  event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed
	return isScreenPressed or isMouseClicked


var drag_start = null
var drag_end = null
var is_pressing = false
var is_rot = false
#region Godot Callback 
func _input(event):
	if (event is InputEventScreenTouch) or(event is InputEventMouseMotion) or (event is InputEventMouseButton and (event.button_index == BUTTON_LEFT or event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN or event.button_index == BUTTON_MIDDLE)):
			# 检查事件类型
			if event is InputEventScreenTouch:
				# 检查触摸手指数量
				if event.get_touch_count() == 1:
					# 处理单指点击事件
					if event.is_pressed():
						# 触摸按下时的代码
						pass
					else:
						pass
						# 触摸抬起时的代码
				elif event.get_touch_count() == 2:
					pass
					
			if event is InputEventMouseButton:
				if(event.button_index == BUTTON_LEFT):
					if event.is_pressed():
						is_pressing = true
						drag_start = event.position  # 记录鼠标按下时的位置
					elif drag_start != null:
						is_pressing = false
						drag_end = event.position  # 记录鼠标释放时的位置
						if drag_start.distance_to(drag_end) < 0.2:
							handle_input_click(event)
				if(event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN):
					handle_input_zoom(event)
					
				if(event.button_index == BUTTON_MIDDLE):
					if event.is_pressed():
						is_rot = true
					else:
						is_rot = false
			if event is InputEventMouseMotion:
				if(is_rot):
					handle_input_rot(event)
				elif(is_pressing):
					handle_input_drag(event)
#	                # 处理双指滑动和缩放事件
#	                if event.is_pressed():
#	                    # 双指按下时的代码
#	                    # 记录双指的起始位置
#	                    var pos1 = event.get_position(0)
#	                    var pos2 = event.get_position(1)
#	                else:
#	                    # 双指抬起时的代码
#	                # 检查两个触摸点的移动距离
#	                var new_pos1 = event.get_position(0)
#	                var new_pos2 = event.get_position(1)
#	                var delta1 = new_pos1 - pos1
#	                var delta2 = new_pos2 - pos2
#	                var delta = delta1 + delta2
#	                # 计算两个触摸点之间的距离
#	                var distance = (new_pos1 - new_pos2).length()
#	                # 判断是双指滑动还是缩放
#	                if distance > 100:
#	                    # 双指缩放
#	                    if delta.y > 0:
#	                        # 双指缩小
#	                    else:
#	                        # 双指放大
#	                else:
#	                    # 双指滑动
#	                    # 根据delta移动相应的物体或相机等
##endregion

func handle_input_click(event):
	print("click")
	print(event)
	
func handle_input_drag(event):
	var cam = get_viewport().get_camera()
	var target_world_pos = voxel_editor.editor_camera.lookAtPoint
	var dir = Vector2(-event.relative.x, event.relative.y) * 0.003 * (1 + voxel_editor.editor_camera.distanceOffset * 3)

	target_world_pos += ((cam.get_global_transform().basis.x) * dir.x + (cam.get_global_transform().basis.y) * dir.y)
	voxel_editor.editor_camera.lookAtPoint = target_world_pos
	print("drag")
	print(event)

func handle_input_rot(event):
	voxel_editor.editor_camera.SetZenithAngelOffsetIncrement(-event.relative.y * 0.002)
	voxel_editor.editor_camera.SetAzimuthAngelOffsetIncrement(event.relative.x * 0.002)
	print("rot")
	print(event)
	
func handle_input_zoom(event):
	if(event is InputEventMouseButton):
		if(event.button_index == BUTTON_WHEEL_UP):
			voxel_editor.editor_camera.distanceOffset += 0.05
			
		if(event.button_index == BUTTON_WHEEL_DOWN):
			voxel_editor.editor_camera.distanceOffset -= 0.05
	print("zoom")
	print(event)
