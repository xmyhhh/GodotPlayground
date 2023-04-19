shader_type spatial;
render_mode cull_back, depth_draw_always, diffuse_lambert, specular_blinn;
//背面剔除，对透明几何体进行不透明的深度预传，不开启高光反射, 不接收光照

uniform sampler2D color;
uniform float roughness : hint_range(0.0,1.0) = 0.1;
uniform float metal : hint_range(0.0, 1.0) = 0.7;
varying vec3 world_position;
varying vec3 world_normal;
varying vec3 world_camera;

void vertex()
{
        world_position = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
        world_normal = (WORLD_MATRIX * vec4(NORMAL,0.0)).xyz;
        world_camera = (CAMERA_MATRIX * vec4(0, 0, 0, 1)).xyz;
}

void fragment() {
      METALLIC = metal;
      ROUGHNESS = roughness;
      ALBEDO = texture(color,world_normal.xy * -1.0 ).rgb;
}