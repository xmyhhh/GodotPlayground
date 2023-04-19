extends Object


static func CreateDirectory(path:String):
	var directory = Directory.new()
	if directory.dir_exists(path) == false:
		directory.make_dir(path)

	directory.change_dir(path)

static func CheckExist(path:String)->bool:
	var file = File.new()
	if(file.file_exists(path)):
		return true
	return false
