extends Control
signal pressed

export var OnHover:NodePath
export var OnNormal:NodePath

#region Goddot Callback
func _gui_input(event):
	if event is InputEventScreenTouch:
		if(OnHover != "" and event.is_pressed()):
			get_node(OnHover).show()
			get_node(OnNormal).hide()

		var rect = get_rect()

		rect.position.x = 0
		rect.position.y = 0

		if ((not event.is_pressed()) and (rect.has_point(event.position))):
			
			emit_signal("pressed")

		if(OnNormal != "" and not event.is_pressed()):
			get_node(OnNormal).show()
			get_node(OnHover).hide()
#endregion
