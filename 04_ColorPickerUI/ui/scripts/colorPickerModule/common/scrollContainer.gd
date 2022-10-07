extends Control


onready var scrollVBoxContainer = get_node("VBoxContainer")
var isScrolling = false
#region Godot Callback
func _ready():
	connect("scroll_started", self, "OnScrollStartedCallback")
#	connect("scroll_ended", self, "OnScrollEndedCallback")
	
func _input(event):
	if event is InputEventScreenTouch and not event.is_pressed():
		yield(get_tree(),"idle_frame")
		isScrolling = false
#endregion
#region Event Callback
func OnScrollStartedCallback():
	isScrolling = true
	
#func OnScrollEndedCallback():
#	print("scroll end")
#	isScrolling = false
#endregion


#region Public Method 
func AddItem(item):
	scrollVBoxContainer.add_child(item)

		
func GetItem(index:int):
	if(index <= scrollVBoxContainer.get_child_count()):
		return scrollVBoxContainer.get_child(index)

func ClearAllItem():

	for n in scrollVBoxContainer.get_children():
		scrollVBoxContainer.remove_child(n)
		n.queue_free()

func ReplaceItem(index:int, item):
	var n = scrollVBoxContainer.get_child(index)
	scrollVBoxContainer.add_child_below_node(n,item)
	n.get_parent().remove_child(n)
	n.queue_free()
	
func GetAllItem():
	return scrollVBoxContainer.get_children()
#endregion
