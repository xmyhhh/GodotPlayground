shader_type spatial;
render_mode cull_back,depth_draw_always,specular_disabled;
//背面剔除，总是进行深度测试，关闭镜面反射，不受环境光影响
uniform float power : hint_range(0,10) = 2.0;
uniform sampler2D tex;
uniform vec4 albedo_color : hint_color  = vec4(1, 1, 1, 1);

void fragment() {
        ALBEDO = texture(tex, UV).rgb * power * albedo_color.rgb;
}