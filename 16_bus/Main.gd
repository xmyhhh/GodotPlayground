extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print(AudioServer.bus_count)
	print(AudioServer.get_bus_name(0))
	
	AudioServer.add_bus()
	print(AudioServer.bus_count)
	print(AudioServer.get_bus_name(0))
	print(AudioServer.get_bus_name(1))
	
	AudioServer.add_bus()
	print(AudioServer.bus_count)
	print(AudioServer.get_bus_name(0))
	print(AudioServer.get_bus_name(1))
	print(AudioServer.get_bus_name(2))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
