extends Node

#文件队列下载 如果有缓存就直接返回路径 如果没有就先下载再异步返回路径。
#因为一次性发起HTTP数量太大会贼卡 设计了一个队列 同时HTTP发起数量有一个上限(maxTaskNum) 超过的就排队
#详细文档地址：https://xpkiphl8oy.feishu.cn/docx/HwOndYAo9ooohRxYWtucgKwZnaf
export var cachePath = "user://avatarCache"
export var maxTaskNum = 8
export var httpTimeout = 10
export var httpMaxRedirects = 8
var currentTaskNum = 0
var TaskArray = []

func DownloadFile(fileURL, taskPram, taskCallback):
	if fileURL == null or str(fileURL) == "" or str(fileURL) == "Null":
		push_warning("error, The fileURL can not be null, do check it again!")
		taskCallback.call_func(taskPram, null)
		return
	var fileName = str(fileURL).get_file()
	if(fileName == null or str(fileName) == "" or str(fileName) == "Null"):
		push_warning("error, The fileName can not be null, do check it again!")
		taskCallback.call_func(taskPram, null)
		return
	var fullPath = cachePath + "/" + fileName
	if(CheckExist(fullPath)):
		taskCallback.call_func(taskPram, fullPath)
	else:

		if(currentTaskNum < maxTaskNum):
			currentTaskNum += 1
			FileDownload(fileURL, fullPath, taskPram, taskCallback, funcref(self, "GetFileRequestCallback"))
		else:
			TaskArray.append(DownLoadTask.new(fileURL, fullPath, taskPram, taskCallback))

func GetFileRequestCallback(result, responseCode, headers, body, requestURL, filePath, taskPram,taskCallback):
	if(responseCode == 200 and result == 0): #如果这两者其中一个都不成功，表示文件下载失败
		taskCallback.call_func(taskPram, filePath)
	else:
		taskCallback.call_func(taskPram, null)
		push_warning("GetFileRequestCallback 失败")
	if(TaskArray.size() > 0):
		var p = TaskArray.pop_front()
		FileDownload(p.fileURL, p.fullPath, p.taskPram, p.taskCallback, funcref(self, "GetFileRequestCallback"))
	else:
		currentTaskNum -= 1
		
func CheckExist(path:String)->bool:
	var file = File.new()
	if(file.file_exists(path)):
		return true
	return false

func FileDownload(url:String, savePath:String, taskPram, taskCallback, callback):
	var httpRequest = HTTPRequest.new()
	add_child(httpRequest)
	httpRequest.timeout = float(httpTimeout)
	httpRequest.max_redirects = int(httpMaxRedirects)
	httpRequest.set_use_threads(false)
	httpRequest.connect("request_completed", self, "DownloadCompleted", [httpRequest, url, savePath, taskPram,taskCallback, callback])
	CreateDirectory(cachePath)
	httpRequest.set_download_file(savePath)
	httpRequest.request(url)

func DownloadCompleted(result:int, responseCode:int, headers, body, httpRequest, requestURL, filePath, taskPram, taskCallback, callback ):
	#Step 1: Remove httpRequest node from tree
	httpRequest.queue_free()
	#Step 2: call callback
	if(callback != null):
		callback.call_func(result, responseCode, headers, body, requestURL, filePath, taskPram, taskCallback)

func CreateDirectory(path:String):
	var directory = Directory.new()
	if directory.dir_exists(path) == false:
		directory.make_dir(path)


class DownLoadTask:
	var fileURL
	var fullPath
	var taskPram
	var taskCallback
	func _init(_fileURL, _fullPath, _taskPram, _taskCallback):
		fileURL = _fileURL
		fullPath = _fullPath
		taskPram = _taskPram
		taskCallback = _taskCallback
