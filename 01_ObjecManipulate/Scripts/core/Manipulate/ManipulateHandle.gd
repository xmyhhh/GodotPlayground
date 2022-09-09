extends Node

var handleInfo = HandleInfo.new()

func _ready():
	set_meta("ManipulateableHandle", true)
	


#region Inernal Class
class HandleInfo:
	var handleIndex = null
	var handleType = null
#endregion
