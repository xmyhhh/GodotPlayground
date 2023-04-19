extends RigidBody

onready var navAgent:NavigationAgent = $"NavigationAgent"
onready var targetNode : Spatial = get_node(targetNodePath)
export(NodePath) var targetNodePath

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	navAgent.set_target_location(get_node("../Position3D").global_transform.origin)

	var target = navAgent.get_next_location()
	print(target)

	var pos = get_global_transform().origin
#
	var max_vel = 30
	if navAgent.distance_to_target() < 5:
		max_vel = 1

	var n = $RayCast.get_collision_normal()
	if n.length_squared() < 0.01:
		n = Vector3(0, 1, 0)
	var vel = (target - pos).slide(n).normalized() * max_vel

	if not $NavigationAgent.is_navigation_finished():
		set_linear_velocity(vel)


func _on_NavigationAgent_velocity_computed(safe_velocity):
	set_linear_velocity(safe_velocity)
