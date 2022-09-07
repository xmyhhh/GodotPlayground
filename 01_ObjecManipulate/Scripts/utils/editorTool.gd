extends Object


# 按照正则表达式匹配node路径，匹配到的节点使用operateFunc操作这个节点，最后返回操作过节点的总数；startNum 初始= {'startNum': 0}
static func OperateNodeInTreeByRegEx(root:Node, regex:RegEx, operateFunc:FuncRef, startNum:Dictionary={'startNum': 0})->int:
	for childNode in root.get_children():
		if(regex.search(childNode.get_path())):
			startNum["startNum"] +=1
			if(operateFunc != null):
				operateFunc.call_func(childNode,startNum["startNum"]-1) #这个地方-1是因为“startNum["startNum"]-1”这个参数表示操作节点的编号，从0号开始
		OperateNodeInTreeByRegEx(childNode,regex,operateFunc,startNum)
	return startNum["startNum"]

# 按照正则表达式匹配node路径，最后返回匹配到节点的路径
static func FindNodeInTreeByRegEx(root:Node,regex:RegEx,res:Array=[])->Array:
	for childNode in root.get_children():
		if(regex.search(childNode.get_path())):
			res.append(childNode.get_path())
		FindNodeInTreeByRegEx(childNode,regex,res)
	return res


# 按照正则表达式匹配node路径(排除符合Exclude规则的结果)，最后返回匹配到节点的路径
static func FindNodeInTreeByRegExExclude(root:Node,regex:RegEx,regexExclude:RegEx,res:Array=[])->Array:
	for childNode in root.get_children():
		if(regex.search(childNode.get_path())):
			if(regexExclude.search(childNode.get_path()) == null):
				res.append(childNode.get_path())

		FindNodeInTreeByRegExExclude(childNode, regex, regexExclude, res)
	return res



static func FindOneNodeByType(root:Node,type:String)->Node:
	if(root.is_class(type)):
		return root
	for childNode in root.get_children():
		var res = FindOneNodeByType(childNode,type)
		if res !=null:
			return res
	return null

static func FindMultiNodeByType(root:Node,type:String,res:Array = []):
	if(root.is_class(type)):
		res.append(root)
	for childNode in root.get_children():
		FindMultiNodeByType(childNode, type, res)
	return res
	
static func MakeStaticBodyAaea(node:StaticBody,factor=1.1)->Area:
	var collisionShapeArray=[]
	FindMultiNodeByType(node,"CollisionShape",collisionShapeArray)

	var area = Area.new()
	area.monitoring=true
	for collisionShape in collisionShapeArray:
		var collisionShapeNew = collisionShape.duplicate()
		collisionShapeNew.scale.y = collisionShapeNew.scale.y *factor
		collisionShapeNew.scale.z = collisionShapeNew.scale.z *factor
		collisionShapeNew.scale.x = collisionShapeNew.scale.x *factor
		area.add_child(collisionShapeNew)

	return area

static func DebugLog(msg:String):
	if(true):
		print("DebugLogInfo: " + msg)

static func MakeOneShotTimer(node:Node, duration:float, callback:FuncRef):
	yield(node.get_tree().create_timer(duration), "timeout")
	if(callback!=null):
		callback.call_func()



static func listFilesInDirectory(path, recursiveTimes=0)-> PoolStringArray:
	var arr: PoolStringArray
	var dir := Directory.new()
	dir.open(path)

	if dir.file_exists(path):
		arr.append(path)

	else:
		dir.list_dir_begin(true,  true)
		while(true):
			var subpath := dir.get_next()
			if subpath.empty():
				break
			if (recursiveTimes<20):  #做一个限制，防止无限递归
				arr += listFilesInDirectory(path.plus_file(subpath), recursiveTimes+1)

	return arr


static func StringArrayFilterByRegEx(strArray:PoolStringArray, regex:RegEx) ->PoolStringArray:
	var res : PoolStringArray
	for strItem in strArray:
		if(regex.search(strItem)):
			res.append(strItem)
	return res


static func StringArrayRandom(strArray):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var num = rng.randi_range(0, strArray.size()-1)
	return strArray[num]
