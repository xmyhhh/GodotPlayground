

extends Spatial

var tscnPath = "res://10_materialTest/tscn/"
var tscnPathDefault = "res://10_materialTest/defaultGlb/"
var maxZ = 100
var dis = 7



# Called when the node enters the scene tree for the first time.
func _ready():
	var files = listFilesInDirectory(tscnPath)
	var i = -1
	var objNum = 3000
	for j in objNum:
		var file = files[j%files.size()]
		i += 1
		var p = load(file).instance()
		add_child(p)
		var x = (i % maxZ) * dis - dis * maxZ / 2
		var z = int(i / maxZ) * dis - (dis * (objNum/maxZ) / 2)
		p.transform.origin = Vector3(x, 0, z)
	
func listFilesInDirectory(path, recursiveTimes = 0)-> PoolStringArray:
	var arr : PoolStringArray
	var dir = Directory.new()

	if dir.open(path) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			
			if dir.current_is_dir():
				print("Found directory: " + file_name)
				arr += listFilesInDirectory(path+"/"+file_name)
		 else:
				arr.push_back(path+ "/" + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

	return arr


func _physics_process(delta):
	$"Control/Label".text = "FPS " + String(Engine.get_frames_per_second())
