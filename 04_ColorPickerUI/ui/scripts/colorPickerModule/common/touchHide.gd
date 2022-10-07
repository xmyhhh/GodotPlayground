extends Control
class_name TouchHide
signal TouchHidePressed

#region Goddot Callback
func _gui_input(event):
	if event is InputEventScreenTouch:
#		print()
		if not event.is_pressed():
			emit_signal("TouchHidePressed")
			self.hide()

#endregion
