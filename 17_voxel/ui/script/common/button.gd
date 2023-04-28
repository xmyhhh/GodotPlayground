extends Control
signal pressed

export var OnHover:NodePath
export var OnNormal:NodePath
export var keepState = true

#region Goddot Callback
func reset():
	get_node(OnNormal).show()
	get_node(OnHover).hide()

func _gui_input(event):
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		if(OnHover != "" and event.is_pressed()):
			get_node(OnHover).show()
			get_node(OnNormal).hide()

		var rect = get_rect()

		rect.position.x = 0
		rect.position.y = 0

		if ((not event.is_pressed()) and (rect.has_point(event.position))):
			
			emit_signal("pressed")
			if(keepState):
				return
				
		if(OnNormal != "" and not event.is_pressed()):
			get_node(OnNormal).show()
			get_node(OnHover).hide()
#endregion
