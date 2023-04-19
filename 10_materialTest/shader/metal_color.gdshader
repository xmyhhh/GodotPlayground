shader_type spatial;
render_mode cull_back, depth_draw_always, diffuse_lambert, specular_blinn;
//背面剔除，对透明几何体进行不透明的深度预传，不开启高光反射, 不接收光照

uniform vec4 color : hint_color;
uniform float roughness : hint_range(0.0,1.0) = 0.1;
uniform float metal : hint_range(0.0, 1.0) = 0.7;

void fragment() {
      METALLIC = metal;
      ROUGHNESS = roughness;
      ALBEDO = color.rgb;
}