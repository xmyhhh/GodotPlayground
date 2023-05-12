extends KinematicBody


var follow_target_node = null
var follow_zoom = Vector3(3.0, 8.0, 25.0)    #stop walk run tele
var speed = Vector2(2.5, 3.5)    #walk run
var lerp_speed = 0.2
var allow_y = false
var set_follow = false
var random = RandomNumberGenerator.new()

var linear_velocity = Vector3()
var target_linear_velocity = Vector3()
var random_speed_factor = 0.5




	
func set_follow_target(target):
	if(target.is_class("Spatial")):
		follow_target_node = target
	else:
		follow_target_node = null
		push_error("follow_target_node must be Spatial type")
		
func start_follow():
	set_follow = true
	
	
func stop_follow():
	set_follow = false
	

func _physics_process(delta):
	

	if(follow_target_node != null and set_follow):
	
		var dis = global_translation.distance_to(follow_target_node.global_translation) 
		var dirction = (follow_target_node.global_translation - global_translation ).normalized()
		if(not allow_y):
			dirction.y = 0
	
		if(dis < follow_zoom.x):
#			var acc = Vector3(max_speed, max_speed, max_speed).slerp(linear_velocity, lerp_speed)
			target_linear_velocity = Vector3()
		
				
		elif(dis > follow_zoom.x and dis < follow_zoom.y):
#			target_linear_velocity = speed.x * dirction
			target_linear_velocity = lerp(target_linear_velocity, (speed.x + random.randfn() * random_speed_factor) * dirction, lerp_speed)
			
		else:
#		elif(dis > follow_zoom.y and dis < follow_zoom.z):
#			target_linear_velocity = speed.y * dirction
			target_linear_velocity = lerp(target_linear_velocity, (speed.y + random.randfn() * random_speed_factor) * dirction, lerp_speed)
		
	
	linear_velocity = move_and_slide(linear_velocity)
	linear_velocity = lerp(linear_velocity, target_linear_velocity, lerp_speed - 0.1)
	
#	print(linear_velocity.length())
	
func get_random_vector3():
	random.randomize()
	return Vector3(random.randfn(), 0.0, random.randfn()).normalized()
	
