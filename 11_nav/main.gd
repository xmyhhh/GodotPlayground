extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var m = SpatialMaterial.new()\


func _ready():

	set_process_input(true)
	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = Color.white
# Called when the node enters the scene tree for the first time.
func _process(delta):
	var path = get_node("AGENT/NavigationAgent").get_nav_path()
	if path:
		draw_path(path)

func draw_path(path_array):
	var im = get_node("Draw")
	im.set_material_override(m)
	im.clear()
	im.begin(Mesh.PRIMITIVE_POINTS, null)
	im.add_vertex(path_array[0])
	im.add_vertex(path_array[path_array.size() - 1])
	im.end()
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for x in path_array:
		# print(str(x))
		im.add_vertex(x)
	im.end()
