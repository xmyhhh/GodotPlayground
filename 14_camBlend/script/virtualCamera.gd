tool
extends Camera
export(Array,NodePath)  var cameraTaget

var cameraTagetNodeArray = []
var activate = false

var virtualFov = null
var velocity = Vector3.ZERO

# The minimum and maximum zoom levels for the camera
const MIN_ZOOM = 40
const MAX_ZOOM = 100

# The minimum and maximum distance between the camera and the targets
const MIN_DISTANCE = 8.0
const MAX_DISTANCE = 20.0

# The smoothing factor for camera movement
const SMOOTHING_FACTOR = 0.1

# The damping factor for camera attitude changes
const DAMPING_FACTOR = 0.2


func _ready():
	set_meta("virtualCamera", true)
	for path in cameraTaget:
		var p = get_node(path)
	
		if(p == null):
			return
		
		if(p != null and not p.is_class("Spatial")):
			push_warning("Virtual camera seting not correct: cameraTaget must be Spatial!")
			return
		cameraTagetNodeArray.append(p)
	if(cameraTagetNodeArray.size()==0):
		cameraTagetNodeArray.append(InitEmptyTarget())

func _physics_process(delta):
	if(not activate):
		return
	DoUpdate(delta)


func GetTargetOrigin():
	var p = cameraTagetNodeArray.size()
	var center = Vector3(0,0,0)
	for target in cameraTagetNodeArray:
		center += target.global_transform.origin
	center = center / p

	return center

func InitEmptyTarget():
	var p = Spatial.new()
	add_child(p)
	p.transform.origin = Vector3(0, 0, -2)
	p.transform.basis = Basis.IDENTITY
	return p

func DoUpdate(delta):
	if(cameraTagetNodeArray.size()==0):
		return

	var target_position = GetTargetOrigin()

	# Calculate the desired camera position and rotation based on the targets
	var target_direction = (target_position - global_transform.origin).normalized()
	var target_distance = clamp(target_position.distance_to(global_transform.origin), MIN_DISTANCE, MAX_DISTANCE)
	var p = global_transform.origin
	target_position = target_position - target_direction * target_distance
	print(target_distance)
	# Apply damping to the camera rotation
	var target_quat = Quat(global_transform.basis).slerp(global_transform.looking_at(GetTargetOrigin(), Vector3.UP).basis, DAMPING_FACTOR)
	var target_rotation = target_quat.get_euler()

	# Calculate the desired field of view based on the distance to the targets
	var target_fov = lerp(MAX_ZOOM, MIN_ZOOM, (target_distance - MIN_DISTANCE) / (MAX_DISTANCE - MIN_DISTANCE))
	var current_fov = get_fov()
	var new_fov = lerp(current_fov, target_fov, SMOOTHING_FACTOR)
	set_fov(new_fov)

	# Set the camera position and rotation based on the desired values
	var target_pos = global_transform.origin.linear_interpolate(target_position, SMOOTHING_FACTOR)
	global_transform.origin = target_pos
	global_transform.basis = Basis(target_rotation)

#	# Apply damping to the camera position
	velocity = velocity.linear_interpolate(Vector3.ZERO, DAMPING_FACTOR)
	global_transform.origin += velocity * delta



