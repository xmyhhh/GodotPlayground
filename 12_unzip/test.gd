extends Control

func _ready():
	
	$queueDownload.DownloadFile("https://static.wdabuliu.com/prod/model/215.zip",null,funcref(self,"unzip"))

func unzip(taskPram, fullPath):
	_test('Extracting a single small text file', fullPath, { 
		'215.pck': '705e5a1242c9955ae2651effa14e2f57', 
	})
	
	
func _green_text(text):
	var escape = PoolByteArray([0x1B]).get_string_from_ascii()
	var code = "[1;32m"
	return escape + code + text + escape + '[0;0m'

func _red_text(text):
	var escape = PoolByteArray([0x1B]).get_string_from_ascii()
	var code = "[1;31m"
	return escape + code + text + escape + '[0;0m'

func _test(test_name, zip_file, files):
	print('[' + test_name + ']')

	var gdunzip = load('res://addons/gdunzip/gdunzip.gd').new()
	var loaded = gdunzip.load(zip_file)

	if !loaded:
		print('- Failed loading zip file')
		return false

	var success = true

	for file in files:
		var uncompressed = gdunzip.uncompress(file)
		if !uncompressed:
			print(_red_text('✗') + ' Failed uncompressing ' + file)
			success = false
			continue

		var tmp_file = File.new()
		var tmp_file_name = file

		tmp_file.open('user://' + tmp_file_name, File.WRITE)
		tmp_file.store_buffer(uncompressed)
		tmp_file.close()

		
		print(_green_text('✓') +  ' Successfully uncompressed ' + file)

		var res = ProjectSettings.load_resource_pack('user://' + tmp_file_name)
		print("load res: ", res)
		print(list_files_in_directory("res://basicResources/propertyResources/215"))
		var a = load("res://basicResources/propertyResources/215/215.tscn")
		add_child(a.instance())
	print()
	return success
	
func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files
